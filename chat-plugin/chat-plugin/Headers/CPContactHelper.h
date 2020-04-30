//
//  CPContactHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/7/26.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

extern NSString * const support_account_pubkey;
extern NSString * const do_not_disturb_tag;

NS_ASSUME_NONNULL_BEGIN

@interface CPContactHelper : NSObject

//MARK:- Add
+ (void)addAssistHelperAssist:(CPAssistant *)assist
                     callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)addContactUser:(NSString * _Nullable )publicKey
               comment:(NSString * _Nullable )remark
              callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

//MARK:- delete
//会删除会话、联系人
+ (void)deleteContactUser:(NSString *)publicKey
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

// 删除陌生人会话
+ (void)onlyDeleteContactsInSessionIds:(NSArray<NSNumber *> *)sessionIds
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

//MARK:- Update (会引起备份弹窗 提示)
+ (void)updateRemark:(NSString *)remark
    whereContactUser:(NSString *)publicKey
            callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateStatus:(ContactStatus)status
    whereContactUser:(NSString *)publicKey
            callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateAllNewfriendToNormalCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


//MARK:- Get
+ (void)getOneContactByPubkey:(NSString * _Nullable )publicKey
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)getNormalContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getBlackListContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getAllContacts:(void (^)(NSArray <CPContact *> * contacts))result;

+ (void)getGroupListContacts:(void (^)(NSArray <CPContact *> * _Nullable contacts))result;

//MARK:  Push Get
+ (void)getMuteList:(void (^)(NSArray <CPContact *> * _Nullable muteP2P,
                              NSArray <CPContact *> * _Nullable muteGroup))result;

//MARK:- Backup
//摘要
+ (void)getBackupStatisticsInfo:(void (^)(BOOL success, NSString *msg,
                                          NSInteger whiteNum, NSInteger blackNum, NSInteger groupNum))result;

//获取上传数据
+ (void)getUploadableContacts:(void (^)(BOOL success, NSString *msg, NSData * _Nullable encryptData))result;

//解码 摘要
+ (void)decodeContactSummary:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData))result;


//还原备份
+ (void)restoreContactContent:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg))result;




//MARK:- DoNotDisturb
+ (void)addUserToDoNotDisturb:(NSString *)publicKey
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)removeUserFromDoNotDisturb:(NSString *)publicKey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


//MARK:- Black list
+ (void)addUserToBlacklist:(NSString *)publicKey
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)removeUserFromBlacklist:(NSString *)publicKey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

@end

NS_ASSUME_NONNULL_END
