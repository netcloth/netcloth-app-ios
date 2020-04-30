//
//  CPAccountHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/7/23.
//  Copyright © 2019 netcloth. All rights reserved.
//

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

+ (void)setNetworkEnterPoint:(NSString *)enterPoint;  //设置链接的域名

+ (void)connectAllChatEnterPoint:(NSArray<NSString *> *)points;  //设置socket 多端口

//具有业务状态 注册成功
+ (BOOL)isConnected;

//仅仅是网络状态
+ (BOOL)isNetworkOk;

+ (void)disconnect;



//MARK:- APNS
+ (void)configDeviceToken:(NSString *)token;

//MARK:- User
/**
 account name list
 @return
 */
+ (void)allUserListCallback:(void (^)(NSArray<User *>* users))result;


+ (void)deleteUser:(NSInteger)uid
          callback:(void (^)(BOOL success, NSString *msg))result;


//MARK:- Export

/**
 check user login pwd
 */
+ (BOOL)checkLoginUserPwd:(NSString * _Nullable)pwd;

/**
 export privatekey to keystore

 @param loginPwd origin pwd
 @param exportPwd export pwd
 @param result result
 */
+ (void)exportKeystoreAndPrivateKey:(NSString *)loginPwd
                     exportPassword:(NSString *)exportPwd
                           callback:(void (^)(BOOL success, NSString *msg, NSString *keystore, NSString *oriPriKey))result;

+ (void)verifyKeystore:(NSString *)keystore
             exportPwd:(NSString *)expwd
              callback:(void (^)(BOOL valid, NSString *msg))result;

//MARK:- Import
+ (void)importKeystore:(NSString *)keystore
           accountName:(NSString *)name
              password:(NSString *)exportPwd
              callback:(void (^)(BOOL success, NSString *msg, User *importUser))result;

+ (void)importPrivateKey:(NSString *)privateKey
           accountName:(NSString *)name
              password:(NSString *)exportPwd
              callback:(void (^)(BOOL success, NSString *msg, User *importUser))result;

//MARK:- Change Pwd
+ (void)verifyPrivateKey:(NSString *)inputPrivateKey
              callback:(void (^)(BOOL valid, NSString *msg))result;

+ (void)changeLoginUserToPwd:(NSString *)nPwd
                    callback:(void (^)(BOOL valid, NSString *msg))result;

//MARK:- Change Name
+ (void)changeLoginUserName:(NSString *)userName
                callback:(void (^)(BOOL success, NSString *msg))result;


@end


NS_ASSUME_NONNULL_END
