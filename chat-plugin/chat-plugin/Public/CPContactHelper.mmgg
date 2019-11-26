







#import "CPContactHelper.h"
#import "CPDataModel+secpri.h"

#import "CPInnerState.h"
#import <YYKit/YYKit.h>

#import "key_tool.h"
#import "string_tools.h"
#import "CPBridge.h"
#import "MessageObjects.h"


NSString * const support_account_pubkey = @"0449b445774c63c28b6019a1aa5913d252f47683409989d15284b347eb1c9f372e87f7f6e95230ef05d36ea9dc8327425433b7cbfc0d8913a769ee2aabfe23b814";

@implementation CPContactHelper

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
            
            [contacts enumerateObjectsUsingBlock:^(CPContact * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.publicKey isEqualToString:publicKey]) {
                    added = YES;
                    *stop = YES;
                }
            }];
            
            
            if (added) {
                block(NO,NSLocalizedString(@"Contact_have_added", nil),nil);
                return;
            }
            

            CPContact *ct = CPContact.alloc.init;
            ct.publicKey = publicKey;
            ct.remark = remark;
            ct.isAutoIncrement = YES;
            
            NSDate *date = NSDate.date;
            ct.createTime = [date timeIntervalSince1970];
            
            BOOL opereation = YES;
            NSString *reason = NSLocalizedString(@"Added Successfully", nil);
            
            if (![CPInnerState.shared.loginUserDataBase insertObject:ct into:kTableName_Contact]) {
                opereation = NO;
                reason = NSLocalizedString(@"System error", nil);
            }
            if (opereation) {
                ct.sessionId = ct.lastInsertedRowID;
            }
            block(opereation, reason, ct);
        }];
    }];
}

+ (void)getAllContacts:(void (^)(NSArray <CPContact *> * contacts))result {
    [CPInnerState.shared asynWriteTask:^{
        NSArray *carray =  [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPContact.class
                                                                          fromTable:kTableName_Contact
                                                                              where:CPContact.sessionType == SessionTypeP2P];
        
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
        NSArray *carray =  [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPContact.class
                                                                          fromTable:kTableName_Contact
                                                                              where:CPContact.sessionType == SessionTypeP2P && CPContact.isBlack == NO];
        
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
        NSArray *carray =  [CPInnerState.shared.loginUserDataBase
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


+ (void)getBackupStatisticsInfo:(void (^)(BOOL success, NSString *msg, NSInteger whiteNum, NSInteger blackNum))result
{
    [CPInnerState.shared asynWriteTask:^{
        NSNumber *whiten =  [CPInnerState.shared.loginUserDataBase
                             getOneValueOnResult:CPContact.publicKey.count()
                             fromTable:kTableName_Contact
                             where:CPContact.sessionType == SessionTypeP2P && CPContact.isBlack == NO && CPContact.publicKey != support_account_pubkey];
        
        NSNumber *blackn =  [CPInnerState.shared.loginUserDataBase
                             getOneValueOnResult:CPContact.publicKey.count()
                             fromTable:kTableName_Contact
                             where:CPContact.sessionType == SessionTypeP2P && CPContact.isBlack == YES];
        
        if (result) {
            [CPInnerState.shared asynDoTask:^{
                result(YES,nil, whiten.integerValue, blackn.integerValue);
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
        NSArray *contacts =  [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPContact.class
                                                                            fromTable:kTableName_Contact
                                                                                where:CPContact.sessionType == SessionTypeP2P && CPContact.publicKey != support_account_pubkey];
        
        if (contacts.count == 0) {
            finalBack(NO,@"Contact data is empty".localized,nil);
            return;
        }

        NSArray *topArray =  [CPInnerState.shared.loginUserDataBase
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
            Json[@"version"] = @(1);
            Json[@"netcloth"] = @"contact-backup-data";
            
            NSInteger whiteN = 0;
            NSInteger blackN = 0;
            long long msTime = [NSDate.date timeIntervalSince1970] * 1000;
            
            NSMutableArray *datas = NSMutableArray.array;
            for (CPContact *ct in contacts) {
                NSMutableDictionary *dic = NSMutableDictionary.dictionary;
                dic[@"alias"] = ct.remark;
                dic[@"publicKey"] = ct.publicKey;
                NSMutableArray *systemTag = NSMutableArray.array;
                if ([topIds containsObject:@(ct.sessionId)]) {
                    [systemTag addObject:@"topping"];
                }
                if (ct.isBlack) {
                    [systemTag addObject:@"blacklist"];
                    blackN ++;
                } else {
                    whiteN ++;
                }
                dic[@"systemTag"] = systemTag;
                [datas addObject:dic];
            }
            Json[@"data"] = datas;
            

            NSData *jsonData = [Json modelToJSONData];
            NSData *gzip = [jsonData gzipDeflate];
            std::string source = nsdata2bytes(gzip);
            std::string encode = [self encodeContactData:source];
            NSData *upload = bytes2nsdata(encode);
            

            NSMutableDictionary *sumJson = NSMutableDictionary.dictionary;
            sumJson[@"version"] = @(1);
            sumJson[@"netcloth"] = @"contact-backup-summary";
            NSMutableDictionary *sinfo = @{}.mutableCopy;
            sumJson[@"data"] = sinfo;
            
            sinfo[@"backupTime"] = @(msTime);
            NSMutableDictionary *count = @{}.mutableCopy;
            sinfo[@"count"] = count;
            
            count[@"contact"] = @(whiteN);
            count[@"blacklist"] = @(blackN);
            
            NSData *sumData = [sumJson modelToJSONData];
            NSData *sumgzip = [sumData gzipDeflate];
            std::string sumsource = nsdata2bytes(sumgzip);
            std::string sumencode = [self encodeContactData:sumsource];
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
                contact = CPContact.alloc.init;
                contact.remark = dic[@"alias"];
                contact.publicKey = dic[@"publicKey"];
                contact.sessionType = SessionTypeP2P;
                contact.createTime = [[NSDate date] timeIntervalSince1970];
                
                NSArray *systemTag = dic[@"systemTag"];
                if ([systemTag containsObject:@"blacklist"]) {
                    contact.isBlack = YES;
                } else {
                    contact.isBlack = NO;
                }
                contact.isAutoIncrement = YES;
                
                BOOL insert_ok = [CPInnerState.shared.loginUserDataBase insertObject:contact into:kTableName_Contact];
                if (insert_ok == false) {
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
                    
                    [CPInnerState.shared.loginUserDataBase insertObject:session into:kTableName_Session];
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
        NSData *decodeData = [self decodeContactData:source];
        if ([NSData cp_isEmpty:decodeData]) {
            finalBack(false,@"Wrong data format".localized,nil);
            return;
        }
        NSData *gzipDecode = [decodeData gzipInflate];
        NSDictionary *json = [gzipDecode jsonValueDecoded];

        finalBack(YES,nil,json);
    });
}



+ (std::string)encodeContactData:(std::string)sourceBytes
{

    std::string iv = CreateAesIVKey();
    

    std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    
    NSData *data_prikey =  bytes2nsdata(str_pri_key);
    NSData *data_256 = [data_prikey sha256Data];
    std::string shared_key = nsdata2bytes(data_256);
    

    std::string msg_encoded;
    @try  {
        std::string out;

        std::string content = sourceBytes;
        AesEncode(shared_key, iv, content, out);
        msg_encoded = out;
    }
    @finally {
        
    }
    std::string for_send = iv + msg_encoded;
    return for_send;
}



+ (NSData *)decodeContactData:(std::string)encodeData {
    if (encodeData.length() < 16) {
        return nil;
    }
    
    std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    NSData *data_prikey =  bytes2nsdata(str_pri_key);
    NSData *data_256 = [data_prikey sha256Data];
    std::string shared_key = nsdata2bytes(data_256);
    
    std::string msg_org = encodeData;
    std::string iv = msg_org.substr(0,16);
    std::string msg_tmp = msg_org.substr(16,encodeData.length() - 16);
    
    std::string msg_decoded;
    BOOL decR = false;
    @try  {
        std::string out;
        std::string content = msg_tmp;
        decR = AesDecode(shared_key, iv, content, out);
        msg_decoded = out;
    }
    @finally {
        if (decR == false || msg_decoded.length() == 0) {
            return nil;
        }
        return bytes2nsdata(msg_decoded);
    }
}




+ (void)getOneContactByPubkey:(NSString * _Nullable )publicKey
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result {
    
    [CPInnerState.shared asynWriteTask:^{
        CPContact *tmpContact =  [CPInnerState.shared.loginUserDataBase
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





+ (void)deleteContactUser:(NSString *)publicKey
                 callback:(void(^)(BOOL succss, NSString *msg))result
{
    [CPInnerState.shared asynWriteTask:^{
        
        CPContact *exitContact =  [CPInnerState.shared.loginUserDataBase
                                   getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.publicKey == publicKey];
        

        if (exitContact &&
            ([NSString cp_isEmpty:exitContact.publicKey] == false)) {
            

            [CPChatHelper deleteSession:exitContact.sessionId complete:nil];
            

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
        BOOL res = [CPInnerState.shared.loginUserDataBase deleteObjectsFromTable:kTableName_Contact where:CPContact.publicKey == publicKey];
        NSString *reason = NSLocalizedString(@"Delete Successfully", nil);
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

+ (void)updateRemark:(NSString *)remark
    whereContactUser:(NSString *)publicKey
            callback:(void(^)(BOOL succss, NSString *msg))result {
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL res = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
                                                               onProperties:{CPContact.remark}
                                                                    withRow:@[remark ?: @""]
                                                                      where:CPContact.publicKey == publicKey];
        
        
        
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
        
        BOOL res = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
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
        
        BOOL res = [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Contact
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
