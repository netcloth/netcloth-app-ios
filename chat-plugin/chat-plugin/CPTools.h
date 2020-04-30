//
//  CPTools.h
//  chat-plugin
//
//  Created by Grand on 2019/11/1.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPGroupChatHelper.h"

//MARK:- DB Name
extern NSString *kTableName_User;
extern NSString *kTableName_Contact;
extern NSString *kTableName_Session;
extern NSString *kTableName_Message;
extern NSString *kTableName_Claim;

extern NSString *kTableName_GroupMember;
extern NSString *kTableName_GroupMessage;
extern NSString *kTableName_GroupNotify;

extern NSString *kTableName_AssetToken;
extern NSString *kTableName_TradeRecord;


@interface CPTools : NSObject

@end


@interface NSString (empty)

+ (BOOL)cp_isEmpty:(NSString *)str;
- (NSString *)localized;

@end

@interface NSData (empty)

+ (BOOL)cp_isEmpty:(NSData *)data;

- (NSString *)hexString_lower;

@end


#define kPrivateKeySize 32
#define kPublicKeySize 65 //unzip pubkey

//log
#if DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif




//MARK:- Tool

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif
