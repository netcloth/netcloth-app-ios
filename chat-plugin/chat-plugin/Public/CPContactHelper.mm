







#import "CPContactHelper.h"
#import "CPDataModel+secpri.h"

#import "CPInnerState.h"
#import <YYKit/YYKit.h>

#import "key_tool.h"
#import "string_tools.h"
#import "CPBridge.h"
#import "MessageObjects.h"

#import "UserSettings.h"


NSString * const support_account_pubkey = @"0449b445774c63c28b6019a1aa5913d252f47683409989d15284b347eb1c9f372e87f7f6e95230ef05d36ea9dc8327425433b7cbfc0d8913a769ee2aabfe23b814";
NSString * const do_not_disturb_tag = @"notdisturb";
NSString * const group_tag = @"group";
NSInteger contact_version = 2;

@implementation CPContactHelper

+ (WCTDatabase *)db {
    return CPInnerState.shared.loginUserDataBase;
}

+ (void)addAssistHelperAssist:(CPAssistant *)assist
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result {
    
    void (^block)(BOOL, NSString *, CPContact *) = ^(BOOL succss, NSString *msg, CPContact * _Nullable contact) {
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(succss, msg, contact);
            }];
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        CPContact *contact = [[CPContact alloc] init];
        contact.publicKey = assist.pub_key;
        contact.remark = assist.nick_name;
        contact.sessionType = SessionTypeP2P;
        NSDate *date = NSDate.date;
        contact.createTime = [date timeIntervalSince1970];;
        contact.status = ContactStatusAssistHelper;
        contact.avatar = assist.avatar;
        contact.server_addr = assist.server_addr;
        contact.isAutoIncrement = YES;
        
        CPContact *find = [self.db getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.publicKey == assist.pub_key];
        if (find == nil) {
            BOOL update = [self.db insertObject:contact into:kTableName_Contact];
            if (update == NO) {
                NSLog(@">> error >> insert contact db assist");
                return;
            }
            contact.sessionId = contact.lastInsertedRowID;
            
            
            CPMessage *msg = CPMessage.alloc.init;
            msg.senderPubKey = assist.pub_key;
            msg.toPubkey = CPInnerState.shared.loginUser.publicKey;
            msg.msgType = MessageTypeAssistTip;
            msg.read = YES;
            msg.msgData = [@"Support_Content".localized dataUsingEncoding:NSUTF8StringEncoding];
            
            std::string sign =  nsstring2bytes(NSUUID.UUID.UUIDString);
            long long hash = (long long)GetHash(sign);
            msg.signHash = hash;
            
            [CPInnerState.shared.msgRecieve storeMessge:msg isCacheMsg:false];
        }
        else {
            [self.db updateRowsInTable:kTableName_Contact
                          onProperties:{CPContact.status,CPContact.remark,CPContact.avatar,CPContact.server_addr}
                               withRow:@[@(ContactStatusAssistHelper),assist.nick_name,assist.avatar,assist.server_addr]
                                 where:CPContact.publicKey == assist.pub_key];
        }
        
        block(true, nil ,contact);
    }];
}



+ (void)addContactUser:(NSString *)publicKey
               comment:(NSString *)remark
              callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result {
    
    [self checkContactUser:publicKey comment:remark callback:^(BOOL succss, NSString *msg) {
        
        void (^block)(BOOL, NSString *, CPContact *) = ^(BOOL succss, NSString *msg, CPContact * _Nullable contact) {
            if (result) {
                [CPInnerState.shared asynDoTask:^{
                    result(succss, msg, contact);
                }];
            }
        };
        
        if (!succss) {
            block(NO,nil,nil);
            return;
        }
        
        
        __block BOOL added = NO;
        [self getAllContacts:^(NSArray<CPContact *> * _Nonnull contacts) {
            
            __block CPContact *haved;
            [contacts enumerateObjectsUsingBlock:^(CPContact * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.publicKey isEqualToString:publicKey]) {
                    
                    if (obj.status == ContactStatusStrange) {
                        haved = obj;
                        *stop = YES;
                    } else {
                        added = YES;
                        *stop = YES;
                    }
                }
            }];
            
            if (haved) {
                BOOL opereation = YES;
                NSString *reason = NSLocalizedString(@"Added Successfully", nil);
                haved.remark = remark;
                haved.status = ContactStatusNormal;
                if (![self.db
                      updateRowsInTable:kTableName_Contact
                      onProperties:{CPContact.remark,CPContact.status}
                      withRow:@[remark, @(ContactStatusNormal)]
                      where:CPContact.publicKey == haved.publicKey]) {
                    opereation = NO;
                    reason = NSLocalizedString(@"System error", nil);
                }
                block(opereation, reason, haved);
                if (opereation) {
                    NSInteger loginUid = CPInnerState.shared.loginUser.userId;
                    [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
                }
                return;
            }
            
            
            if (added) {
                block(NO,NSLocalizedString(@"Contact_have_added", nil),nil);
                return;
            }
            
            
            CPContact *ct = CPContact.alloc.init;
            ct.publicKey = publicKey;
            ct.remark = remark;
            ct.isAutoIncrement = YES;
            ct.status = ContactStatusNormal;
            
            NSDate *date = NSDate.date;
            ct.createTime = [date timeIntervalSince1970];
            
            BOOL opereation = YES;
            NSString *reason = NSLocalizedString(@"Added Successfully", nil);
            
            if (![self.db insertObject:ct into:kTableName_Contact]) {
                opereation = NO;
                reason = NSLocalizedString(@"System error", nil);
            }
            if (opereation) {
                ct.sessionId = ct.lastInsertedRowID;
                NSInteger loginUid = CPInnerState.shared.loginUser.userId;
                [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
            }
            block(opereation, reason, ct);
        }];
    }];
}


+ (void)getAllContacts:(void (^)(NSArray <CPContact *> * contacts))result {
    [CPInnerState.shared asynWriteTask:^{
        NSArray *carray =  [self.db getAllObjectsOfClass:CPContact.class fromTable:kTableName_Contact];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(carray);
            }];
        }
    }];
}

+ (void)getNormalContacts:(void (^)(NSArray <CPContact *> * contacts))result
{
    [CPInnerState.shared asynWriteTask:^{
        NSArray *carray =  [self.db getObjectsOfClass:CPContact.class
                                                                          fromTable:kTableName_Contact
                                                                              where:
                            CPContact.sessionType == SessionTypeP2P && CPContact.isBlack == NO];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(carray);
            }];
        }
    }];
}

+ (void)getBlackListContacts:(void (^)(NSArray <CPContact *> * contacts))result
{
    [CPInnerState.shared asynWriteTask:^{
        NSArray *carray =  [self.db
                            getObjectsOfClass:CPContact.class
                            fromTable:kTableName_Contact
                            where:CPContact.sessionType == SessionTypeP2P && CPContact.isBlack == YES];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(carray);
            }];
        }
    }];
}


+ (void)getGroupListContacts:(void (^)(NSArray <CPContact *> * contacts))result {
    [CPInnerState.shared asynWriteTask:^{
        NSArray *carray =  [self.db
                            getObjectsOfClass:CPContact.class
                            fromTable:kTableName_Contact
                            where:CPContact.sessionType == SessionTypeGroup &&
                            CPContact.groupProgress >= GroupCreateProgressCreateOK];
        
        
        for (CPContact *contact in carray) {
            NSArray *firstMembers =
            [self.db getObjectsOfClass:CPGroupMember.class
                                                             fromTable:kTableName_GroupMember
                                                                 where:CPGroupMember.sessionId == contact.sessionId
                                                               orderBy:CPGroupMember.join_time.order(WCTOrderedAscending)
                                                                 limit:4];
            contact.groupRelateMember = firstMembers;
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(carray);
            }];
        }
    }];
}

+ (void)getMuteList:(void (^)(NSArray <CPContact *> * _Nullable muteP2P,
                              NSArray <CPContact *> * _Nullable muteGroup))result  {
    [CPInnerState.shared asynWriteTask:^{
        NSArray *mp =  [self.db
                              getObjectsOfClass:CPContact.class
                              fromTable:kTableName_Contact
                              where:
                              (CPContact.sessionType == SessionTypeP2P &&
                               CPContact.publicKey != support_account_pubkey &&
                               CPContact.status != ContactStatusAssistHelper
                               && CPContact.isDoNotDisturb == true)];
        
        NSArray *mg =  [self.db
                        getObjectsOfClass:CPContact.class
                        fromTable:kTableName_Contact
                        where:
                        (CPContact.sessionType == SessionTypeGroup &&
                         CPContact.groupProgress >= GroupCreateProgressCreateOK
                         && CPContact.isDoNotDisturb == true)];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(mp, mg);
            }];
        }
    }];
}


+ (void)getBackupStatisticsInfo:(void (^)(BOOL success, NSString *msg, NSInteger whiteNum, NSInteger blackNum, NSInteger groupNum))result
{
    [CPInnerState.shared asynWriteTask:^{
        NSNumber *whiten =  [self.db
                             getOneValueOnResult:CPContact.publicKey.count()
                             fromTable:kTableName_Contact
                             where:
                             CPContact.sessionType == SessionTypeP2P &&
                             CPContact.isBlack == NO &&
                             CPContact.status != ContactStatusStrange &&
                             CPContact.status != ContactStatusAssistHelper];
        
        NSNumber *blackn =  [self.db
                             getOneValueOnResult:CPContact.publicKey.count()
                             fromTable:kTableName_Contact
                             where:
                             CPContact.sessionType == SessionTypeP2P &&
                             CPContact.isBlack == YES];
        
        NSNumber *groupN =  [self.db
                             getOneValueOnResult:CPContact.publicKey.count()
                             fromTable:kTableName_Contact
                             where:
                             CPContact.sessionType == SessionTypeGroup &&
                             CPContact.groupProgress >= GroupCreateProgressCreateOK];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(YES,nil, whiten.integerValue, blackn.integerValue, groupN.integerValue);
            }];
        }
    }];
}

+ (void)getUploadableContacts:(void (^)(BOOL success, NSString *msg, NSData *encryptData))result {
    
    void (^finalBack)(BOOL, NSString *, NSData *) = ^(BOOL succss, NSString *msg, NSData * _Nullable encData) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg, encData);
            });
        }
    };
    
    
    [CPInnerState.shared asynWriteTask:^{
        NSArray *contacts =  [self.db
                              getObjectsOfClass:CPContact.class
                              fromTable:kTableName_Contact
                              where:
                              (CPContact.sessionType == SessionTypeP2P &&
                               CPContact.publicKey != support_account_pubkey &&
                               CPContact.status != ContactStatusAssistHelper &&
                               CPContact.status != ContactStatusStrange) ||
                              
                              (CPContact.sessionType == SessionTypeGroup &&
                               CPContact.groupProgress >= GroupCreateProgressCreateOK)];
        
        if (contacts.count == 0) {
            finalBack(NO,@"Contact data is empty".localized,nil);
            return;
        }
        
        
        NSArray *topArray =  [self.db
                              getObjectsOnResults: {CPSession.sessionId}
                              fromTable:kTableName_Session
                              where:CPSession.topMark == 1];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSLog(@"%@",topArray); 
            NSMutableArray *topIds = NSMutableArray.array;
            for (CPSession *session in topArray) {
                [topIds addObject:@(session.sessionId)];
            }
            
            
            NSMutableDictionary *Json = NSMutableDictionary.dictionary;
            Json[@"version"] = @(contact_version);
            Json[@"netcloth"] = @"contact-backup-data";
            
            NSInteger whiteN = 0;
            NSInteger blackN = 0;
            NSInteger groupN = 0;
            
            long long msTime = [NSDate.date timeIntervalSince1970] * 1000;
            
            NSMutableArray *datas = NSMutableArray.array;
            for (CPContact *ct in contacts) {
                NSMutableDictionary *dic = NSMutableDictionary.dictionary;
                dic[@"alias"] = ct.remark;
                
                
                NSMutableArray *systemTag = NSMutableArray.array;
                if ([topIds containsObject:@(ct.sessionId)]) {
                    [systemTag addObject:@"topping"];
                }
                
                if (ct.sessionType == SessionTypeP2P) {
                    dic[@"publicKey"] = ct.publicKey;
                    if (ct.isBlack) {
                        [systemTag addObject:@"blacklist"];
                        blackN ++;
                    }
                    else if (ct.isDoNotDisturb) {
                        [systemTag addObject:do_not_disturb_tag];
                        whiteN ++;
                    }
                    else {
                        whiteN ++;
                    }
                }
                else if (ct.sessionType == SessionTypeGroup) {
                    NSString *prikeyHex =  [ct.decodePrivateKey hexString_lower]; 
                    if ([NSString cp_isEmpty:prikeyHex]) {
                        continue;
                    }
                    
                    dic[@"privateKey"] = prikeyHex;
                    [systemTag addObject:group_tag];
                    if (ct.isDoNotDisturb) {
                        [systemTag addObject:do_not_disturb_tag];
                    }
                    groupN++;
                }
                
                dic[@"systemTag"] = systemTag;
                [datas addObject:dic];
            }
            Json[@"data"] = datas;
            
            
            NSData *jsonData = [Json modelToJSONData];
            NSData *gzip = [jsonData gzipDeflate];
            std::string source = nsdata2bytes(gzip);
            std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
            std::string encode = [CPBridge aesEncodeData:source byPrivateKey:str_pri_key];
            NSData *upload = bytes2nsdata(encode);
            
            
            NSMutableDictionary *sumJson = NSMutableDictionary.dictionary;
            sumJson[@"version"] = @(contact_version);
            sumJson[@"netcloth"] = @"contact-backup-summary";
            NSMutableDictionary *sinfo = @{}.mutableCopy;
            sumJson[@"data"] = sinfo;
            
            sinfo[@"backupTime"] = @(msTime);
            NSMutableDictionary *count = @{}.mutableCopy;
            sinfo[@"count"] = count;
            
            count[@"contact"] = @(whiteN);
            count[@"blacklist"] = @(blackN);
            count[group_tag] = @(groupN);
            
            NSData *sumData = [sumJson modelToJSONData];
            NSData *sumgzip = [sumData gzipDeflate];
            std::string sumsource = nsdata2bytes(sumgzip);
            std::string sumencode = [CPBridge aesEncodeData:sumsource byPrivateKey:str_pri_key];
            NSData *sumupload = bytes2nsdata(sumencode);
            
            
            NCProtoContacts *format = NCProtoContacts.alloc.init;
            format.content = upload;
            format.summary = sumupload;
            std::string pubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
            format.pubKey = bytes2nsdata(pubkey);
            
            finalBack(YES,nil,format.data);
        });
    }];
}

+ (void)decodeContactSummary:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData))result
{
    void (^finalBack)(BOOL, NSString *, NSDictionary *) = ^(BOOL succss, NSString *msg, NSDictionary * _Nullable decodeData) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg, decodeData);
            });
        }
    };
    
    [self decodeContact:encodeData complete:^(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData) {
        if ([decodeData[@"netcloth"] isEqualToString:@"contact-backup-summary"] == false) {
            finalBack(NO,@"Wrong data format".localized,nil);
            return;
        }
        finalBack(success,msg,decodeData);
    }];
}


+ (void)restoreContactContent:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg))result {
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [self decodeContact:encodeData complete:^(BOOL success, NSString * _Nonnull msg, NSDictionary * _Nullable decodeData) {
        if ([decodeData[@"netcloth"] isEqualToString:@"contact-backup-data"] == false) {
            finalBack(NO,@"Wrong data format".localized);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *datas = decodeData[@"data"];
            
            CPContact *contact;
            CPSession *session;
            NSInteger successNum = 0;
            
            for (NSDictionary *dic in datas) {
                
                
                NSArray *systemTag = dic[@"systemTag"];
                if ([systemTag containsObject:group_tag]) {
                    contact = CPContact.alloc.init;
                    contact.remark = dic[@"alias"];
                    contact.sessionType = SessionTypeGroup;
                    
                    NSString *privateKey = dic[@"privateKey"];
                    std::string prikey = bytesFromHexString(privateKey);
                    NSData *srcPrikey = bytes2nsdata(prikey);
                    
                    std::string pubkey = GetPublicKeyByPrivateKey(prikey);
                    NSString *hexPubkey = hexStringFromBytes(pubkey);
                    
                    contact.publicKey = hexPubkey;
                    
                    contact.status = ContactStatusNormal;
                    
                    
                    if ([NSData cp_isEmpty:srcPrikey]) {
                        continue;
                    }
                    [contact setSourcePrivateKey:srcPrikey];
                    
                    contact.groupProgress = GroupCreateProgressRestoreOk;
                    
                    NSDate *date = NSDate.date;
                    contact.createTime = [date timeIntervalSince1970];
                    contact.modifiedTime = 0;
                    
                    if ([systemTag containsObject:do_not_disturb_tag]) {
                        contact.isDoNotDisturb = YES;
                    }
                    
                    
                    contact.isAutoIncrement = YES;
                    if (![self.db insertObject:contact into:kTableName_Contact]) {
                        continue;
                    }
                    
                    long long sessionId = contact.lastInsertedRowID;
                    contact.sessionId == sessionId;
                    BOOL topping = [systemTag containsObject:@"topping"];
                    if (topping) {
                        session = CPSession.alloc.init;
                        session.sessionId = sessionId;
                        session.sessionType = SessionTypeGroup;
                        session.topMark = 1;
                        session.lastMsgId = 0; 
                        session.createTime = contact.createTime;
                        session.updateTime = contact.createTime;
                        [self.db insertObject:session into:kTableName_Session];
                    }
                    
                    continue;
                }
                
                
                contact = CPContact.alloc.init;
                
                contact.remark = dic[@"alias"];
                
                contact.publicKey = dic[@"publicKey"];
                contact.sessionType = SessionTypeP2P;
                contact.createTime = [[NSDate date] timeIntervalSince1970];
                
                
                contact.status = ContactStatusNormal;
                contact.isBlack = NO;
                contact.isDoNotDisturb = NO;
                if ([systemTag containsObject:@"blacklist"]) {
                    contact.isBlack = YES;
                }
                if ([systemTag containsObject:do_not_disturb_tag]) {
                    contact.isDoNotDisturb = YES;
                }
                
                contact.isAutoIncrement = YES;
                
                BOOL insert_ok = [self.db insertObject:contact into:kTableName_Contact];
                if (insert_ok == false) {
                    
                    CPContact *haved =
                    [self.db getOneObjectOfClass:CPContact.class
                                                                     fromTable:kTableName_Contact
                                                                         where:CPContact.publicKey == contact.publicKey];
                    
                    
                    NSString *oriRemark = [haved.publicKey substringToIndex:12];
                    if (([haved.remark isEqualToString:oriRemark]) &&
                        (![contact.remark isEqualToString:oriRemark])) {
                        [self.db updateRowsInTable:kTableName_Contact
                                                                    onProperties:{CPContact.remark,CPContact.status}
                                                                         withRow:@[contact.remark, @(ContactStatusNormal)]
                                                                           where:CPContact.publicKey == contact.publicKey];
                    }
                    continue;
                }
                long long sessionId = contact.lastInsertedRowID;
                contact.sessionId == sessionId;
                BOOL topping = [systemTag containsObject:@"topping"];
                if (topping) {
                    session = CPSession.alloc.init;
                    session.sessionId = sessionId;
                    session.sessionType = SessionTypeP2P;
                    session.topMark = 1;
                    session.lastMsgId = 0; 
                    session.createTime = contact.createTime;
                    session.updateTime = contact.createTime;
                    [self.db insertObject:session into:kTableName_Session];
                }
                successNum ++;
            }
            
            finalBack(YES, nil);
        });
    }];
}




+ (void)decodeContact:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData))result
{
    void (^finalBack)(BOOL, NSString *, NSDictionary *) = ^(BOOL succss, NSString *msg, NSDictionary * _Nullable decodeData) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg, decodeData);
            });
        }
    };
    if ([NSData cp_isEmpty:encodeData]) {
        finalBack(false,@"Wrong data format".localized,nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        std::string source = nsdata2bytes(encodeData);
        std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        NSData *decodeData = [CPBridge aesDecodeData:source byPrivateKey:str_pri_key];
        if ([NSData cp_isEmpty:decodeData]) {
            finalBack(false,@"Wrong data format".localized,nil);
            return;
        }
        NSData *gzipDecode = [decodeData gzipInflate];
        NSDictionary *json = [gzipDecode jsonValueDecoded];
        
        finalBack(YES,nil,json);
    });
}


+ (void)getOneContactByPubkey:(NSString * _Nullable )publicKey
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result {
    
    [CPInnerState.shared asynWriteTask:^{
        CPContact *tmpContact =  [self.db
                                  getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact
                                  where:CPContact.publicKey == publicKey];
        
        
        if (result) {
            BOOL r = tmpContact != nil;
            NSString *tmsg = r ? @"success" : @"System error".localized;
            [CPInnerState.shared asynDoTask:^{
                result(r, tmsg, tmpContact);
            }];
        }
    }];
}


+ (void)onlyDeleteContactsInSessionIds:(NSArray<NSNumber *> *)sessionIds
                              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL r =
        [self.db deleteObjectsFromTable:kTableName_Contact where:CPContact.sessionId.in(sessionIds)];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(r,nil);
            }];
        }
    }];
}


+ (void)deleteContactUser:(NSString *)publicKey
                 callback:(void(^)(BOOL succss, NSString *msg))result
{
    [CPInnerState.shared asynWriteTask:^{
        
        CPContact *exitContact =  [self.db
                                   getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.publicKey == publicKey];
        
        
        if (exitContact &&
            ([NSString cp_isEmpty:exitContact.publicKey] == false)) {
            
            
            [CPSessionHelper deleteSession:exitContact.sessionId complete:nil];
            
            
            if (exitContact.sessionType == SessionTypeGroup) {
                [self.db deleteObjectsFromTable:kTableName_GroupMessage
                                                                        where:CPMessage.sessionId == exitContact.sessionId];
                [self.db deleteObjectsFromTable:kTableName_GroupMember
                                                                        where:CPGroupMember.sessionId == exitContact.sessionId];
                
                
                CPContact *cache =  [CPInnerState.shared.groupContactCache getObjectBy:^BOOL(CPContact *contact) {
                    if ([contact.publicKey isEqualToString:exitContact.publicKey]) {
                        return true;
                    }
                    return false;
                }];
                
                if (cache) {
                    [CPInnerState.shared.groupContactCache removeObject:cache];
                }
            }
            
            
            [CPContactHelper _deleteContactUser:exitContact.publicKey callback:^(BOOL succss, NSString *msg) {
                if (result) {
                    [CPInnerState.shared asynDoTask:^{
                        result(succss,msg);
                    }];
                }
            }];
        }
        else {
            if (result) {
                [CPInnerState.shared asynDoTask:^{
                    result(false,NSLocalizedString(@"System error", nil));
                }];
            }
        }
    }];
}

+ (void)_deleteContactUser:(NSString *)publicKey
                  callback:(void(^)(BOOL succss, NSString *msg))result {
    
    [CPInnerState.shared asynWriteTask:^{
        BOOL res = [self.db deleteObjectsFromTable:kTableName_Contact where:CPContact.publicKey == publicKey];
        NSString *reason = NSLocalizedString(@"Delete Successfully", nil);
        if (res == false) {
            reason = NSLocalizedString(@"System error", nil);
        } else {
            NSInteger loginUid = CPInnerState.shared.loginUser.userId;
            [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
}



+ (void)updateRemark:(NSString *)remark
    whereContactUser:(NSString *)publicKey
            callback:(void(^)(BOOL succss, NSString *msg))result {
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.remark}
                                                                    withRow:@[remark ?: @""]
                                                                      where:CPContact.publicKey == publicKey];
        
        
        
        NSString *reason = NSLocalizedString(@"Update Successfully", nil);
        if (res == false) {
            reason = NSLocalizedString(@"System error", nil);
        } else {
            NSInteger loginUid = CPInnerState.shared.loginUser.userId;
            [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
}

+ (void)updateStatus:(ContactStatus)status
    whereContactUser:(NSString *)publicKey
            callback:(void(^)(BOOL succss, NSString *msg))result {
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.status}
                                                                    withRow:@[@(status)]
                                                                      where:CPContact.publicKey == publicKey];
        
        
        
        NSString *reason = NSLocalizedString(@"Update Successfully", nil);
        if (res == false) {
            reason = NSLocalizedString(@"System error", nil);
        } else {
            if (status != ContactStatusAssistHelper) {
                NSInteger loginUid = CPInnerState.shared.loginUser.userId;
                [UserSettings deleteKey:@"contactBackup" ofUser:loginUid];
            }
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
}

+ (void)updateAllNewfriendToNormalCallback:(void(^)(BOOL succss, NSString *msg))result {
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.status}
                                                                    withRow:@[@(ContactStatusNormal)]
                                                                      where:CPContact.status == ContactStatusNewFriend];
        
        
        
        NSString *reason = NSLocalizedString(@"Update Successfully", nil);
        if (res == false) {
            reason = NSLocalizedString(@"System error", nil);
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
}




+ (void)addUserToBlacklist:(NSString *)publicKey
                  callback:(void(^)(BOOL succss, NSString *msg))result
{
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.isBlack}
                                                                    withRow:@[@(YES)]
                                                                      where:CPContact.publicKey == publicKey];
        
        
        
        NSString *reason = @"Update Successfully".localized;
        if (res == false) {
            reason = @"System error".localized;
        } else {
            
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
    
}

+ (void)removeUserFromBlacklist:(NSString *)publicKey
                       callback:(void(^)(BOOL succss, NSString *msg))result {
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.isBlack}
                                                                    withRow:@[@(NO)]
                                                                      where:CPContact.publicKey == publicKey];
        
        NSString *reason = @"Update Successfully".localized;
        if (res == false) {
            reason = @"System error".localized;
        } else {
            
        }
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(res,reason);
            }];
        }
    }];
}


+ (void)addUserToDoNotDisturb:(NSString *)publicKey
                     callback:(void(^)(BOOL succss, NSString *msg))result {
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.isDoNotDisturb}
                                                                    withRow:@[@(YES)]
                                                                      where:CPContact.publicKey == publicKey];
        
        if (result == nil) {
            return;
        }
        NSString *reason = @"Update Successfully".localized;
        if (res == false) {
            reason = @"System error".localized;
        }
        [CPInnerState.shared asynDoTask:^{
            result(res,reason);
        }];
    }];
    
}

+ (void)removeUserFromDoNotDisturb:(NSString *)publicKey
                          callback:(void(^)(BOOL succss, NSString *msg))result {
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [self.db updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.isDoNotDisturb}
                                                                    withRow:@[@(NO)]
                                                                      where:CPContact.publicKey == publicKey];
        
        if (result == nil) {
            return;
        }
        NSString *reason = @"Update Successfully".localized;
        if (res == false) {
            reason = @"System error".localized;
        }
        [CPInnerState.shared asynDoTask:^{
            result(res,reason);
        }];
    }];
}



+ (void)checkContactUser:(NSString *)publicKey
                 comment:(NSString *)remark
                callback:(void(^)(BOOL succss, NSString *msg))result {
    NSAssert(result != nil, @"result must set");
    if ([NSString cp_isEmpty:publicKey]) {
        result(NO,@"请输入有效地址");
        return;
    }
    
    if ([NSString cp_isEmpty:remark]) {
        result(NO,@"请输入有效备注");
        return;
    }
    result(YES,@"数据有效");
}

@end
