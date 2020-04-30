//
//  CPSendMsgHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/10/29.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPGroupChatHelper.h"

@class CPMessage;

NS_ASSUME_NONNULL_BEGIN

@interface CPSendMsgHelper : NSObject

//MARK:- Send

// send text msg
+ (void)sendMsg:(NSString *)text toUser:(NSString *)toPubkey;

/* Send Audio
 *（mono）
 * :11025
 * :PCM16
 */
+ (void)sendAudioData:(NSData *)data toUser:(NSString *)toPubkey;


//MARK:- Send Image
+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;

+ (void)onDownloadImageData:(NSData *)encodeData withMessage:(CPMessage *)msg;


//MARK:- for Retry
+ (void)retrySendMsg:(long long)msgId;
+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message;

//MARK:- APNS
+ (void)setDeviceToken:(NSString *)deviceToken;
+ (void)bindDeviceToken;

+ (void)unbindDeviceTokenComplete:(MsgResponseBack)back;


@end

NS_ASSUME_NONNULL_END
