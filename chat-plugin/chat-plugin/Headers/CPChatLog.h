//
//  CPChatLog.h
//  chat-plugin
//
//  Created by Grand on 2019/10/22.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void LogFormat(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

NS_ASSUME_NONNULL_BEGIN

@interface CPChatLog : NSObject

+ (NSData * _Nullable)zipLogs;

@end

@class NCProtoNetMsg;
@interface CPChatLog (_priviate)
+ (void)enableFileLog;
+ (void)recordSendMsg:(NCProtoNetMsg *)pack;
+ (void)recordRecieveMsg:(NCProtoNetMsg *)pack;
@end

NS_ASSUME_NONNULL_END
