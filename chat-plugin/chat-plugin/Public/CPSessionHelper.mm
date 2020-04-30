//
//  CPSessionHelper.m
//  chat-plugin
//
//  Created by Grand on 2019/12/11.
//  Copyright © 2019 netcloth. All rights reserved.
//

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
#import <chat_plugin/chat_plugin-Swift.h>
#import <YYKit/YYKit.h>

@implementation CPSessionHelper

//MARK:- Getter
+ (WCTDatabase *)db {
    return CPInnerState.shared.loginUserDataBase;
}


+ (void)requestRecommendedGroupInServerNodeComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPRecommendedGroup *> * _Nullable recommendGroup))complete {
    
    void (^finalBlock)(BOOL, NSString *, NSArray<CPRecommendedGroup *> * ) = ^(BOOL succss, NSString *msg, NSArray<CPRecommendedGroup *> * info) {
        if (complete) {
            [CPInnerState.shared asynDoTask:^{
                complete(succss, msg, info);
            }];
        }
    };
    
    NSString *url = CPNetURL.getRecommendationGroup;
    [CPNetWork requestUrlWithPath:url method:@"GET" para:nil complete:^(BOOL r, NSDictionary* _Nullable data) {
        if (r && [data isKindOfClass:NSDictionary.class]
            && [data[@"recommendations"] isKindOfClass:NSArray.class]) {
            NSArray *info = [NSArray modelArrayWithClass:CPRecommendedGroup.class json:data[@"recommendations"]];
            finalBlock (info != nil, nil, info);
        }
        else {
            finalBlock(false, nil, nil);
        }
    }];
}

//fake recommend group only once
+ (void)fakeAddRecommendedGroupSession {
    CPSession *fake = CPSession.alloc.init;
    fake.sessionId = -1; //recommend
    fake.topMark = 1;
    [CPInnerState.shared asynWriteTask:^{
        CPSession *find = [self.db
                   getOneObjectOfClass:CPSession.class
                   fromTable:kTableName_Session
                   where:CPSession.sessionId == -1];
        if (find == nil) {
            [self.db insertObject:fake into:kTableName_Session];
        }
    }];
}

+ (void)fakeUpdateRecommendedGroupSessionCount:(NSInteger)count {
    [CPInnerState.shared asynWriteTask:^{
        [self.db updateRowsInTable:kTableName_Session
                                        onProperties:CPSession.groupUnreadCount
                                             withRow:@[@(count)]
                                               where:CPSession.sessionId == -1];
    }];
}


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

//MARK:- 最新会话
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
        
        //filter msg
        if (message.msgType == MessageTypeAssistTip) {
            continue;
        }
        
        //cal count
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
                           (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                           (CPContact.isBlack.inTable(kTableName_Contact) == NO));
    
    
    WCTMultiSelect *groupSelect = [[self.db prepareSelectMultiObjectsOnResults:{
        CPSession.AllProperties.inTable(kTableName_Session),
        CPContact.AllProperties.inTable(kTableName_Contact),
    } fromTables:@[kTableName_Session, kTableName_Contact]]
                                   where: group
                                   ];
    
    WCTMultiObject *multiObject;
    NSMutableArray<CPSession *> *array = @[].mutableCopy;
    while ((multiObject = [groupSelect nextMultiObject])) {
        CPSession *session = (CPSession *) [multiObject objectForKey:kTableName_Session];
        CPContact *contact = (CPContact *) [multiObject objectForKey:kTableName_Contact];
        
        CPMessage *message = [self.db getOneObjectOfClass:CPMessage.class
                                                fromTable:kTableName_GroupMessage
                                                    where:CPMessage.msgId == session.lastMsgId
                              && CPMessage.sessionId == session.sessionId
                                                  orderBy:CPMessage.msgId.order(WCTOrderedDescending)];
        message.isGroupChat = YES;
        
        if (message != nil && message.msgType <= MessageTypeImage) {
            //get member nick name
            CPGroupMember *findMember =  [self.db getOneObjectOnResults:{CPGroupMember.nickName}
                                                              fromTable:kTableName_GroupMember
                                                                  where:CPGroupMember.sessionId == contact.sessionId &&
                                          CPGroupMember.hexPubkey == message.senderPubKey];
            message.senderRemark = findMember.nickName;
        }

        //filter msg
        if (message != nil && message.isDelete != 1) {
            session.lastMsg = message;
        }
        session.relateContact = contact;
        
        //group members
        NSArray *firstMembers =
        [self.db getObjectsOfClass:CPGroupMember.class
                           fromTable:kTableName_GroupMember
                               where:CPGroupMember.sessionId == contact.sessionId
                             orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)
                               limit:4];
        
        session.groupRelateMember = firstMembers;
        
        // find @ me msg
        int64_t unreadCount = session.groupUnreadCount;
        if (unreadCount > 0) {
            int64_t beginId = session.lastMsg.server_msg_id - unreadCount + 1;
            int64_t endId = session.lastMsg.server_msg_id;

            CPMessage *atMeMsg =
            [self.db getObjectsOfClass:CPMessage.class
                                                     fromTable:kTableName_GroupMessage
                                                         where:CPMessage.sessionId == session.sessionId
                                   && CPMessage.server_msg_id >= beginId
                                   && CPMessage.server_msg_id <= endId
                                   && (CPMessage.useway == MessageUseWayAtMe  ||  CPMessage.useway == MessageUseWayAtAll)

                                                       orderBy:CPMessage.msgId.order(WCTOrderedDescending)
                                  limit:unreadCount].firstObject;
            session.atRelateMsg = atMeMsg;
        }
        
        [array addObject:session];
    }
    return array;
}

//MARK:- 陌生会话
+ (void)getStrengerAllSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete {
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTMultiSelect *multiSelect = [[self.db prepareSelectMultiObjectsOnResults:{
            CPSession.AllProperties.inTable(kTableName_Session),
            CPMessage.AllProperties.inTable(kTableName_Message),
            CPContact.AllProperties.inTable(kTableName_Contact),
        } fromTables:@[ kTableName_Session, kTableName_Message,kTableName_Contact]]
                                       
                                       where:(CPSession.lastMsgId.inTable(kTableName_Session) == CPMessage.msgId.inTable(kTableName_Message)) && (CPSession.sessionId.inTable(kTableName_Session) == CPContact.sessionId.inTable(kTableName_Contact)) &&
                                       (CPContact.status == ContactStatusStrange || CPContact.status == ContactStatusAssistHelper)]
        ;
        
        
        WCTMultiObject *multiObject;
        NSMutableArray<CPSession *> *array = @[].mutableCopy;
        while ((multiObject = [multiSelect nextMultiObject])) {
            CPSession *session = (CPSession *) [multiObject objectForKey:kTableName_Session];
            CPMessage *message = (CPMessage *) [multiObject objectForKey:kTableName_Message];
            CPContact *contact = (CPContact *) [multiObject objectForKey:kTableName_Contact];
            
            //filter msg
            if (message.msgType == MessageTypeAssistTip) {
                continue;
            }
            
            //cal count
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

//MARK:- Set
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

//MARK:-  删除
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
        else if (stype == SessionTypeP2P) {
            [self _deleteRelateMsgOfSession:sessionId deleteRemote:true];
        }
        
        if (complete != nil) {
            [CPInnerState.shared asynDoTask:^{
                complete(r2,@"操作结果");
            }];
        }
    }];
}

//删除陌生人会话
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

//清空所有聊天记录
+ (void)deleteAllSessionComplete:(void (^)(BOOL success, NSString *msg))complete {
    
    [CPInnerState.shared asynWriteTask:^{
        
        //may long time
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

//MARK:-  置顶
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

@end
