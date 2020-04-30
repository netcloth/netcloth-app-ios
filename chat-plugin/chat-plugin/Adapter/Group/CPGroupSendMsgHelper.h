//
//  CPGroupSendMsgHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CPMessage;

@interface CPGroupSendMsgHelper : NSObject

//MARK:- Send

// send text msg
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


//MARK:- Send Image
+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;

+ (void)onDownloadImageData:(NSData *)encodeData withMessage:(CPMessage *)msg;


//MARK:- for Retry
+ (void)retrySendMsg:(long long)msgId;
+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message;


@end

NS_ASSUME_NONNULL_END
