//
//  CPInnerHelper.m
//  chat-plugin
//
//  Created by Grand on 2019/7/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPInnerState.h"
#import "key_tool.h"
#import "string_tools.h"
#import "audio_format_tool.h"

#import "NSDate+YYAdd.h"
#import "NSString+YYAdd.h"
#import "CPBridge.h"

#import <Alamofire/Alamofire-Swift.h>
#import <chat_plugin/chat_plugin-Swift.h>

#import "ConnectManager.h"
#import "MessageObjects.h"
#import "CPAccountHelper.h"
#import "CPChatLog.h"
#import "CPSendMsgHelper.h"
#import "CPAccountHelper+Private.h"

static CPInnerState *_instance;
dispatch_queue_t readSerialQueue;
dispatch_queue_t writeSerialQueue;

@interface CPInnerState () <ConnectManagerDelegate>

@property (nonatomic, strong) NetWorkCheck *netChecker;
@property (nonatomic, strong) ConnectManager *connectManager;

@end

@implementation CPInnerState

- (void)dealloc
{
    NSLog(@"dealloc -- %@", self.class);
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized (self) {
            _instance = [[CPInnerState alloc] _init];
        }
    });
    
    return _instance;
}

- (instancetype)init
{
    NSAssert(NO, @"use shared");
    return nil;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
        readSerialQueue = dispatch_queue_create("com.netcloth.chat.sq.rd", DISPATCH_QUEUE_SERIAL); // read msg from connect
        writeSerialQueue = dispatch_queue_create("com.netcloth.chat.sq.wt", DISPATCH_QUEUE_SERIAL); //op db
        self.chatDelegates = [NSHashTable weakObjectsHashTable];
        
        self.netChecker = [[NetWorkCheck alloc] init];
        [self.netChecker check];
        
        [MessageObjects configAction];
    }
    return self;
}

//MARK:- Login
//now reset resource
- (void)userlogin {
    self.cacheMsgManager = [[CPOfflineMsgManager alloc] init];
    self.imageCaches = [[CPImageCaches alloc] initWithUid:self.loginUser.userId];
    self.connectManager = ConnectManager.shared;
    self.msgRecieve = ChatMessageHandleRecieve.alloc.init;
    self.groupMsgRecieve = GroupChatMessageHandleRecieve.alloc.init;
    self.groupContactCache = LittleArrayStorage.alloc.init;
}

- (void)userlogout {
    self.imageCaches = nil;
    self.cacheMsgManager = nil;
    self.msgRecieve = nil;
    self.groupMsgRecieve = nil;
    
    [self.loginUserDataBase close];
    self.loginUserDataBase = nil;
    self.loginUser = nil;
    decodePrivateKey = "";
    
    self.groupContactCache = nil;
}


//MARK:- Connect
BOOL _RegisterOk = false;
- (BOOL)connectServiceHost:(NSString *)host
                      port:(uint16_t)port {
    _RegisterOk = false;
    [self.connectManager connectHost:host port:port delegate:self];
    return true;
}

- (void)disconnect {
    [self asynDoTask:^{
        _RegisterOk = false;
        [self.connectManager disconnectDeleteStore:true];
    }];
}

- (BOOL)isConnected {
    if (self.connectManager) {
        return self.connectManager.isConnected && self.netChecker.netOk && _RegisterOk;
    }
    return false;
}
- (BOOL)isNetworkOk {
    return self.netChecker.netOk;
}

//MARK: Connect Delegate
- (void)onConnectSuccess {
    //send register msg
    [self sendRegisterMsg];
    [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
}

- (void)onConnectError {
    //may need toast ui
    _RegisterOk = false;
    [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
}

- (void)onConnectReadPack:(NCProtoNetMsg * _Nullable)netmsg {
    if (!netmsg) {
        return;
    }
    [self OnGetPbPack:netmsg];
}

- (void)onShouldReinitConnectToUseNewHostAndPort {
    [CPAccountHelper onShouldReinitConnectToUseNewHostAndPort];
}

//MARK:- Register
- (void)sendRegisterMsg {
    NCProtoNetMsg *pack =
    CreateRegister(getPublicKeyFromUser(self.loginUser), getDecodePrivateKeyForUser(self.loginUser, self.loginUser.password));
    [self.connectManager sendMsg:pack];
}

//MARK:- 发消息

- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg {
    [self _pbmsgSend:netmsg autoCallNetStatus:nil];
}
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg autoCallNetStatus:(CPMessage *)message {
    
    [self asynDoTask:^{
        if ([self isConnected] == false && message) {
            //Note:
            [self asynWriteTask:^{
                message.toServerState = 2;
                //update db
                [CPInnerState.shared.loginUserDataBase
                 updateRowsInTable:kTableName_Message
                 onProperties:{CPMessage.toServerState}
                 withObject:message
                 where:CPMessage.msgId == message.msgId];
                
                [self msgAsynCallRecieveStatusChange:message];
            }];
            return;
        }
        [self.connectManager sendMsg:netmsg];
        
        
        if (message) {
            [self.cacheMsgManager handleOnlineMsg:message];
        }
        
#if DEBUG
        long long sign_hash = (long long)GetHash(nsdata2bytes(netmsg.head.signature));
        //INTEGER  值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中
        NSLog(@"pb >> sendname %@, hash %lld", netmsg.name , sign_hash);
#endif
    }];
}

//MARK:- 收消息

- (void)OnGetPbPack:(NCProtoNetMsg *)pack
{
    [CPInnerState.shared asynReadTask:^{
        
#if DEBUG
        NSString *fromPubkey = [pack.head.fromPubKey hexString_lower];
        fromPubkey = fromPubkey.length > 10 ? [fromPubkey substringFromIndex:126] : fromPubkey;
        
        NSString *toPubkey = [pack.head.toPubKey hexString_lower];
        toPubkey = toPubkey.length > 10 ? [toPubkey substringFromIndex:126] : toPubkey;
        
        
        long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
        NSLog(@"pb << msgId: %lld \n msgname: %@ \n senderKey: %@ \n toKey: %@ \n sign: %lld",pack.head.msgId, pack.name, fromPubkey, toPubkey , sign_hash);
#endif
        //dispatch msg
        SEL method = [MessageObjects actionSelectorForPack:pack.name];
        if (!method) {
            NSLog(@"pb << unknown %@",pack.name);
            return;
        }
        
        if ([self respondsToSelector:method]) {
            [self performSelector:method withObject:pack];
        }
        else if ([self.msgRecieve respondsToSelector:method]) {
            [self.msgRecieve performSelector:method withObject:pack];
        }
        else if ([self.groupMsgRecieve respondsToSelector:method]) {
            [self.groupMsgRecieve performSelector:method withObject:pack];
        }
        
    }];
}

- (void)actionForRegisterRsp:(NCProtoNetMsg *)pack {
    NCProtoRegisterRsp *body = [NCProtoRegisterRsp parseFromData:pack.data_p error:nil];
    if (body.result != 0) {
        //error
        _RegisterOk = false;
        [self.connectManager disconnect];
    } else {
        _RegisterOk = true;
        [self asynDoTask:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
            [NSNotificationCenter.defaultCenter postNotificationName:kServiceRegisterOk object:nil];
        }];
        
        [self.cacheMsgManager _bridgeOnLogin];
        [CPSendMsgHelper bindDeviceToken];
        [self.msgRecieve resendLatest_180s_unsendMsg];
    }
    //replay
    [self.msgRecieve clientReplay:pack];
}



//MARK:- Call Delegate

// 收到消息回调
- (void)msgAsynCallBack:(CPMessage *)msg {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onReceiveMsg:)]) {
                [face onReceiveMsg:msg];
            }
        }
    }];
}
- (void)msgAsynCallRecieveStatusChange:(CPMessage *)msg {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onMsgSendStateChange:)]) {
                [face onMsgSendStateChange:msg];
            }
        }
    }];
}

- (void)msgAsynCallRecieveChatCaches:(NSArray<CPMessage *> *)caches {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onCacheMsgRecieve:)]) {
                [face onCacheMsgRecieve:caches];
            }
        }
    }];
}

- (void)msgAsynCallReceiveGroupChatMsgs:(NSArray<CPMessage *> *)groups {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onReceiveGroupChatMsgs:)]) {
                [face onReceiveGroupChatMsgs:groups];
            }
        }
    }];
}

- (void)msgAsynCallCurrentRoomInfoChange {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onCurrentRoomInfoChange)]) {
                [face onCurrentRoomInfoChange];
            }
        }
    }];
}
- (void)msgAsynCallonUnreadRsp:(NSArray<CPUnreadResponse *> *)response {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onUnreadRsp:)]) {
                [face onUnreadRsp:response];
            }
        }
    }];
}

- (void)msgAsynCallonReceiveNotify:(CPGroupNotify *)notice {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onReceiveNotify:)]) {
                [face onReceiveNotify:notice];
            }
        }
    }];
}

- (void)msgAsynCallonSessionsChange:(id)approved {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onSessionNeedChange:)]) {
                [face onSessionNeedChange:approved];
            }
        }
    }];
}

- (void)onLogonNotify:(NCProtoNetMsg *)notify {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onLogonNotify:)]) {
                [face onLogonNotify:notify];
            }
        }
    }];
}

//MARK: 消息撤回
- (void)onRecallSuccessNotify:(NCProtoNetMsg *)successNotify {
    [self dispatchSelector:_cmd body:successNotify];
}

- (void)onRecallFailedNotify:(NCProtoNetMsg *)failNotify {
    [self dispatchSelector:_cmd body:failNotify];
}

- (void)dispatchSelector:(SEL)selector  body:(id)para {
    [self asynDoTask:^{
        for (id<ChatDelegate> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:selector]) {
                try {
                    [face performSelector:selector withObject:para];
                } catch (NSError *err) {
                    
                }
            }
        }
    }];
}


//MARK:- Tool


/**
 On Main queue
 @param task
 */
- (void)asynDoTask:(dispatch_block_t)task {
    [self doTask:task onQueue:dispatch_get_main_queue()];
}

- (void)asynWriteTask:(dispatch_block_t)task {
    [self doTask:task onQueue:writeSerialQueue];
}

- (void)asynReadTask:(dispatch_block_t)task {
    [self doTask:task onQueue:readSerialQueue];
}



- (void)doTask:(dispatch_block_t)task
       onQueue:(dispatch_queue_t)queue {
    [self doTask:task onQueue:queue isAsync:YES];
}

- (void)doTask:(dispatch_block_t)task
       onQueue:(dispatch_queue_t)queue
       isAsync:(BOOL)async
{
    if (async) {
        dispatch_async(queue, task);
    }
    else {
        dispatch_sync(queue, task);
    }
}

@end
