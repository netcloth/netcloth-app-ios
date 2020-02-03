  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "CPGroupChatHelper.h"

@class CPMessage;

NS_ASSUME_NONNULL_BEGIN

@interface CPSendMsgHelper : NSObject

  

  
+ (void)sendMsg:(NSString *)text toUser:(NSString *)toPubkey;

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

  
+ (void)setDeviceToken:(NSString *)deviceToken;
+ (void)bindDeviceToken;

+ (void)unbindDeviceTokenComplete:(MsgResponseBack)back;


@end

NS_ASSUME_NONNULL_END
