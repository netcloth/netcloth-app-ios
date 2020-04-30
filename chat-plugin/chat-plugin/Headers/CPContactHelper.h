







#import <Foundation/Foundation.h>
#import "CPDataModel.h"

extern NSString * const support_account_pubkey;
extern NSString * const do_not_disturb_tag;

NS_ASSUME_NONNULL_BEGIN

@interface CPContactHelper : NSObject


+ (void)addAssistHelperAssist:(CPAssistant *)assist
                     callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)addContactUser:(NSString * _Nullable )publicKey
               comment:(NSString * _Nullable )remark
              callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;



+ (void)deleteContactUser:(NSString *)publicKey
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)onlyDeleteContactsInSessionIds:(NSArray<NSNumber *> *)sessionIds
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)updateRemark:(NSString *)remark
    whereContactUser:(NSString *)publicKey
            callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateStatus:(ContactStatus)status
    whereContactUser:(NSString *)publicKey
            callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateAllNewfriendToNormalCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;



+ (void)getOneContactByPubkey:(NSString * _Nullable )publicKey
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)getNormalContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getBlackListContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getAllContacts:(void (^)(NSArray <CPContact *> * contacts))result;

+ (void)getGroupListContacts:(void (^)(NSArray <CPContact *> * _Nullable contacts))result;


+ (void)getMuteList:(void (^)(NSArray <CPContact *> * _Nullable muteP2P,
                              NSArray <CPContact *> * _Nullable muteGroup))result;



+ (void)getBackupStatisticsInfo:(void (^)(BOOL success, NSString *msg,
                                          NSInteger whiteNum, NSInteger blackNum, NSInteger groupNum))result;


+ (void)getUploadableContacts:(void (^)(BOOL success, NSString *msg, NSData * _Nullable encryptData))result;


+ (void)decodeContactSummary:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData))result;



+ (void)restoreContactContent:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg))result;





+ (void)addUserToDoNotDisturb:(NSString *)publicKey
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)removeUserFromDoNotDisturb:(NSString *)publicKey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;



+ (void)addUserToBlacklist:(NSString *)publicKey
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)removeUserFromBlacklist:(NSString *)publicKey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

@end

NS_ASSUME_NONNULL_END
