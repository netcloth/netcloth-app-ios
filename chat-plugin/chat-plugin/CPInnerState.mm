







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

static NSMutableDictionary *_ActionNamesMap;

@interface CPInnerState () <ConnectManagerDelegate>

@property (nonatomic, strong) CPOfflineMsgManager *cacheMsgManager;
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
        readSerialQueue = dispatch_queue_create("com.netcloth.chat.sq.rd", DISPATCH_QUEUE_SERIAL);
        writeSerialQueue = dispatch_queue_create("com.netcloth.chat.sq.wt", DISPATCH_QUEUE_SERIAL);
        self.chatDelegates = [NSHashTable weakObjectsHashTable];
        
        self.cacheMsgManager = [[CPOfflineMsgManager alloc] init];
        
        self.netChecker = [[NetWorkCheck alloc] init];
        [self.netChecker check];
        
        self.connectManager = ConnectManager.shared;
        
        [self configActions];
    }
    return self;
}

#ifndef NSValuePoint
#define NSValuePoint(point)  [NSValue valueWithPointer:point]
#endif

- (void)configActions {
    _ActionNamesMap = @{}.mutableCopy;
    _ActionNamesMap[kMsg_RegisterRsp] =  NSValuePoint(@selector(actionForRegisterRsp:));
    _ActionNamesMap[kMsg_Text] =  NSValuePoint(@selector(actionForText:));
    _ActionNamesMap[kMsg_Audio] = NSValuePoint(@selector(actionForAudio:));
    _ActionNamesMap[kMsg_Image] = NSValuePoint(@selector(actionForImage:));

    _ActionNamesMap[kMsg_ServerReceipt] = NSValuePoint(@selector(actionForServerReceipt:));

    _ActionNamesMap[kMsg_CacheMsgRsp] = NSValuePoint(@selector(actionForCacheMsgRsp:));
}


BOOL _RegisterOk = false;
- (BOOL)connectServiceHost:(NSString *)host
                      port:(uint16_t)port {
    _RegisterOk = false;
    [self.connectManager connectHost:host port:port delegate:self];
    [self _setup];
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

- (void)_setup {
    self.imageCaches = nil;
    self.imageCaches = [[CPImageCaches alloc] initWithUid:self.loginUser.userId];
}


- (void)onConnectSuccess {

    [self sendRegisterMsg];
    [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
}

- (void)onConnectError {

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


- (NSString *)curEnv {
    return nil;
}


- (NSString *)switchEnv {
    return nil;
}



- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg {
    [self _pbmsgSend:netmsg autoCallNetStatus:nil];
}
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg autoCallNetStatus:(CPMessage *)message {
    
    [self asynDoTask:^{
        if ([self isConnected] == false && message) {

            [self asynWriteTask:^{
                message.toServerState = 2;

                [CPInnerState.shared.loginUserDataBase
                 updateRowsInTable:kTableName_Message
                 onProperties:{CPMessage.toServerState}
                 withObject:message
                 where:CPMessage.msgId == message.msgId];
                
                [self asynCallStatusChange:message];
            }];
            return;
        }
        [self.connectManager sendMsg:netmsg];
        
#if DEBUG
        long long sign_hash = (long long)GetHash(nsdata2bytes(netmsg.head.signature));

        NSLog(@"coremsg - send Msg type %@ , msg hash %lld", netmsg.name ,sign_hash);
#endif
    }];
}


- (void)sendRegisterMsg {
    NCProtoNetMsg *pack =
    CreateRegister(getPublicKeyFromUser(self.loginUser), getDecodePrivateKeyForUser(self.loginUser, self.loginUser.password));
    [self.connectManager sendMsg:pack];
}



- (void)OnGetPbPack:(NCProtoNetMsg *)pack
{
    [CPInnerState.shared asynReadTask:^{
        
        Class cls = [MessageObjects messageClassForName:pack.name];
        if (!cls) {
            NSLog(@"coremsg-recieve-unknown-type %@",pack.name);
            return;
        }

        SEL method = (SEL)[_ActionNamesMap[pack.name] pointerValue];
        if (!method) {
            NSLog(@"coremsg-recieve-unknown-action-type %@",pack.name);
            return;
        }
        
        [self performSelector:method withObject:pack];
#if DEBUG
        long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
        NSLog(@"coremsg-recieve-msg-hash %lld name %@",sign_hash,pack.name);
#endif
    }];
}






- (CPMessage * )_dealRecieveNetMsg:(NCProtoNetMsg *)msg
                           isCache:(BOOL)isCache
                   storeEncodeData:(id)data
{
    std::string fromPubkey = nsdata2bytes(msg.head.fromPubKey);
    NSString *senderpubkey = hexStringFromBytes(fromPubkey);
    
    std::string toPubKey = nsdata2bytes(msg.head.toPubKey);

    CPMessage *cpmsg = CPMessage.alloc.init;
    cpmsg.senderPubKey = senderpubkey;
    cpmsg.toPubkey = hexStringFromBytes(toPubKey);
    

    if ([data isKindOfClass:NSData.class]) {
        cpmsg.msgData = dataHexFromBytes(nsdata2bytes(data));
    }
    else if ([data isKindOfClass:GPBMessage.class]) {
    }
    else {
        return nil;
    }
    
    cpmsg.version = GetAppVersion();
    long long sign_hash = (long long)GetHash(nsdata2bytes(msg.head.signature));
    cpmsg.signHash = sign_hash;
    cpmsg.toServerState = 1;
    
    if (msg.head.msgTime > 1000) {
        double server_time = msg.head.msgTime / 1000.0;
        cpmsg.createTime = server_time;
    }
    

    BOOL isInRoom = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.chatToPubkey];
    BOOL isSelfSend = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.loginUser.publicKey];
    if (isInRoom || isSelfSend) {
        cpmsg.read = YES;
    }
    

    if ([msg.name isEqualToString:(NSString *)kMsg_Audio]) {
        cpmsg.msgType = MessageTypeAudio;
    }
    else if ([msg.name isEqualToString:(NSString *)kMsg_Text]) {
        cpmsg.msgType = MessageTypeText;
    }
    else if ([msg.name isEqualToString:(NSString *)kMsg_Image]) {
        cpmsg.msgType = MessageTypeImage;
        cpmsg.msgData = nil;
        NCProtoImage *image = (NCProtoImage *)data;
        cpmsg.fileHash = image.id_p;
        cpmsg.pixelWidth = image.width;
        cpmsg.pixelHeight = image.height;
    }
    else {
        cpmsg.msgType = MessageTypeUnknown;
    }
    

    BOOL update = [CPInnerState.shared storeMessge:cpmsg isCacheMsg:isCache];
    return update ? cpmsg : nil;
}

- (BOOL)storeMessge:(CPMessage *)message isCacheMsg:(BOOL)isCache
{
    BOOL isme =  [message.senderPubKey isEqualToString:self.loginUser.publicKey];

    int sessionId = 0;
    long long messageId = 0;
    SessionType sessionType = SessionTypeP2P;
    double createTime = [NSDate.date timeIntervalSince1970];
    

    NSString *contactPubkey = isme ? message.toPubkey : message.senderPubKey;
    CPContact *contact = [self selectContactByPubkey:contactPubkey];
    
    

    if (contact == nil) {
        contact = [self create_InsertContactByPubkey:contactPubkey createTime:createTime];
        if (contact == nil) {
            NSLog(@"MSG - Contact - err");
            return NO;
        }
    }
    sessionId = contact.sessionId;
    
    if (contact.isBlack) {
        NSLog(@"MSG - Black - err");
        return false;
    }
    
    


    message.senderRemark = contact.remark;
    message.sessionId = sessionId;
    if (message.createTime <= 10) {
        message.createTime = createTime;
    }
    message.isAutoIncrement = YES;
    

    CPMessage *findMsg = [self selectMsgBySendPubkey:message.senderPubKey toPubkey:message.toPubkey signHash:message.signHash];
    if (findMsg != nil) {
        long long msgid = findMsg.msgId;
        message.msgId = msgid;
        NSLog(@"MSG - find - exist msg");
        return NO;
    }
    
    NSAssert(message.createTime > 0, @"Message create Time Must Set 2");

    BOOL update = [self.loginUserDataBase insertObject:message into:kTableName_Message];
    if (update == NO) {
        NSLog(@"MSG - error >> insert message db");
        return NO;
    }
    messageId = message.lastInsertedRowID;
    message.msgId = messageId;
    

    CPSession *haved = [self selectSessionBySessionId:sessionId];
    if (haved) {

        update = [self.loginUserDataBase updateRowsInTable:kTableName_Session
                                              onProperties:{CPSession.lastMsgId, CPSession.updateTime}
                                                   withRow:@[@(messageId), @(createTime)]
                                                     where:CPSession.sessionId == sessionId];
    }
    else {
        CPSession *insert =
        [self create_InsertSession:sessionId type:sessionType lastMsgId:messageId ctime:createTime utime:createTime];
        update = insert ? YES : NO;
    }
    if (update == NO) {

        NSLog(@"MSG >> error >> insert session db");
    }
    return YES;
}

- (void)actionForRegisterRsp:(NCProtoNetMsg *)pack {
    NCProtoRegisterRsp *body = [NCProtoRegisterRsp parseFromData:pack.data_p error:nil];
    if (body.result != 0) {

        _RegisterOk = false;
        [self.connectManager disconnect];
    } else {
        _RegisterOk = true;
        [self asynDoTask:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
        }];
        
        [self.cacheMsgManager _bridgeOnLogin];
        [CPSendMsgHelper bindDeviceToken];
        [self resendLatest_180s_unsendMsg];
    }

    [self clientReplay:pack];
}

- (void)actionForText:(NCProtoNetMsg *)pack {
    NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];

    if (insertOk) {
        [self asynCallBackMsg:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }

    [self clientReplay:pack];
}

- (void)actionForAudio:(NCProtoNetMsg *)pack {
    NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];

    if (insertOk) {
        [self asynCallBackMsg:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }

    [self clientReplay:pack];
}

- (void)actionForImage:(NCProtoNetMsg *)pack {
    NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body];

    if (insertOk) {
        [self asynCallBackMsg:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }

    [self clientReplay:pack];
}



- (void)actionForServerReceipt:(NCProtoNetMsg *)pack {
    
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
    

    WCTCondition condition =
    CPMessage.senderPubKey == hexStringFromBytes(fromPubkey) &&
    CPMessage.toPubkey == hexStringFromBytes(toPubKey) &&
    CPMessage.signHash == sign_hash;
    
    WCTOneRow *row = [self.loginUserDataBase getOneRowOnResults:{
        CPMessage.msgId}
                                                      fromTable:kTableName_Message
                                                          where:condition];
    if (row == nil) {
        return;
    }
    
    
    CPMessage *cpmsg = CPMessage.alloc.init;
    
    NCProtoServerReceipt *body = [NCProtoServerReceipt parseFromData:pack.data_p error:nil];
    int result = 1;
    if (body.result != 0) {
        result = 2;
    }
    if (body.result == 2) {
        cpmsg.toUserNotFound = true;
    }
    
    long long msgid = [(NSNumber *)row[0] longLongValue];
    double server_time = pack.head.msgTime / 1000.0;
    NSAssert(server_time > 0, @"Message create Time Must Set 1");
    BOOL update = [self.loginUserDataBase updateRowsInTable:kTableName_Message
                                               onProperties:{CPMessage.toServerState,CPMessage.createTime}
                                                    withRow:@[@(result),@(server_time)]
                                                      where:condition];
    
    if (update == false) {
        return;
    }
    
    cpmsg.msgId = msgid;
    cpmsg.toServerState = result;
    [self asynCallStatusChange:cpmsg];
}


- (void)actionForCacheMsgRsp:(NCProtoNetMsg *)pack {
    
    NCProtoCacheMsgRsp *body = [NCProtoCacheMsgRsp parseFromData:pack.data_p error:nil];
    if (!body) {
        NSLog(@"coremsg-CacheMsgRsp-body-empty");
        return;
    }
    
    uint32_t randId = body.roundId;
    if (randId != self.cacheMsgManager.fetchId) {
        NSLog(@"coremsg-CacheMsgRsp-fetchid-error");
        return;
    }
    
    if (body.msgsArray_Count == 0) {
        NSLog(@"coremsg-CacheMsgRsp-count-0");
        [self.cacheMsgManager setSysMark:YES];
        return;
    }
    NSLog(@"coremsg-CacheMsgRsp-count-OK");

    NSMutableArray<CPMessage *> *arr = NSMutableArray.array;

    for (NCProtoNetMsg *pack in body.msgsArray) {
        CPMessage *tmpMsg;
        if ([pack.name isEqualToString:kMsg_Text]) {
            NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
        }
        else if ([pack.name isEqualToString:kMsg_Audio]) {
            NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
        }
        else if ([pack.name isEqualToString:kMsg_Image]) {
              NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
              tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body];
        }
        
        if (tmpMsg) {
            [arr addObject:tmpMsg];
        }
    }
    
    CPMessage *lastMsg;
    NCProtoNetMsg *lastIn = body.msgsArray.lastObject;
    
    if (lastIn != nil) {
        lastMsg = CPMessage.alloc.init;
        lastMsg.createTime = lastIn.head.msgTime / 1000.0;
        long long sign_hash = (long long)GetHash(nsdata2bytes(lastIn.head.signature));
        lastMsg.signHash = sign_hash;
    }
    

    if (arr.count > 0) {
        [self asynCallCaches:arr];
    }
    
    if (lastMsg) {

        [self.cacheMsgManager handleCacheMsg:lastMsg];

        [self.cacheMsgManager _startFetchCacheMsg];
    }
    

    [self clientReplay:pack];
}


- (void)resendLatest_180s_unsendMsg {

    [self asynWriteTask:^{
        double expect = NSDate.date.timeIntervalSince1970 - 180;
        NSArray* msgArray = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPMessage.class
                                                                           fromTable:kTableName_Message
                                                                               where:CPMessage.createTime > expect && (CPMessage.toServerState == 0 || CPMessage.toServerState == 3)
                                                                             orderBy:CPMessage.msgId.order(WCTOrderedDescending)
                                                                               limit:17];
        
        if (msgArray.count == 0) {
            return;
        }
        
        for (CPMessage *msg in msgArray) {
            [CPSendMsgHelper retrySendMsg:msg.msgId];
        }
    }];
}

- (void)clientReplay:(NCProtoNetMsg *)packin {
    NCProtoNetMsg *replay = CreateClientReplyMsg(packin);
    [self _pbmsgSend:replay];
}

- (CPContact * _Nullable)selectContactByPubkey:(NSString *)contactPubKey {
    CPContact * contact =
    [self.loginUserDataBase getOneObjectOfClass:CPContact.class
                                      fromTable:kTableName_Contact
                                          where:CPContact.publicKey == contactPubKey];
    
    return contact;
}

- (CPContact * _Nullable)create_InsertContactByPubkey:(NSString *)contactPubKey createTime:(double)ctime
{
    CPContact *contact = [CPContact new];
    
    NSString *pubkey_ = contactPubKey;
    contact.publicKey = pubkey_;
    contact.remark = [pubkey_ substringToIndex:12];
    
    contact.sessionType = SessionTypeP2P;
    contact.createTime = ctime;
    
    contact.isAutoIncrement = YES;
    BOOL update = [self.loginUserDataBase insertObject:contact into:kTableName_Contact];
    if (update == NO) {
        NSLog(@">> error >> insert contact db");
        return nil;
    }
    contact.sessionId = contact.lastInsertedRowID;
    return contact;
}

- (CPMessage * _Nullable)selectMsgBySendPubkey:(NSString *)sendPubkey
                                      toPubkey:(NSString *)toPubkey
                                      signHash:(unsigned long long)signHash
{
    WCTCondition condition =
    CPMessage.senderPubKey == sendPubkey &&
    CPMessage.toPubkey == toPubkey &&
    CPMessage.signHash == signHash;
    
    CPMessage *row =
    [self.loginUserDataBase getOneObjectOfClass:CPMessage.class
                                      fromTable:kTableName_Message
                                          where:condition];
    
    return row;
}

- (CPSession *_Nullable)selectSessionBySessionId:(int)sid {
    CPSession *haved =
    [self.loginUserDataBase getOneObjectOfClass:CPSession.class
                                      fromTable:kTableName_Session
                                          where:CPSession.sessionId == sid];
    return haved;
}

- (CPSession *_Nullable)create_InsertSession:(int)sessionId
                                        type:(SessionType)sessionType
                                   lastMsgId:(long long)lastMsgId
                                       ctime:(double)createTime
                                       utime:(double)updateTime
{
    CPSession *session = [CPSession new];
    session.sessionId = sessionId;
    session.sessionType = sessionType;
    session.lastMsgId = lastMsgId;
    session.createTime = createTime;
    session.updateTime = updateTime;
    BOOL res = [self.loginUserDataBase insertObject:session into:kTableName_Session];
    return res ? session : nil;
}







- (void)asynCallBackMsg:(CPMessage *)msg {
    [self asynDoTask:^{
        for (id<ChatInterface> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onReceiveMsg:)]) {
                [face onReceiveMsg:msg];
            }
        }
    }];
}
- (void)asynCallStatusChange:(CPMessage *)msg {
    [self asynDoTask:^{
        for (id<ChatInterface> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onMsgSendStateChange:)]) {
                [face onMsgSendStateChange:msg];
            }
        }
    }];
}

- (void)asynCallCaches:(NSArray<CPMessage *> *)caches {
    [self asynDoTask:^{
        for (id<ChatInterface> face in self.chatDelegates) {
            if (face != nil && [face respondsToSelector:@selector(onCacheMsgRecieve:)]) {
                [face onCacheMsgRecieve:caches];
            }
        }
    }];
}




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
