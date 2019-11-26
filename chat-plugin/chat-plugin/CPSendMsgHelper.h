







#import <Foundation/Foundation.h>

#include <string>

@class CPMessage;

NS_ASSUME_NONNULL_BEGIN

@interface CPSendMsgHelper : NSObject




+ (void)sendMsg:(NSString *)text toUser:(NSString *)toPubkey;

+ (void)sendAudioData:(NSData *)data toUser:(NSString *)toPubkey;



+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;

+ (void)onDownloadImageData:(NSData *)encodeData withMessage:(CPMessage *)msg;



+ (void)retrySendMsg:(long long)msgId;
+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message;


+ (void)setDeviceToken:(NSString *)deviceToken;
+ (void)bindDeviceToken;
+ (void)unbindDeviceToken;


@end

NS_ASSUME_NONNULL_END
