  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const kServiceConnectStatusChange;
extern NSNotificationName const kServiceRegisterOk;

@interface CPAccountHelper : NSObject

+ (void)registerUserByAccount:(NSString *)name
                     password:(NSString *)pwd
                     callback:(void (^)(BOOL success, NSString *msg, User * _Nullable registerUser))result;

+ (void)loginWithUid:(NSInteger)uid
                password:(NSString *)pwd
                callback:(void (^)(BOOL succsss, NSString * _Nullable msg))result;

+ (BOOL)isLogin;

+ (User * _Nullable)loginUser;

+ (void)logoutWithComplete:(void (^)(BOOL succsss, NSString * _Nullable msg))callBack;

+ (void)setNetworkEnterPoint:(NSString *)enterPoint;    

+ (void)connectAllChatEnterPoint:(NSArray<NSString *> *)points;    

  
+ (BOOL)isConnected;

  
+ (BOOL)isNetworkOk;

+ (void)disconnect;



  
+ (void)configDeviceToken:(NSString *)token;

  
 
+ (void)allUserListCallback:(void (^)(NSArray<User *>* users))result;


+ (void)deleteUser:(NSInteger)uid
          callback:(void (^)(BOOL success, NSString *msg))result;


  

 
+ (BOOL)checkLoginUserPwd:(NSString * _Nullable)pwd;

 
+ (void)exportKeystoreAndPrivateKey:(NSString *)loginPwd
                     exportPassword:(NSString *)exportPwd
                           callback:(void (^)(BOOL success, NSString *msg, NSString *keystore, NSString *oriPriKey))result;

+ (void)verifyKeystore:(NSString *)keystore
             exportPwd:(NSString *)expwd
              callback:(void (^)(BOOL valid, NSString *msg))result;

  
+ (void)importKeystore:(NSString *)keystore
           accountName:(NSString *)name
              password:(NSString *)exportPwd
              callback:(void (^)(BOOL success, NSString *msg, User *importUser))result;

+ (void)importPrivateKey:(NSString *)privateKey
           accountName:(NSString *)name
              password:(NSString *)exportPwd
              callback:(void (^)(BOOL success, NSString *msg, User *importUser))result;

  
+ (void)verifyPrivateKey:(NSString *)inputPrivateKey
              callback:(void (^)(BOOL valid, NSString *msg))result;

+ (void)changeLoginUserToPwd:(NSString *)nPwd
                    callback:(void (^)(BOOL valid, NSString *msg))result;

  
+ (void)changeLoginUserName:(NSString *)userName
                callback:(void (^)(BOOL success, NSString *msg))result;


@end


NS_ASSUME_NONNULL_END
