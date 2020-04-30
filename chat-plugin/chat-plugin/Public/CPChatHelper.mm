







#import "CPChatHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <WCDB/WCDB.h>
#import <WCDB/WCTMultiSelect.h>
#import "CPBridge.h"
#import "MessageObjects.h"
#import "CPSendMsgHelper.h"
#import "CPAccountHelper.h"
#import "CPContactHelper.h"
#include "key_tool.h"

@implementation CPChatHelper

+ (void)sendText:(NSString *)msg
          toUser:(NSString *)pubkey
{
    NSAssert(CPInnerState.shared.chatToPubkey != nil, @"must use setRoomToPubkey 1");
    [CPSendMsgHelper sendMsg:msg toUser:pubkey];
}

+ (void)sendAudioData:(NSData *)data
               toUser:(NSString *)pubkey
{
    [CPSendMsgHelper sendAudioData:data toUser:pubkey];
}

+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey
{
    [CPSendMsgHelper sendImageData:data toUser:pubkey];
}



+ (void)addInterface:(id<ChatDelegate>)delegate
{
    [CPInnerState.shared.chatDelegates addObject:delegate];
}
+ (void)removeInterface:(id<ChatDelegate>)delegate
{
    [CPInnerState.shared.chatDelegates removeObject:delegate];
    
}

+ (void)setRoomToPubkey:(NSString *)topubkey {
    CPInnerState.shared.chatToPubkey = topubkey;
}

+ (void)fakeSendMsg:(CPMessage *)msg complete:(void (^ __nullable)(BOOL success, NSString *msg))complete {
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.msgRecieve storeMessge:msg isCacheMsg:false];
        if (r) {
            [CPInnerState.shared msgAsynCallBack:msg];
        }
        
        if (complete == nil) {
            return;
        }
        [CPInnerState.shared asynDoTask:^{
            complete(r,nil);
        }];
    }];
}


+ (void)sendDeleteMsgAction:(NCProtoDeleteAction)action
                       hash:(int64_t)hash
            relateHexPubkey:(NSString * _Nullable)hexPubkey
                   complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        std::string repubkey = bytesFromHexString(hexPubkey);
        
        NCProtoNetMsg *nt = CreateDeleteCacheMsg(action, hash, repubkey, fromstrpubkey, mySignPrikey);
        
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
    
}


@end



@interface CPChatHelper (ChatRoomInterface)
@end

@implementation CPChatHelper (ChatRoomInterface)
+ (void)retrySendMsg:(long long)msgId
{
    [CPSendMsgHelper retrySendMsg:msgId];
}

+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete
{
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(succss,msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        NSNumber *sHa = [db getOneValueOnResult:CPMessage.signHash fromTable:kTableName_Message where:CPMessage.msgId == msgId];
        int64_t hash = [sHa longLongValue];
        [self sendDeleteMsgAction:NCProtoDeleteAction_DeleteActionHash hash:hash relateHexPubkey:nil complete:^(NSDictionary *response) {
            int code = [response[@"code"] intValue];
            if (code == ChatErrorCodeOK) {
                BOOL r1 = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_Message where:CPMessage.msgId == msgId];
                finalBlock(r1, @"操作结果");
            }
            else {
                finalBlock(false, @"操作结果");
            }
        }];
    }];
}

+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r1 = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Message onProperties:{CPMessage.read,CPMessage.audioRead} withRow:@[@(YES),@(YES)] where:CPMessage.msgId == msgId];
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
    }];
}

+ (void)getMessagesInSession:(NSInteger)sessionId
                  createTime:(double)createTime
                   fromMsgId:(long long)msgId 
                        size:(NSInteger)size 
                    complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete
{
    
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPMessage *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase prepareSelectObjectsOnResults:CPMessage.AllProperties
                                                                                       fromTable:kTableName_Message];
        
        if (msgId == -1 || createTime == -1) {
            array = [[[select where:CPMessage.sessionId == sessionId]
                      
                      orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.msgId.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select where: CPMessage.sessionId == sessionId && CPMessage.createTime <= createTime && CPMessage.msgId < msgId]
                      orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.msgId.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
}



@end
