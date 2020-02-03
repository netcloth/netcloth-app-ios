  
  
  
  
  
  
  

#import "CPSessionHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <WCDB/WCDB.h>
#import <WCDB/WCTMultiSelect.h>
#import "CPBridge.h"
#import "MessageObjects.h"
#import "CPSendMsgHelper.h"
#import "CPAccountHelper.h"
#import "CPContactHelper.h"

@implementation CPSessionHelper

@end


@interface CPSessionHelper (ChatSessionInterface)
@end

@implementation CPSessionHelper (ChatSessionInterface)

+ (void)getOneSessionById:(NSInteger)sessionId
                 complete:(void (^)(BOOL success, NSString *msg, CPSession * _Nullable recentSessions))complete
{
    [CPInnerState.shared asynWriteTask:^{
        CPSession *find =
        [self.db getOneObjectOfClass:CPSession.class
                           fromTable:kTableName_Session
                               where:CPSession.sessionId == sessionId];
        
        if (complete == nil) {
            return;
        }
        [CPInnerState.shared asynDoTask:^{
            complete(find != nil,nil,find);
        }];
    }];
}

  
+ (void)getAllRecentSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete
{
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray *p2ps = [self recentP2PSessions];
        NSArray *groups = [self recentGroupSessions];
        
        NSMutableArray *array = NSMutableArray.array;
        [array addObjectsFromArray:p2ps];
        [array addObjectsFromArray:groups];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    [NSSortDescriptor sortDescriptorWithKey:@"topMark" ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:NO],
                                    nil];
        [array sortUsingDescriptors:sortDescriptors];
        NSArray *orderArray =  array;
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,orderArray);
            }
        }];
    }];
}

+ (NSArray<CPSession *> *)recentP2PSessions {
    WCTCondition p2p =  ((CPSession.sessionType.inTable(kTableName_Session) == SessionTypeP2P) &&
                         (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                         (CPContact.isBlack.inTable(kTableName_Contact) == NO));
    
    
    WCTMultiSelect *p2pSelect = [[self.db prepareSelectMultiObjectsOnResults:{
        CPSession.AllProperties.inTable(kTableName_Session),
        CPContact.AllProperties.inTable(kTableName_Contact),
    } fromTables:@[kTableName_Session, kTableName_Contact]]
                                 
                                 where: p2p
                                 ];
    
    
    WCTMultiObject *multiObject;
    NSMutableArray<CPSession *> *array = @[].mutableCopy;
    while ((multiObject = [p2pSelect nextMultiObject])) {
        CPSession *session = (CPSession *) [multiObject objectForKey:kTableName_Session];
        CPContact *contact = (CPContact *) [multiObject objectForKey:kTableName_Contact];
        CPMessage *message = [self.db getOneObjectOfClass:CPMessage.class
                                                fromTable:kTableName_Message
                                                    where:CPMessage.msgId <= session.lastMsgId && CPMessage.sessionId == session.sessionId
                                                  orderBy:CPMessage.msgId.order(WCTOrderedDescending)];
        
          
        if ([message.senderPubKey isEqualToString:support_account_pubkey]) {
            NSString *content = message.msgDecodeContent;
            if ([content isKindOfClass:NSString.class] && [content isEqualToString:@"Support_Content".localized]) {
                continue;
            }
        }
        
          
        NSNumber *count = [self.db getOneValueOnResult:CPMessage.AnyProperty.count()
                                             fromTable:kTableName_Message
                                                 where:CPMessage.sessionId == session.sessionId && CPMessage.read == NO];
        
        session.unreadCount = count.integerValue;
        session.lastMsg = message;
        session.relateContact = contact;
        [array addObject:session];
    }
    return array;
}

+ (NSArray <CPSession *> *)recentGroupSessions
{
    WCTCondition group =  ((CPSession.sessionType.inTable(kTableName_Session) == SessionTypeGroup) &&
                           (CPSession.lastMsgId.inTable(kTableName_Session) == CPMessage.msgId.inTable(kTableName_GroupMessage)) &&
                           (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                           (CPContact.isBlack.inTable(kTableName_Contact) == NO));
    
    
    WCTMultiSelect *groupSelect = [[self.db prepareSelectMultiObjectsOnResults:{
        CPSession.AllProperties.inTable(kTableName_Session),
        CPMessage.AllProperties.inTable(kTableName_GroupMessage),
        CPContact.AllProperties.inTable(kTableName_Contact),
    } fromTables:@[kTableName_Session,kTableName_GroupMessage, kTableName_Contact]]
                                   
                                   where: group
                                   ];
    
    WCTMultiObject *multiObject;
    NSMutableArray<CPSession *> *array = @[].mutableCopy;
    while ((multiObject = [groupSelect nextMultiObject])) {
        CPSession *session = (CPSession *) [multiObject objectForKey:kTableName_Session];
        CPMessage *message = (CPMessage *) [multiObject objectForKey:kTableName_GroupMessage];
        CPContact *contact = (CPContact *) [multiObject objectForKey:kTableName_Contact];
        
        if (message.msgType <= MessageTypeImage) {
              
            CPGroupMember *findMember =  [self.db getOneObjectOnResults:{CPGroupMember.nickName}
                                                              fromTable:kTableName_GroupMember
                                                                  where:CPGroupMember.sessionId == contact.sessionId &&
                                          CPGroupMember.hexPubkey == message.senderPubKey];
            message.senderRemark = findMember.nickName;
        }
        
        message.isGroupChat = YES;
        
          
        if (message.isDelete != 1) {
            session.lastMsg = message;
        }
        session.relateContact = contact;
        
          
        NSArray *firstMembers =
        [self.db getObjectsOnResults:{CPGroupMember.nickName}
                           fromTable:kTableName_GroupMember
                               where:CPGroupMember.sessionId == contact.sessionId
                             orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)
                               limit:4];
        NSMutableArray *nicks = NSMutableArray.array;
        for (CPGroupMember *member in firstMembers) {
            [nicks addObject:member.nickName];
        }
        session.groupRelateMemberNick = nicks;
        
        
        [array addObject:session];
    }
    return array;
}

  


+ (void)getStrengerAllSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete {
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTMultiSelect *multiSelect = [[self.db prepareSelectMultiObjectsOnResults:{
            CPSession.AllProperties.inTable(kTableName_Session),
            CPMessage.AllProperties.inTable(kTableName_Message),
            CPContact.AllProperties.inTable(kTableName_Contact),
        } fromTables:@[ kTableName_Session, kTableName_Message,kTableName_Contact]]
                                       
                                       where:(CPSession.lastMsgId.inTable(kTableName_Session) == CPMessage.msgId.inTable(kTableName_Message)) && (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                                       CPContact.status == ContactStatusStrange]
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
            
              
            NSNumber *count = [self.db getOneValueOnResult:CPMessage.AnyProperty.count()
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


+ (void)setAllReadOfSession:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL r1 = false;
        if (stype == SessionTypeP2P) {
            r1 = [self.db updateRowsInTable:kTableName_Message
                               onProperties:CPMessage.read
                                    withRow:@[@(YES)]
                                      where:CPMessage.sessionId == sessionId];
        }
        else if (stype == SessionTypeGroup) {
            
            r1 = [self.db updateRowsInTable:kTableName_Session
                               onProperties:CPSession.groupUnreadCount
                                    withRow:@[@(0)]
                                      where:CPSession.sessionId == sessionId];
            
           
            [self.db updateRowsInTable:kTableName_GroupMessage
                          onProperties:CPMessage.isDelete
                               withRow:@[@(0)]
                                 where:CPMessage.sessionId == sessionId && CPMessage.isDelete == 2];
            
            [self.db updateRowsInTable:kTableName_GroupMessage
                          onProperties:CPMessage.read
                               withRow:@[@(true)]
                                 where:CPMessage.sessionId == sessionId && CPMessage.read == false];
        }
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r1,@"操作结果");
            }];
        }
    }];
}

+ (void)setUnReadCount:(NSInteger)count
             ofSession:(NSInteger)sessionId
       withSessionType:(SessionType)stype
              complete:(void (^)(BOOL success, NSString *msg))complete {
    BOOL r1 = false;
    if (stype == SessionTypeGroup) {
        r1 = [self.db updateRowsInTable:kTableName_Session
                           onProperties:CPSession.groupUnreadCount
                                withRow:@[@(count)]
                                  where:CPSession.sessionId == sessionId];
    }
    
    if (complete != nil) {
        [CPInnerState.shared asynDoTask:^{
            complete(r1,@"操作结果");
        }];
    }
}

  
+ (void)deleteSession:(NSInteger)sessionId
             complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [self.db deleteObjectsFromTable:kTableName_Session where:CPSession.sessionId == sessionId];
        
        [self _deleteRelateMsgOfSession:sessionId deleteRemote:true];
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r,@"操作结果");
            }];
        }
    }];
}

+ (void)clearSessionChatsIn:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^ __nullable)(BOOL success, NSString *msg))complete {
    [CPInnerState.shared asynWriteTask:^{
        BOOL r2 = true;
        if (stype == SessionTypeGroup) {
            r2 = [self.db
                  updateRowsInTable:kTableName_GroupMessage
                  onProperties:{CPMessage.isDelete}
                  withRow:@[@(1)]
                  where:CPMessage.sessionId == sessionId && CPMessage.isDelete != 1];
        }
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r2,@"操作结果");
            }];
        }
    }];
}

  
+ (void)deleteSessions:(NSArray<NSNumber *> *)sessionIds
              complete:(void (^)(BOOL success, NSString *msg))complete {
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL r = [self.db deleteObjectsFromTable:kTableName_Session where:CPSession.sessionId.in(sessionIds)];
        
        for (NSNumber *sid in sessionIds) {
            [self _deleteRelateMsgOfSession:sid.integerValue deleteRemote:true];
        }
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r,@"操作结果");
            }];
        }
    }];
    
}

  
+ (void)deleteAllSessionComplete:(void (^)(BOOL success, NSString *msg))complete {
    
    [CPInnerState.shared asynWriteTask:^{
        
          
        NSArray *arrays = [self.db getAllObjectsOfClass:CPSession.class fromTable:kTableName_Session];
        for (CPSession *session in arrays) {
            BOOL r = [self.db deleteObjectsFromTable:kTableName_Session where:CPSession.sessionId == session.sessionId];
            [self _deleteRelateMsgOfSession:session.sessionId deleteRemote:false];
        }
        
        [CPChatHelper sendDeleteMsgAction:NCProtoDeleteAction_DeleteActionAll hash:0 relateHexPubkey:nil complete:nil];
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(true,@"操作结果");
            }];
        }
    }];
}

+ (void)_deleteRelateMsgOfSession:(NSInteger)sessionId deleteRemote:(BOOL)delR {
    CPContact *relateContact =
    [self.db getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.sessionId == sessionId];
    if (relateContact.sessionType == SessionTypeP2P) {
        [self.db deleteObjectsFromTable:kTableName_Message where:CPMessage.sessionId == sessionId];
        if (delR) {
            [CPChatHelper sendDeleteMsgAction:NCProtoDeleteAction_DeleteActionSession hash:0 relateHexPubkey:relateContact.publicKey complete:nil];
        }
    }
    else if (relateContact.sessionType == SessionTypeGroup) {
        [self.db updateRowsInTable:kTableName_GroupMessage onProperties:{CPMessage.isDelete} withRow:@[@(1)] where:CPMessage.sessionId == sessionId && CPMessage.isDelete != 1];
    }
}

  
+ (void)markTopOfSession:(NSInteger)sessionId
                complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        double time = [NSDate.date timeIntervalSince1970];
        BOOL r1 = [self.db updateRowsInTable:kTableName_Session
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
        BOOL r1 = [self.db updateRowsInTable:kTableName_Session
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

  
+ (WCTDatabase *)db {
    return CPInnerState.shared.loginUserDataBase;
}


@end
