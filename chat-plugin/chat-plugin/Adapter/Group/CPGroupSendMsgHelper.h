







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CPMessage;

@interface CPGroupSendMsgHelper : NSObject




+ (void)sendMsg:(NSString *)text
         toUser:(NSString *)toPubkey
         at_all:(BOOL)atAll
     at_members:(NSArray <NSString *> *)members;

/* Send Audio
 *（mono）
 * :11025
 * :PCM16
 */
+ (void)sendAudioData:(NSData *)data toUser:(NSString *)toPubkey;



+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;

+ (void)onDownloadImageData:(NSData *)encodeData withMessage:(CPMessage *)msg;



+ (void)retrySendMsg:(long long)msgId;
+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message;


@end

NS_ASSUME_NONNULL_END
