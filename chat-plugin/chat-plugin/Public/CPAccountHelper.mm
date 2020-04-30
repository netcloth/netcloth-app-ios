







#import "CPAccountHelper.h"
#import "CPDataModel+secpri.h"
#import "CPContactHelper.h"

#import "key_tool.h"
#import "string_tools.h"

#import "NSDate+YYAdd.h"
#import "NSString+YYAdd.h"
#import "FCFileManager.h"
#import <WCDB/WCDB.h>
#import "CPInnerState.h"
#import "CPBridge.h"
#import "CPChatLog.h"
#import "CPSendMsgHelper.h"
#import <chat_plugin/chat_plugin-Swift.h>
#import "UserSettings.h"

NSNotificationName const kServiceConnectStatusChange = @"NCKServiceConnectStatusChange";
NSNotificationName const kServiceRegisterOk = @"NCKServiceRegisterOk";

NSArray *_allEndPoints;
NSInteger _rand = 0;

@implementation CPAccountHelper

+ (void)load {
    [super load];
    
#if DEBUG
    



#endif
    
    [self fixUserDbBeforeV1];
}


+ (void)registerUserByAccount:(NSString *)name
                     password:(NSString *)pwd
                     callback:(void (^)(BOOL success, NSString *msg, User * _Nullable registerUser))result
{
    
    std::string prikey =  generationAccountPrivatekey();
    [self _registerUserAccount:name password:pwd privateKey:prikey callback:^(BOOL success, NSString *msg, User * _Nullable registerUser) {
        
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success,msg,registerUser);
            });
        }
    }];
}

+ (void)_registerUserAccount:(NSString *)name
                    password:(NSString *)pwd
                  privateKey:(std::string)privateKey
                    callback:(void (^)(BOOL success, NSString *msg, User * _Nullable registerUser))result
{
    void (^error)(NSString *msg) = ^(NSString *msg){
        if (result) {
            result(NO,msg,nil);
        };
    };
    
    User *user = User.alloc.init;
    
    std::string prikey =  privateKey;
    std::string publicKey = GetPublicKeyByPrivateKey(prikey);
    
    
    user.publicKey = hexStringFromBytes(publicKey);
    user.accountName = name;
    long long sign_hash = (long long)GetHash(publicKey);
    user.pubkeySignHash = sign_hash;
    
    NSDate *date = NSDate.date;
    user.createTime = [date timeIntervalSince1970];
    
    
    user.isAutoIncrement = YES;
    
    [self createUsersBD];
    
    BOOL update = [CPInnerState.shared.allUsersDB insertObject:user into:kTableName_User];
    if (update == NO) {
        error(@"Account is existed".localized);
        return;
    }
    else {
        int uid = user.lastInsertedRowID;
        user.userId = uid;
        
        
        NSString *folder = [NSString stringWithFormat:@"%d",uid];
        [FCFileManager createDirectoriesForPath:folder];
        
        NSString *dbpath = [self dbPathForUUID:folder];
        WCTDatabase *database = [[WCTDatabase alloc] initWithPath:dbpath];
        [self createTabsAtDb:database];
        [database close];
        
        
        NSData *dpk = bytes2nsdata(prikey);
        NSError *err;
        [NCKeyStore.shared registerWithOriginPrivateKey:dpk pwd:pwd uid:uid error:&err];
        
        if (err) {
            error(@"System error".localized);
            return;
        }
    }
    
    if (result) {
        
        NSInteger userId = user.userId;
        NSString *key = [UserSettings sourceKey:@"contactBackup" ofUser:userId];
        [UserSettings setObject:@"1" forSourceKey:key];
        
        result(YES,@"添加账号成功",user);
    }
    
}

+ (void)loginWithUid:(NSInteger)uid
            password:(NSString *)pwd
            callback:(void (^)(BOOL succsss, NSString *msg))result
{
    
    void (^error)(NSString *msg1) = ^(NSString *msg1){
        if (result) {
            result(NO,msg1);
        };
    };
    
    
    NSError *err;
    [NCKeyStore.shared login:uid pwd:pwd error:&err];
    if (err) {
        error(nil);
        return;
    }
    
    
    if (![self loginUserForUid:uid fromPassword:pwd]) {
        error(nil);
        return;
    }
    
    [CPInnerState.shared asynWriteTask:^{
        try {
            
            [CPInnerState.shared userlogin];
            
            
            [CPInnerState.shared asynDoTask:^{
                if (result) {
                    result(YES, nil);
                }
            }];
            
            [CPSessionHelper fakeAddRecommendedGroupSession];
            [CPChatLog enableFileLog];
        }
        catch (std::exception) {
            
        }
        catch (NSError *err) {
            
            NSLog(@"%@",err);
        }
        
    }];
}

+ (BOOL)isLogin {
    if ([self loginUser] != nil) {
        return YES;
    }
    return false;
}


+ (void)connectAllChatEnterPoint:(NSArray<NSString *> *)points {
    _allEndPoints = points;
    _rand = 0;
    [self randomConnect];
}

+ (BOOL)isConnected {
    return [CPInnerState.shared isConnected];
}

+ (BOOL)isNetworkOk {
    return [CPInnerState.shared isNetworkOk] && _allEndPoints.count > 0;
}

+ (void)setNetworkEnterPoint:(NSString *)enterPoint {
    CPNetURL.EnterPointApi = enterPoint;
}

+ (void)onShouldReinitConnectToUseNewHostAndPort {
    _rand ++;
    [self randomConnect];
}

+ (void)randomConnect {
    
    if (_allEndPoints == nil || _allEndPoints.count == 0) {
        return;
    }
    
    NSInteger index = _rand % _allEndPoints.count;
    NSString *endPoint = _allEndPoints[index];
    NSArray *compon = [endPoint componentsSeparatedByString:@":"];
    NSString *host;
    uint16_t point = 4455;
    if (compon.count >= 2) {
        host = compon[0];
        point = [compon[1] intValue];
    } else if (compon.count == 1)  {
        host = compon[0];
    }
    [self _connectHost:host port:point];
}

+ (void)_connectHost:(NSString *)host port:(uint16_t)point {
    [CPInnerState.shared connectServiceHost:host port:point];
}

+ (void)disconnect {
    [CPInnerState.shared disconnect];
}


+ (User * _Nullable)loginUser {
    return CPInnerState.shared.loginUser;
}

+ (void)logoutWithComplete:(void (^)(BOOL succsss, NSString * _Nullable msg))callBack {
    [CPSendMsgHelper unbindDeviceTokenComplete:^(NSDictionary *response) {
        [CPInnerState.shared.chatDelegates removeAllObjects];
        [CPInnerState.shared disconnect]; 
        
        _allEndPoints = nil;
        [self setNetworkEnterPoint:@""];
        
        [CPInnerState.shared userlogout];
        
        if (callBack != nil) {
            callBack(true, nil);
        }
    }];
}



+ (BOOL)checkLoginUserPwd:(NSString *)pwd {
    if ([self isLogin] == false) {
        return false;
    }
    
    NSError *err;
    NSData *orpk = [NCKeyStore.shared nsdataPrikeyOfLoginUser:pwd error:&err];
    if (err || orpk.length != kPrivateKeySize) {
        return false;
    }
    return true;
}

+ (void)allUserListCallback:(void (^)(NSArray<User *>* users))result {
    
    [CPInnerState.shared asynWriteTask:^{
        NSArray *users =
        [CPInnerState.shared.allUsersDB getAllObjectsOfClass:User.class fromTable:kTableName_User];
        
        [CPInnerState.shared asynDoTask:^{
            if (result) {
                result(users);
            }
        }];
    }];
}


+ (BOOL)fixUserDbBeforeV1 {
    [self createUsersBD];
    return NO;
}

+ (void)createUsersBD {
    if (CPInnerState.shared.allUsersDB == nil) {
        NSString *dbpath = [FCFileManager pathForDocumentsDirectoryWithPath:[@"Users" stringByAppendingPathComponent:@"Chat.db"]];
        WCTDatabase *database = [[WCTDatabase alloc] initWithPath:dbpath];
        CPInnerState.shared.allUsersDB = database;
    }
    [CPInnerState.shared.allUsersDB createTableAndIndexesOfName:kTableName_User withClass:User.class];
}

+ (void)configDeviceToken:(NSString *)token
{
    [CPSendMsgHelper setDeviceToken:token];
}


+ (void)deleteUser:(NSInteger)uid
          callback:(void (^)(BOOL success, NSString *msg))result
{
    void (^block)(BOOL, NSString *) = ^(BOOL success, NSString *msg) {
           if (result) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   result(success, msg);
               });
           }
       };
    
    
    NSString *path = [self dbFolderForUUID:@(uid).stringValue];
    NSError *err;
    [FCFileManager removeItemAtPath:path error:&err];
    if (err) {
        block(false, @"delete db err");
    } else {
        BOOL res =
        [CPInnerState.shared.allUsersDB  deleteObjectsFromTable:kTableName_User where:User.userId == uid];
        
        if (res == false) {
            block(false, @"delete user error");
        }
        else {
            [CPOfflineMsgManager deleteOffKeyOfUser:uid];
            block(true, @"ok");
        }
    }
}


+ (void)exportKeystoreAndPrivateKey:(NSString *)loginPwd
                    exportPassword:(NSString *)exportPwd
                          callback:(void (^)(BOOL success, NSString *msg, NSString *keystore, NSString *oriPriKey))result;
{
    
    void (^block)(BOOL, NSString *, NSString *, NSString *) = ^(BOOL success, NSString *msg,NSString *keystore, NSString *oriPk){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg, keystore, oriPk);
            });
        }
    };
    
    
    std::string oriPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, loginPwd);
    if (oriPrikey.length() > 0) {
        NSData *bridgeBytes = bytes2nsdata(oriPrikey); 
        NSAssert(bridgeBytes.length == kPrivateKeySize, @"bridgeBytes must fill data");
        
        
        NSError *err;
        NSString *keystore = [CPWalletWraper encodeKeystore:bridgeBytes exportPwd:exportPwd error:&err];
        
        if (err) {
            block(false,@"WalletManager.Error.invalidKeystore".localized, nil, nil);
        }
        else {
            NSString *priKey =  hexStringFromBytes(oriPrikey);
            
            if ([exportPwd isEqualToString:loginPwd] == NO) {
                
                NSError *err;
                [NCKeyStore.shared changeLoginUserWithOldPwd:loginPwd toNewPwd:exportPwd uid:CPInnerState.shared.loginUser.userId error:&err];
                if (err) {
                    block(false,@"WalletManager.Error.invalidKeystore".localized, nil, nil);
                } else {
                    CPInnerState.shared.loginUser.password = exportPwd;
                    decodePrivateKey = "";
                    block(true,nil, keystore, priKey);
                }
                
            } else {
                block(true,nil, keystore, priKey);
            }
        }
    }
    else {
        block(false, @"WalletManager.Error.invalidPassword".localized, nil, nil);
    }
}

+ (void)verifyKeystore:(NSString *)keystore
             exportPwd:(NSString *)expwd
              callback:(void (^)(BOOL valid, NSString *msg))result
{
    void (^block)(BOOL, NSString *) = ^(BOOL success, NSString *msg){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg);
            });
        }
    };
    
    NSError *err;
    NSData *decodePrikey = [CPWalletWraper decodeKeystore:keystore password:expwd error:&err];
    std::string oriPrikey =   getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, expwd);
    std::string toDecodeP = nsdata2bytes(decodePrikey);
    
    if (err || (decodePrikey.length != kPrivateKeySize) || !(toDecodeP == oriPrikey)) {
        block(false, @"WalletManager.Error.invalidKeystore".localized);
    } else {
        block(true, @"valid data".localized);
    }
}


+ (void)importKeystore:(NSString *)keystore
           accountName:(NSString *)name
              password:(NSString *)exportPwd
              callback:(void (^)(BOOL success, NSString *msg, User *importUser))result
{
    void (^block)(BOOL, NSString *, User *) = ^(BOOL success, NSString *msg, User *importUser){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg, importUser);
            });
        }
    };
    
    
    NSError *err;
    NSData *decodePrikey = [CPWalletWraper decodeKeystore:keystore password:exportPwd error:&err];
    if (err) {
        block(false, @"WalletManager.Error.invalidData".localized, nil);
    }
    else {
        std::string prikey = nsdata2bytes(decodePrikey);
        [self _registerUserAccount:name password:exportPwd privateKey:prikey callback:^(BOOL success, NSString *msg, User * _Nullable registerUser) {
            block(success,msg,registerUser);
        }];
    }
}


+ (void)importPrivateKey:(NSString *)privateKey
             accountName:(NSString *)name
                password:(NSString *)exportPwd
                callback:(void (^)(BOOL success, NSString *msg, User *importUser))result
{
    void (^block)(BOOL, NSString *, User *) = ^(BOOL success, NSString *msg, User *importUser){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg, importUser);
            });
        }
    };
    
    
    std::string prikey = bytesFromHexString(privateKey);
    if (prikey.length() != kPrivateKeySize) {
        block(false, @"WalletManager.Error.invalidData".localized, nil);
    }
    else {
        [self _registerUserAccount:name password:exportPwd privateKey:prikey callback:^(BOOL success, NSString *msg, User * _Nullable registerUser) {
            block(success,msg,registerUser);
        }];
    }
}


+ (void)verifyPrivateKey:(NSString *)inputPrivateKey
                callback:(void (^)(BOOL valid, NSString *msg))result
{
    void (^block)(BOOL, NSString *) = ^(BOOL success, NSString *msg){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg);
            });
        }
    };
    
    std::string prikey = bytesFromHexString(inputPrivateKey);
    if (prikey.length() != kPrivateKeySize) {
        block(false, @"WalletManager.Error.invalidData".localized);
    }
    else {
        std::string publicKey = GetPublicKeyByPrivateKey(prikey); 
        NSString *spbkey = [CPInnerState.shared.loginUser publicKey];
        std::string storePbkey = bytesFromHexString(spbkey);
        
        if (publicKey != storePbkey) {
            block(false, @"WalletManager.Error.invalidData".localized);
        }
        else {
            block(true, @"Valid data".localized);   
        }
    }
}

+ (void)changeLoginUserToPwd:(NSString *)nPwd
                    callback:(void (^)(BOOL valid, NSString *msg))result;
{
    void (^block)(BOOL, NSString *) = ^(BOOL success, NSString *msg){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(success, msg);
            });
        }
    };
    
    User *loginUser = CPInnerState.shared.loginUser;
    NSError *err;
    [NCKeyStore.shared changeLoginUserWithOldPwd:loginUser.password toNewPwd:nPwd uid:loginUser.userId error:&err];
    
    if (err) {
        block(false,@"WalletManager.Error.invalidPrivateKey".localized);
    } else {
        loginUser.password = nPwd;
        block(true,nil);
    }
}


+ (void)changeLoginUserName:(NSString *)userName
                callback:(void (^)(BOOL success, NSString *msg))result
{
    void (^block)(BOOL, NSString *) = ^(BOOL success, NSString *msg){
           if (result) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   result(success, msg);
               });
           }
    };
    [CPInnerState.shared asynWriteTask:^{
        BOOL r =
        [CPInnerState.shared.allUsersDB updateRowsInTable:kTableName_User onProperties:User.accountName withRow:@[userName] where:User.userId == CPInnerState.shared.loginUser.userId];
        if (r == false) {
            block(false, @"Contact_have_added".localized);
        } else {
            CPInnerState.shared.loginUser.accountName = userName;
            block(true,nil);
        }
    }];
}


+ (User *)loginUserForUid:(NSInteger)uid
              fromPassword:(NSString *)pwd {
    
    [self createUsersBD];
    
    if (!CPInnerState.shared.loginUserDataBase) {
        NSString *uuid = @(uid).stringValue;
        NSString *dbpath = [self dbPathForUUID:uuid];
        NSLog(@"DBPath = %@",dbpath);
        WCTDatabase *database = [[WCTDatabase alloc] initWithPath:dbpath];
        CPInnerState.shared.loginUserDataBase = database;
    }
    
    if (!CPInnerState.shared.loginUser) {
        User *user = [CPInnerState.shared.allUsersDB
                      getOneObjectOfClass:User.class
                      fromTable:kTableName_User
                      where:User.userId == uid];
        
        if (user != nil) {
            
            NSError *err;
            NSData *oriPriKey = [NCKeyStore.shared nsdataPrikeyOfLoginUser:pwd error:&err];
            if (err) {
                return nil;
            }
            else {
                std::string bytePrikey = nsdata2bytes(oriPriKey);
                std::string pubkey = GetPublicKeyByPrivateKey(bytePrikey);
                NSString *pk = hexStringFromBytes(pubkey);
                user.publicKey = pk;
            }
            
            user.password = pwd;
            CPInnerState.shared.loginUser = user;
            [self createTabsAtDb:CPInnerState.shared.loginUserDataBase];
        }
        return user;
    }
    return CPInnerState.shared.loginUser;
}

+ (NSString *)dbPathForUUID:(NSString *)uuid {
    if (!uuid) {
        return nil;
    }
    NSString *dbpath = [FCFileManager pathForDocumentsDirectoryWithPath:[uuid stringByAppendingPathComponent:@"Chat.db"]];
    return dbpath;
}

+ (NSString *)dbFolderForUUID:(NSString *)uuid {
    if (!uuid) {
        return nil;
    }
    NSString *dbpath = [FCFileManager pathForDocumentsDirectoryWithPath:uuid];
    return dbpath;
}



+ (void)createTabsAtDb:(WCTDatabase *)db {
    [db createTableAndIndexesOfName:kTableName_Contact withClass:CPContact.class];
    [db createTableAndIndexesOfName:kTableName_Session withClass:CPSession.class];
    [db createTableAndIndexesOfName:kTableName_Message withClass:CPMessage.class];
    [db createTableAndIndexesOfName:kTableName_Claim withClass:CPChainClaim.class];
    
    [db createTableAndIndexesOfName:kTableName_GroupMessage withClass:CPMessage.class];
    [db createTableAndIndexesOfName:kTableName_GroupMember withClass:CPGroupMember.class];
    [db createTableAndIndexesOfName:kTableName_GroupNotify withClass:CPGroupNotify.class];
    
    [db createTableAndIndexesOfName:kTableName_AssetToken withClass:CPAssetToken.class];
    [db createTableAndIndexesOfName:kTableName_TradeRecord withClass:CPTradeRsp.class];
}

static NSString *_domain;
dispatch_semaphore_t _domainlock = dispatch_semaphore_create(1);

+ (void)requestDomain:(NSInteger)count {
    
    dispatch_semaphore_wait(_domainlock, DISPATCH_TIME_FOREVER);    
    if (_domain) {
        dispatch_semaphore_signal(_domainlock);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https:
    request.timeoutInterval = 30;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    NSURLSessionDataTask *task =
    [session
     dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            NSString *url = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if ([NSString cp_isEmpty:url] == NO) {
                _domain = url;
                [NSUserDefaults.standardUserDefaults setObject:_domain forKey:@"kgdomain"];
            }
        }
        dispatch_semaphore_signal(_domainlock);
    }];
    [task resume];
}

+ (NSString *)connectDomain {
    if (!_domain) {
        _domain = [NSUserDefaults.standardUserDefaults  objectForKey:@"kgdomain"];
    }
    return _domain;
}

@end
