







#import <Foundation/Foundation.h>
#import "CPDataModel.h"


extern NSString * const support_account_pubkey;

NS_ASSUME_NONNULL_BEGIN

@interface CPContactHelper : NSObject


+ (void)addContactUser:(NSString * _Nullable )publicKey
               comment:(NSString * _Nullable )remark
              callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)getNormalContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getBlackListContacts:(void (^)(NSArray <CPContact *> * contacts))result;
+ (void)getAllContacts:(void (^)(NSArray <CPContact *> * contacts))result;


+ (void)getBackupStatisticsInfo:(void (^)(BOOL success, NSString *msg, NSInteger whiteNum, NSInteger blackNum))result;
+ (void)getUploadableContacts:(void (^)(BOOL success, NSString *msg, NSData * _Nullable encryptData))result;


+ (void)decodeContactSummary:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg, NSDictionary * _Nullable decodeData))result;

+ (void)restoreContactContent:(NSData *)encodeData complete:(void (^)(BOOL success, NSString *msg))result;



+ (void)getOneContactByPubkey:(NSString * _Nullable )publicKey
                     callback:(void(^)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;




+ (void)deleteContactUser:(NSString *)publicKey
                 callback:(void(^)(BOOL succss, NSString *msg))result;


+ (void)updateRemark:(NSString *)remark
    whereContactUser:(NSString *)publicKey
            callback:(void(^)(BOOL succss, NSString *msg))result;


+ (void)addUserToBlacklist:(NSString *)publicKey
                  callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)removeUserFromBlacklist:(NSString *)publicKey
                       callback:(void(^)(BOOL succss, NSString *msg))result;

@end

NS_ASSUME_NONNULL_END
