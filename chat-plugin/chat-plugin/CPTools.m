//
//  CPTools.m
//  chat-plugin
//
//  Created by Grand on 2019/11/1.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPTools.h"

NSString *kTableName_User = @"user";
NSString *kTableName_Contact = @"contact";
NSString *kTableName_Session = @"session";
NSString *kTableName_Message = @"message";
NSString *kTableName_Claim = @"claim";

NSString *kTableName_GroupMember = @"groupmember";
NSString *kTableName_GroupMessage = @"groupmessage";
NSString *kTableName_GroupNotify = @"groupnotify";

NSString *kTableName_AssetToken = @"assettoken";
NSString *kTableName_TradeRecord = @"traderecord";

@implementation CPTools

@end


@implementation NSString (empty)

+ (BOOL)cp_isEmpty:(NSString *)str {
    if (str && [str isKindOfClass:NSString.class] && str.length) {
        return NO;
    }
    return YES;
}

- (NSString *)localized {
    return NSLocalizedString(self, nil);
}

@end


@implementation NSData (empty)
+ (BOOL)cp_isEmpty:(NSData *)data {
    if (data &&
        [data isKindOfClass:NSData.class] &&
        data.length > 0 ) {
        return false;
    }
    return true;
}

- (NSString *)hexString_lower {
    NSUInteger length = self.length;
    NSMutableString *result = [NSMutableString stringWithCapacity:length * 2];
    const unsigned char *byte = self.bytes;
    for (int i = 0; i < length; i++, byte++) {
        [result appendFormat:@"%02x", *byte];
    }
    return result;
}

@end
