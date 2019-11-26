







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

@implementation CPChatHelper

+ (void)sendText:(NSString *)msg
          toUser:(NSString *)pubkey
{
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



+ (void)addInterface:(id<ChatInterface>)delegate
{
    [CPInnerState.shared.chatDelegates addObject:delegate];
}
+ (void)removeInterface:(id<ChatInterface>)delegate
{
    [CPInnerState.shared.chatDelegates removeObject:delegate];

}

+ (void)requestOfflineMsg
{

}

+ (void)setRoomToPubkey:(NSString *)topubkey {
    CPInnerState.shared.chatToPubkey = topubkey;
}


@end


@interface CPChatHelper (DB)

@end

@implementation CPChatHelper (DB)

+ (void)getAllRecentSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete
{
    [CPInnerState.shared asynWriteTask:^{
        
        WCTMultiSelect *multiSelect = [[CPInnerState.shared.loginUserDataBase prepareSelectMultiObjectsOnResults:{
            CPSession.AllProperties.inTable(kTableName_Session),
            CPMessage.AllProperties.inTable(kTableName_Message),
            CPContact.AllProperties.inTable(kTableName_Contact),
        } fromTables:@[ kTableName_Session, kTableName_Message,kTableName_Contact]]
                                        
                                        where:(CPSession.lastMsgId.inTable(kTableName_Session) == CPMessage.msgId.inTable(kTableName_Message)) && (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                                       CPContact.isBlack == NO]
                                       ;
        
        
        WCTMultiObject *multiObject;
        NSMutableArray<CPSession *> *array = @[].mutableCopy;
        while ((multiObject = [multiSelect nextMultiObject])) {
            CPSession *session = (CPSession *) [multiObject objectForKey:kTableName_Session];
            CPMessage *message = (CPMessage *) [multiObject objectForKey:kTableName_Message];
            CPContact *contact = (CPContact *) [multiObject objectForKey:kTableName_Contact];
            

            if ([message.senderPubKey isEqualToString:support_account_pubkey]) {
                NSString *content = message.msgDecodeContent;
                if ([content isKindOfClass:NSString.class] && [content isEqualToString:@"Support_Content".localized]) {
                    continue;
                }
            }
            

            NSNumber *count = [CPInnerState.shared.loginUserDataBase getOneValueOnResult:CPMessage.AnyProperty.count()
                                                                               fromTable:kTableName_Message
                                                                                   where:CPMessage.sessionId == session.sessionId && CPMessage.read == NO];
            
            session.unreadCount = count.integerValue;
            session.lastMsg = message;
            session.relateContact = contact;
            [array addObject:session];
        }
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    [NSSortDescriptor sortDescriptorWithKey:@"topMark" ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:NO],nil];
        [array sortUsingDescriptors:sortDescriptors];
        NSArray *orderArray =  array;
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,orderArray);
            }
        }];
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


+ (void)setAllReadOfSession:(NSInteger)sessionId
                   complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r1 = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Message onProperties:CPMessage.read withRow:@[@(YES)] where:CPMessage.sessionId == sessionId];
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
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

+ (void)deleteSession:(NSInteger)sessionId
             complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_Session where:CPSession.sessionId == sessionId];
        
        BOOL r1 = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_Message where:CPMessage.sessionId == sessionId];
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r && r1,@"操作结果");
            }];
        }
    }];
}

+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r1 = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_Message where:CPMessage.msgId == msgId];
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
    }];
}

+ (void)markTopOfSession:(NSInteger)sessionId
                complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        double time = [NSDate.date timeIntervalSince1970];
        BOOL r1 = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Session
                                                              onProperties:{CPSession.topMark, CPSession.updateTime}
                                                                   withRow:@[@(1),@(time)]
                                                                     where:CPSession.sessionId == sessionId];
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
    }];
}

+ (void)unTopOfSession:(NSInteger)sessionId
              complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        double time = [NSDate.date timeIntervalSince1970];
        BOOL r1 = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Session
                                                              onProperties:{CPSession.topMark, CPSession.updateTime}
                                                                   withRow:@[@(0),@(time)]
                                                                     where:CPSession.sessionId == sessionId];
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
    }];
}


+ (void)retrySendMsg:(long long)msgId
{
    [CPSendMsgHelper retrySendMsg:msgId];
}

@end
