







#import "CPGroupManagerHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <WCDB/WCDB.h>
#import <WCDB/WCTMultiSelect.h>
#import "CPBridge.h"
#import "MessageObjects.h"
#import "CPGroupSendMsgHelper.h"
#import "CPAccountHelper.h"
#import "CPContactHelper.h"
#include <string>
#import <string_tools.h>
#import "key_tool.h"
#import <chat_plugin/chat_plugin-Swift.h>
#import <YYKit/YYKit.h>
#import "CPGroupSendMsgHelper.h"
#import "UserSettings.h"


@implementation CPGroupManagerHelper

+ (void)createNormalGroupByGroupName:(NSString *)groupName
                       ownerNickName:(NSString *)owner_nick_name
                     groupPrivateKey:(NSData *)privateKey
                       groupProgress:(GroupCreateProgress)progress
                       serverAddress:(NSString * _Nullable)serverAddress
                            callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result
{
    
    void (^finalBlock)(BOOL, NSString *, CPContact *) = ^(BOOL succss, NSString *msg, CPContact * _Nullable contact) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, contact);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPContact *ct = CPContact.alloc.init;
        
        std::string pubkey = GetPublicKeyByPrivateKey(nsdata2bytes(privateKey));
        
        ct.publicKey = hexStringFromBytes(pubkey);
        ct.remark = groupName;
        ct.isAutoIncrement = YES;
        ct.status = ContactStatusNormal;
        
        ct.sessionType = SessionTypeGroup;
        [ct setSourcePrivateKey:privateKey];
        [ct setSourceNotice:@""];
        
        if ([[ct encodePrivateKey] length] <= 10) {
            finalBlock(false, @"System error".localized, nil);
            return;
        }
        
        
        ct.groupNodeAddress = serverAddress;
        ct.groupProgress = progress;
        
        NSDate *date = NSDate.date;
        ct.createTime = [date timeIntervalSince1970];
        
        BOOL opereation = YES;
        NSString *reason = NSLocalizedString(@"Added Successfully", nil);
        
        if (![CPInnerState.shared.loginUserDataBase insertObject:ct into:kTableName_Contact]) {
            opereation = NO;
            reason = NSLocalizedString(@"Contact_have_added", nil);
            ct = nil;
        }
        if (opereation) {
            ct.sessionId = ct.lastInsertedRowID;
            NSInteger loginUid = CPInnerState.shared.loginUser.userId;
            [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
        }
        
        finalBlock(opereation, reason, ct);
    }];
}

+ (void)joinGroupByGroupName:(NSString *)groupName
             groupPrivateKey:(NSData *)privateKey
                 groupNotice:(NSString * _Nullable)encNotice
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result{
    
    void (^finalBlock)(BOOL, NSString *, CPContact *) = ^(BOOL succss, NSString *msg, CPContact * _Nullable contact) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, contact);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPContact *ct = CPContact.alloc.init;
        
        std::string pubkey = GetPublicKeyByPrivateKey(nsdata2bytes(privateKey));
        NSString *hexPub = hexStringFromBytes(pubkey);
        ct.publicKey = hexPub;
        ct.remark = groupName;
        ct.isAutoIncrement = YES;
        ct.status = ContactStatusNormal;
        
        ct.sessionType = SessionTypeGroup;
        [ct setSourcePrivateKey:privateKey];
        ct.notice_encrypt_content = encNotice;
        
        if ([[ct encodePrivateKey] length] <= 16 ||
            privateKey.length != kPrivateKeySize) {
            finalBlock(false, @"System error".localized, nil);
            return;
        }
        
        
        
        ct.groupProgress = GroupCreateProgressJoinedOk;
        
        NSDate *date = NSDate.date;
        ct.createTime = [date timeIntervalSince1970];
        
        BOOL success = YES;
        NSString *reason = NSLocalizedString(@"Added Successfully", nil);
        
        NSAssert(ct.decodePrivateKey.length > 0, @"add group prikey key must set");
        
        if ([CPInnerState.shared.loginUserDataBase insertObject:ct into:kTableName_Contact] == false) {
            success = NO;
            reason = NSLocalizedString(@"Contact_have_added", nil);
            success = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                                  onProperties:{CPContact.groupProgress} withRow:@[@(GroupCreateProgressJoinedOk)]
                                                                         where:CPContact.publicKey == hexPub];
            if (success) {
                CPContact *find =
                [CPInnerState.shared.loginUserDataBase getOneObjectOnResults:{CPContact.sessionId} fromTable:kTableName_Contact where:CPContact.publicKey == hexPub];
                ct.sessionId = find.sessionId;
            } else {
                ct = nil;
            }
            
        }
        else {
            ct.sessionId = ct.lastInsertedRowID;
            NSInteger loginUid = CPInnerState.shared.loginUser.userId;
            [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
        }
        
        finalBlock(success, reason, ct);
    }];
}



+ (void)updateGroupModifyTime:(int64_t)modifyTime
                     byPubkey:(NSString *)pubkey
                     callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r =
        [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                    onProperties:{CPContact.modifiedTime}
                                                         withRow:@[@(modifyTime)]
                                                           where:CPContact.publicKey == pubkey];
        finalBlock(r, nil);
    }];
}

+ (void)updateGroupProgress:(GroupCreateProgress)progress
                 orIpalHash:(NSString * _Nullable)txhash
                   byPubkey:(NSString *)publicKey
                   callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res;
        if ([NSString cp_isEmpty:txhash]) {
            res = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                              onProperties:{CPContact.groupProgress}
                                                                   withRow:@[@(progress)]
                                                                     where:CPContact.publicKey == publicKey];
        } else {
            res = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                              onProperties:{CPContact.groupProgress,CPContact.txhash}
                                                                   withRow:@[@(progress), txhash]
                                                                     where:CPContact.publicKey == publicKey];
        }
        
        
        
        NSString *reason = @"Update Successfully".localized;
        if (res == false) {
            reason = @"System error".localized;
        }
        
        if (res) {
            CPContact *find =
            [CPInnerState.shared.groupContactCache getObjectBy:^BOOL(CPContact * ct) {
                if ([ct.publicKey isEqualToString:publicKey]) {
                    return YES;
                }
                return false;
            }];
            if (find) {
                find.groupProgress = progress;
            }
        }
        
        finalBlock(res, reason);
    }];
}

+ (void)requestServerGroupInfo:(NSString *)groupPubkey
                      callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupInfoResp * _Nullable info))result {
    
    void (^finalBlock)(BOOL, NSString *, CPGroupInfoResp *) = ^(BOOL succss, NSString *msg, CPGroupInfoResp * info) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, info);
            }];
        }
    };
    
    NSString *url = [CPNetURL.getGroupInfo stringByReplacingOccurrencesOfString:@"{pub_key}" withString:groupPubkey];
    [CPNetWork requestUrlWithPath:url method:@"GET" para:nil complete:^(BOOL r, NSDictionary* _Nullable data) {
        if (r && [data isKindOfClass:NSDictionary.class]) {
            NSDictionary *group = data[@"group"];
            int result = [data[@"result"] intValue];
            if (result != ChatErrorCodeOK) {
                
                finalBlock(false, nil, nil);
                return;
            }
            CPGroupInfoResp *info = [CPGroupInfoResp modelWithJSON:group];
            finalBlock (info != nil, nil, info);
        }
        else if ([data isKindOfClass:NSDictionary.class]) {
            CPGroupInfoResp *info = CPGroupInfoResp.alloc.init;
            info.resultCode = [data[@"result"] intValue];
            finalBlock(false, nil, info);
        }
        else {
            finalBlock(false, nil, nil);
        }
    }];
}

+ (void)updateGroupName:(NSString *)name
          byGroupPubkey:(NSString *)hexpubkey
               callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                             onProperties:CPContact.remark
                                                                  withRow:@[name]
                                                                    where:CPContact.publicKey == hexpubkey];
        
        finalBlock(r, nil);
    }];
    
}

+ (void)updateGroupNotice:(NSString *)encNotice
               modifyTime:(NSTimeInterval)changeTime
                publisher:(NSString *)changerHexPubkey
            byGroupPubkey:(NSString *)hexpubkey
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                             onProperties:
                  {CPContact.notice_encrypt_content,CPContact.notice_modified_time, CPContact.notice_publisher}
                                                                  withRow:@[encNotice,@(changeTime),changerHexPubkey]
                                                                    where:CPContact.publicKey == hexpubkey];
        
        finalBlock(r, nil);
    }];
}

+ (void)updateGroupMyAlias:(NSString *)nickname
             byGroupPubkey:(NSString *)hexpubkey
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        NSString *mePubkey = CPAccountHelper.loginUser.publicKey;
        
        [self updateMemberNickName:nickname memberHexPubkey:mePubkey byGroupPubkey:hexpubkey callback:^(BOOL succss, NSString * _Nonnull msg) {
            finalBlock(succss, msg);
        }];
    }];
}


+ (void)updateMemberNickName:(NSString *)nickname
             memberHexPubkey:(NSString *)memberPubkey
               byGroupPubkey:(NSString *)hexpubkey
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        
        CPContact *ct = [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.publicKey == hexpubkey];
        if (ct.sessionId <= 0) {
            finalBlock(false,nil);
            return;
        }
        
        BOOL r = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_GroupMember
                                                             onProperties:CPGroupMember.nickName
                                                                  withRow:@[nickname]
                                                                    where:CPGroupMember.sessionId == ct.sessionId &&
                  CPGroupMember.hexPubkey == memberPubkey];
        
        finalBlock(r, nil);
    }];
    
}

+ (void)updateGroupInviteType:(int)type
                byGroupPubkey:(NSString *)hexpubkey
                     callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                             onProperties:CPContact.inviteType
                                                                  withRow:@[@(type)]
                                                                    where:CPContact.publicKey == hexpubkey];
        
        finalBlock(r, nil);
    }];
    
}


+ (void)getGroupNotifyPreviewSessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupNotifyPreview * _Nullable notify))result {
    
    void (^finalBlock)(BOOL, NSString *, CPGroupNotifyPreview *) = ^(BOOL succss, NSString *msg, CPGroupNotifyPreview *notify) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, notify);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPGroupNotifyPreview *notifys = CPGroupNotifyPreview.alloc.init;
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        
        
        NSTimeInterval _start =  [NSDate.date timeIntervalSince1970] - 259200;
        NSNumber *unReadCount = [db getOneValueOnResult:CPGroupNotify.AnyProperty.count()
                                              fromTable:kTableName_GroupNotify
                                                  where:(CPGroupNotify.status == DMNotifyStatusUnread) && (CPGroupNotify.createTime >= _start)];
        
        NSNumber *readCount = [db getOneValueOnResult:CPGroupNotify.AnyProperty.count()
                                            fromTable:kTableName_GroupNotify
                                                where:(CPGroupNotify.status == DMNotifyStatusRead) && (CPGroupNotify.createTime >= _start)];
        
        notifys.unreadCount = unReadCount.integerValue;
        notifys.readCount = readCount.integerValue;
        
        
        CPGroupNotify *latestMsg = [db getOneObjectOfClass:CPGroupNotify.class
                                                 fromTable:kTableName_GroupNotify
                                                     where:((CPGroupNotify.status == DMNotifyStatusUnread) || (CPGroupNotify.status == DMNotifyStatusRead)) && (CPGroupNotify.createTime >= _start)
                                                   orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)];
        notifys.lastNotice = latestMsg;
        
        finalBlock(YES,nil, notifys);
    }];
}


+ (void)getDistinctGroupNotifySessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotifySession *>* notifys))result
{
    void (^finalBlock)(BOOL, NSString *, NSArray *) = ^(BOOL succss, NSString *msg, NSArray *array) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, array);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        
        
        NSArray<NSNumber *> * sessionIds =
        [db getOneDistinctColumnOnResult:CPGroupNotify.sessionId
                               fromTable:kTableName_GroupNotify
                                 orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)];
        
        
        NSMutableArray *array = NSMutableArray.array;
        for (NSNumber *sid in sessionIds) {
            int sessionId = sid.intValue;
            
            CPContact *group = [db getOneObjectOfClass:CPContact.class
                                             fromTable:kTableName_Contact
                                                 where:CPContact.sessionId == sessionId && CPContact.sessionType == SessionTypeGroup];
            if (group == nil) {
                continue;
            }
            
            CPGroupNotifySession *notifys = CPGroupNotifySession.alloc.init;
            notifys.sessionId = sessionId;
            notifys.relateContact = group;
            
            
            NSArray *firstMembers =
            [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPGroupMember.class
                                                             fromTable:kTableName_GroupMember
                                                                 where:CPGroupMember.sessionId == sessionId
                                                               orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)
                                                                 limit:4];
            
            notifys.groupRelateMember = firstMembers;
            
            
            NSTimeInterval _start =  [NSDate.date timeIntervalSince1970] - 259200;
            NSNumber *count = [db getOneValueOnResult:CPGroupNotify.AnyProperty.count()
                                            fromTable:kTableName_GroupNotify
                                                where:CPGroupNotify.sessionId == sessionId &&
                               CPGroupNotify.status == DMNotifyStatusUnread &&
                               CPGroupNotify.createTime >= _start];
            
            notifys.unreadCount = count.integerValue;
            
            
            CPGroupNotify *latestMsg = [db getOneObjectOfClass:CPGroupNotify.class
                                                     fromTable:kTableName_GroupNotify
                                                         where:CPGroupNotify.sessionId == sessionId
                                                       orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)];
            notifys.lastNotice = latestMsg;
            
            [self filterNotifyStatus:latestMsg];
            
            [array addObject:notifys];
        }
        
        
        [self sortNotifySessionArray:array];
        finalBlock(true, nil, array);
    }];
}





+ (void)getGroupDistinctSenderOfLatestNotifyInSession:(int)sessionId
                                             callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result {
    
    void (^finalBlock)(BOOL, NSString *, NSArray *) = ^(BOOL succss, NSString *msg, NSArray *array) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, array);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        
        
        NSArray<NSString *> * sendersHex =
        [db getOneDistinctColumnOnResult:CPGroupNotify.senderPublicKey
                               fromTable:kTableName_GroupNotify
                                   where:CPGroupNotify.sessionId == sessionId
                                 orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)];
        
        NSMutableArray<CPGroupNotify *> *array = NSMutableArray.array;
        for (NSString *senderPubKey in sendersHex) {
            
            CPGroupNotify *latestMsg = [db getOneObjectOfClass:CPGroupNotify.class
                                                     fromTable:kTableName_GroupNotify
                                                         where:CPGroupNotify.sessionId == sessionId && CPGroupNotify.senderPublicKey == senderPubKey
                                                       orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)];
            if (latestMsg != nil) {
                [self filterNotifyStatus:latestMsg];
                [array addObject:latestMsg];
            }
        }
        
        [self sortNotifyArray:array];
        finalBlock(true, nil, array);
    }];
}


+ (void)getGroupNotifyInSession:(int)sessionId
                  ofRequestUser:(NSString *)hexPubkey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result {
    
    void (^finalBlock)(BOOL, NSString *, NSArray *) = ^(BOOL succss, NSString *msg, NSArray *array) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, array);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        
        NSMutableArray *array =
        [db getObjectsOfClass:CPGroupNotify.class
                    fromTable:kTableName_GroupNotify
                        where:CPGroupNotify.sessionId == sessionId &&
         CPGroupNotify.senderPublicKey == hexPubkey
                      orderBy:CPGroupNotify.createTime.order(WCTOrderedDescending)
                        limit:3];
        
        for (CPGroupNotify *item in array) {
            [self filterNotifyStatus:item];
        }
        
        finalBlock(true, nil, array);
    }];
}


+ (void)filterNotifyStatus:(CPGroupNotify *)notice {
    if (notice.status == DMNotifyStatusUnread ||
        notice.status == DMNotifyStatusRead) {
        NSTimeInterval now = [NSDate.date timeIntervalSince1970];
        double diff = fabs(now - notice.createTime);
        if (diff > 259200) { 
            notice.status = DMNotifyStatusExpired;
        }
    }
}

+ (void)sortNotifySessionArray:(NSMutableArray<CPGroupNotifySession *> *)array {
    [array sortUsingComparator:^NSComparisonResult(CPGroupNotifySession *  _Nonnull obj1, CPGroupNotifySession *  _Nonnull obj2) {
        return [self sortNotice:obj1.lastNotice obj2:obj2.lastNotice];
    }];
}

+ (NSComparisonResult)sortNotice:(CPGroupNotify * _Nonnull)obj1 obj2:(CPGroupNotify * _Nonnull)obj2 {
    if (obj1.status == DMNotifyStatusUnread) {
        if (obj2.status == DMNotifyStatusUnread) {
            if (obj1.createTime >= obj2.createTime) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        return NSOrderedAscending;
    }
    else if (obj1.status == DMNotifyStatusRead) {
        if (obj2.status == DMNotifyStatusUnread) {
            return NSOrderedDescending;
        }
        else if (obj2.status == DMNotifyStatusRead) {
            if (obj1.createTime >= obj2.createTime) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        return NSOrderedAscending;
    }
    else if (obj1.createTime >= obj2.createTime) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedDescending;
    }
}

+ (void)sortNotifyArray:(NSMutableArray<CPGroupNotify *> *)array {
    [array sortUsingComparator:^NSComparisonResult(CPGroupNotify *  _Nonnull obj1, CPGroupNotify *  _Nonnull obj2) {
        return [self sortNotice:obj1 obj2:obj2];
    }];
}

+ (void)updateGroupNotifyInSession:(int)sessionId
                     ofRequestUser:(NSString *)hexPubkey
                          toStatus:(DMNotifyStatus)status
                          callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        BOOL r = [db updateRowsInTable:kTableName_GroupNotify
                          onProperties:{CPGroupNotify.status}
                               withRow:@[@(status)]
                                 where:CPGroupNotify.sessionId == sessionId &&
                  CPGroupNotify.senderPublicKey == hexPubkey];
        
        
        finalBlock(r, nil);
    }];
}

+ (void)updateGroupNotifyToReadInSession:(int)sessionId
                   whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        BOOL r = [db updateRowsInTable:kTableName_GroupNotify
                          onProperties:{CPGroupNotify.status}
                               withRow:@[@(DMNotifyStatusRead)]
                                 where:CPGroupNotify.sessionId == sessionId &&
                  CPGroupNotify.status == DMNotifyStatusUnread];
        finalBlock(r, nil);
    }];
}


+ (void)updateGroupNotifyToReadInNoticeId:(int64_t)noticeId
                    whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        WCTDatabase *db = CPInnerState.shared.loginUserDataBase;
        
        CPGroupNotify *find =
        [db getOneObjectOfClass:CPGroupNotify.class
                      fromTable:kTableName_GroupNotify
                          where:CPGroupNotify.noticeId == noticeId &&
         CPGroupNotify.status == DMNotifyStatusUnread];
        
        if (find == nil) {
            finalBlock(false, nil);
        }
        else {
            
            BOOL r = [db updateRowsInTable:kTableName_GroupNotify
            onProperties:{CPGroupNotify.status}
                 withRow:@[@(DMNotifyStatusRead)]
                   where:CPGroupNotify.noticeId == noticeId &&
                   CPGroupNotify.status == DMNotifyStatusUnread];
            finalBlock(r, nil);
        }
    }];
}



+ (void)insertOrReplaceGroupAllMember:(NSArray<CPGroupMember *> *)member
                             callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    NSAssert(member.count > 0, @"update must not null 1");
    
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *mDic = @{}.mutableCopy;
        NSMutableArray *subArr;
        for (CPGroupMember *item in member) {
            NSAssert(item.sessionId > 0, @"session id must set 1");
            NSString *key = @(item.sessionId).stringValue;
            subArr = mDic[key];
            if (subArr == nil) {
                subArr = @[].mutableCopy;
                [subArr addObject:item];
                mDic[key] = subArr;
            } else {
                [subArr addObject:item];
            }
        }
        
        dispatch_group_t group = dispatch_group_create();
        NSInteger count = mDic.count;
        __block NSInteger sucCount = 0;
        [mDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            dispatch_group_enter(group);
            [self insertOrReplaceOneGroupAllMember:obj callback:^(BOOL succss, NSString * _Nonnull msg) {
                if (succss == true) {
                    sucCount += 1;
                }
                dispatch_group_leave(group);
            }];
        }];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            finalBlock(count == sucCount, nil);
        });
    });
}

+ (void)insertOrReplaceOneGroupAllMember:(NSArray<CPGroupMember *> *)member
                                callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    NSAssert(member.count > 0, @"update must not null 2");
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        NSInteger sessionId = member.firstObject.sessionId;
        
        int64_t lastAddTime = 0;
        NSMutableArray *toAddhexPubkeys = @[].mutableCopy;
        for (CPGroupMember *item in member) {
            NSAssert(item.sessionId > 0, @"session id must set 2");
            [toAddhexPubkeys addObject:item.hexPubkey];
            lastAddTime = MAX(lastAddTime, item.join_time);
        }
        
        NSMutableSet *toadd = [NSMutableSet setWithArray:toAddhexPubkeys];
        
        
        NSArray *oneAlls = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPGroupMember.class
                                                                          fromTable:kTableName_GroupMember
                                                                              where:CPGroupMember.sessionId == sessionId && CPGroupMember.join_time <= lastAddTime];
        
        NSMutableArray *oneAllsHexPubkey = @[].mutableCopy;
        for (CPGroupMember *item in oneAlls) {
            [oneAllsHexPubkey addObject:item.hexPubkey];
        }
        NSMutableSet *old = [NSMutableSet setWithArray:oneAllsHexPubkey];
        
        [old minusSet:toadd];
        
        
        BOOL del = YES;
        if (old.count) {
            NSInteger sessionId = member[0].sessionId;
            NSArray *deltes = old.allObjects;
            del = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_GroupMember
                                                                          where:CPGroupMember.hexPubkey.in(deltes) &&
                   CPGroupMember.sessionId == sessionId];
        }
        
        BOOL r = [CPInnerState.shared.loginUserDataBase insertOrReplaceObjects:member into:kTableName_GroupMember];
        
        finalBlock(r && del, nil);
    }];
}


+ (void)insertOrReplaceOneGroupMember:(CPGroupMember *)member
                             callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    NSAssert(member.sessionId > 0, @"session id must set 3");
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r =
        [CPInnerState.shared.loginUserDataBase insertOrReplaceObject:member into:kTableName_GroupMember];
        finalBlock(r, nil);
    }];
}

+ (void)deleteOneGroupMember:(NSString *)memberPubkey
                   inSession:(NSInteger)sessionId
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    NSAssert(sessionId > 0, @"session id must set 4");
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r =
        [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_GroupMember
                                                                where:CPGroupMember.hexPubkey == memberPubkey && CPGroupMember.sessionId == sessionId];
        finalBlock(r, nil);
    }];
    
}

+ (void)deleteGroupMembers:(NSArray<NSString *> *)memberPubkeys
                 inSession:(NSInteger)sessionId
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    NSAssert(sessionId > 0, @"session id must set 5");
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_GroupMember
                                                                where:CPGroupMember.hexPubkey.in(memberPubkeys) && CPGroupMember.sessionId == sessionId];
        finalBlock(r, nil);
    }];
}

+ (void)deleteGroupAllMembersInSession:(NSInteger)sessionId
                              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    NSAssert(sessionId > 0, @"session id must set 6");
    void (^finalBlock)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_GroupMember
                                                                where:CPGroupMember.sessionId == sessionId];
        finalBlock(r, nil);
    }];
}


+ (void)getAllMemberListInGroupSession:(NSInteger)sessionId
                              callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray<CPGroupMember *> *memebers))result {
    
    NSAssert(sessionId > 0, @"session id must set 7");
    void (^finalBlock)(BOOL, NSString *, NSArray *) = ^(BOOL succss, NSString *msg, NSArray *members) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, members);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray *array =
        [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPGroupMember.class
                                                       fromTable:kTableName_GroupMember
                                                           where:CPGroupMember.sessionId == sessionId
                                                         orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)];
        
        finalBlock(array != nil, nil,array);
    }];
}

+ (void)getOneGroupMember:(NSString *)memberPubkey
                inSession:(NSInteger)sessionId
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupMember *member))result {
    NSAssert(sessionId > 0, @"session id must set 8");
    void (^finalBlock)(BOOL, NSString *, CPGroupMember *) = ^(BOOL succss, NSString *msg, CPGroupMember *member) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, member);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        CPGroupMember *member  =
        [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPGroupMember.class
                                                         fromTable:kTableName_GroupMember
                                                             where:CPGroupMember.hexPubkey == memberPubkey && CPGroupMember.sessionId == sessionId];
        finalBlock(member.sessionId > 0, nil, member);
    }];
}



+ (void)searchContacts:(NSString *)text
              callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray<CPContact *> * _Nullable contact))result {
    
    NSAssert(text != nil, @"text must set");
    void (^finalBlock)(BOOL, NSString *, NSArray *) = ^(BOOL succss, NSString *msg, NSArray *member) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, member);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        NSString *param = [NSString stringWithFormat:@"%%%@%%",text] ;
        
        NSArray * contacts  =
        [CPInnerState.shared.loginUserDataBase
         getObjectsOfClass:CPContact.class
         fromTable:kTableName_Contact
         where:CPContact.remark.like(param)];
        
        for (CPContact *contact in contacts) {
            if (contact.sessionType == SessionTypeGroup) {
                NSArray *firstMembers =
                [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPGroupMember.class
                                                               fromTable:kTableName_GroupMember
                                                                     where:CPGroupMember.sessionId == contact.sessionId
                                                                   orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)
                                                                     limit:4];
                
                contact.groupRelateMember = firstMembers;
            }
        }
        
        
        finalBlock(YES, nil, contacts);
    }];
    
    
    
}


@end


@interface CPGroupManagerHelper (ChatRoomInterface)
@end

@implementation CPGroupManagerHelper (ChatRoomInterface)

+ (void)retrySendMsg:(long long)msgId
{
    [CPGroupSendMsgHelper retrySendMsg:msgId];
}

+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete
{
    [CPInnerState.shared asynWriteTask:^{
        BOOL r1 = [CPInnerState.shared.loginUserDataBase
                   updateRowsInTable:kTableName_GroupMessage
                   onProperties:{CPMessage.isDelete}
                   withRow:@[@(1)]
                   where:CPMessage.msgId == msgId];
        
        
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
        BOOL r1 = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_GroupMessage onProperties:{CPMessage.read,CPMessage.audioRead} withRow:@[@(YES),@(YES)] where:CPMessage.msgId == msgId];
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
    
    
}


+ (void)queryMessagesInSession:(NSInteger)sessionId
              lessThenServerId:(int64_t)serverId 
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete {
    
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPMessage *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase prepareSelectObjectsOnResults:CPMessage.AllProperties
                                                                                       fromTable:kTableName_GroupMessage];
        
        if (serverId == -1) {
            array = [[[select where:CPMessage.sessionId == sessionId]
                      
                      orderBy:{CPMessage.server_msg_id.order(WCTOrderedDescending),
                CPMessage.msgId.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select where:
                       CPMessage.sessionId == sessionId &&
                       CPMessage.server_msg_id >= serverId - size  &&
                       CPMessage.server_msg_id < serverId]
                      orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.server_msg_id.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        for (CPMessage *item in array) {
            item.isGroupChat = true;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
}



+ (void)v2_queryMessagesInSession:(NSInteger)sessionId
                          beginId:(int64_t)beginId 
                            endId:(int64_t)endid
                            count:(NSInteger)wantCount 
                         complete:(void (^ __nullable)(BOOL needSyn, int realCount, int64_t realBeginId, int64_t realEndId))complete {
    
    int64_t l_beginId = MAX(1, beginId);
    int64_t l_endId = endid;
    NSInteger l_count = wantCount;
    NSAssert(l_endId >= l_beginId, @"Must >");
    
    if (l_beginId > l_endId || l_count <= 0) {
        
        NSLog(@"syn group message error query bid %lld eid %lld", beginId, endid);
        if (complete) {
            complete(false, 0, l_beginId, l_endId);
        }
        return;
    }
    else if (l_beginId == l_endId) {
        l_endId += 1;
    }
    
    NSInteger size = l_endId - l_beginId;
    size = MIN(size, l_count); 
    
    
    l_beginId = l_endId - size; 
    
    
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPMessage *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase prepareSelectObjectsOnResults:CPMessage.AllProperties
                                                                                       fromTable:kTableName_GroupMessage];
        array = [[[select where:
                   CPMessage.sessionId == sessionId &&
                   CPMessage.server_msg_id >= l_beginId  &&
                   CPMessage.server_msg_id < l_endId]
                  orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
            CPMessage.server_msg_id.order(WCTOrderedDescending)}] limit:size] .allObjects;
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(array.count != size, size, l_beginId, l_endId);
            }
        }];
    }];
    
}

+ (void)V2GetMessagesInSession:(NSInteger)sessionId
              beforeCreateTime:(double)createTime
                beforeServerId:(long long)serverMsgId 
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success,
                                         NSString *msg,
                                         NSArray<CPMessage *> * _Nullable recentSessions,
                                         long long firstReadServerMsgId,
                                         CPMessage * __nullable firstReadMsg, 
                                         CPMessage * __nullable atRelateMsg))complete
{
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSMutableArray <CPMessage *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase prepareSelectObjectsOnResults:CPMessage.AllProperties
                                                                                       fromTable:kTableName_GroupMessage];
        
        CPMessage *atMsg = nil;
        long long firstId = 0;
        CPMessage *firstReadMsg = nil;
        if (serverMsgId == -1 || createTime == -1) {
            array = [[[select where:CPMessage.sessionId == sessionId &&
                       CPMessage.isDelete != 1]
                      
                      orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.server_msg_id.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
            
            
            CPMessage *readMsg =
            [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPMessage.class
                                                             fromTable:kTableName_GroupMessage
                                                                 where:CPMessage.sessionId == sessionId
             && (CPMessage.isDelete != 2 && CPMessage.isDelete != 1)
             && CPMessage.read == YES
                                                               orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.server_msg_id.order(WCTOrderedDescending)}];
            
            readMsg.isGroupChat = YES;
            firstId = readMsg.server_msg_id;
            firstReadMsg = readMsg;
            
            
            
            NSArray *msgs = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPMessage.class
                                                                   fromTable:kTableName_GroupMessage
                                                                       where:CPMessage.sessionId == sessionId
                             && (CPMessage.isDelete != 2 && CPMessage.isDelete != 1)
                             && CPMessage.read == false
                             && (CPMessage.useway == MessageUseWayAtMe || CPMessage.useway == MessageUseWayAtAll)
                             && (CPMessage.server_msg_id > firstId)
                     
                     orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                     CPMessage.server_msg_id.order(WCTOrderedDescending)}
                             limit:30
                     ];
            
            atMsg = msgs.lastObject;
            atMsg.isGroupChat = true;
            
            
            if (atMsg != nil) {
                NSArray *unreadMsgArray = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPMessage.class
                                                                fromTable:kTableName_GroupMessage
                                                                    where:CPMessage.sessionId == sessionId
                && (CPMessage.isDelete != 2 && CPMessage.isDelete != 1)
                && (CPMessage.server_msg_id > firstId && CPMessage.server_msg_id < atMsg.server_msg_id)
                                            && CPMessage.read == false
                                                                  orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                   CPMessage.server_msg_id.order(WCTOrderedDescending)} limit:10];
                
                
                if (array == nil || array.count == 0) {
                    array = NSMutableArray.array;
                }
                for (CPMessage *item in unreadMsgArray) {
                    item.isDelete = 10; 
                }
                [array insertObjects:unreadMsgArray atIndex:0];
            }
        }
        else {
            
            array = [[[select where: CPMessage.sessionId == sessionId &&
                       CPMessage.createTime <= createTime &&
                       CPMessage.server_msg_id < serverMsgId &&
                       CPMessage.isDelete != 1]
                      orderBy:{CPMessage.createTime.order(WCTOrderedDescending),
                CPMessage.msgId.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        for (CPMessage *item in array) {
            item.isGroupChat = true;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array, firstId,firstReadMsg,atMsg);
            }
        }];
    }];
    
}

@end
