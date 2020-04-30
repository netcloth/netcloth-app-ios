//
//  UserSettings.m
//  chat-plugin
//
//  Created by Grand on 2019/9/18.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "UserSettings.h"
#import "CPInnerState.h"
#import "NSString+YYAdd.h"
#import "YYCache.h"

static YYCache *_UserCache;

@implementation UserSettings

+ (void)initialize
{
    if (self == [UserSettings class]) {
        if (_UserCache == nil) {
            NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *path = [cacheFolder stringByAppendingPathComponent:@"UserCaches"];
            _UserCache = [[YYCache alloc] initWithPath:path];
        }
    }
}

+ (void)setObject:(id)obj forKey:(NSString *)key {
    [_UserCache setObject:obj forKey:[self userKeyWithKey:key]];
}

+ (id)objectForKey:(NSString *)key {
    return
    [_UserCache objectForKey:[self userKeyWithKey:key]];
}

+ (NSString *)userKeyWithKey:(NSString *)key {
    return
    [@(CPInnerState.shared.loginUser.userId).stringValue stringByAppendingString:key];
}
//MARK:- Add
 + (void)deleteKey:(NSString *)key ofUser:(NSInteger)uid
{
    NSString *key1 = [@(uid).stringValue stringByAppendingString:key];
    [_UserCache removeObjectForKey:key1];
}

//MARK:- Use Source
+ (NSString *)sourceKey:(NSString *)key ofUser:(NSInteger)uid {
    return [@(uid).stringValue stringByAppendingString:key];
}
+ (void)setObject:(id _Nullable)obj forSourceKey:(NSString *)key {
    [_UserCache setObject:obj forKey:key];
}
+ (id)objectForSourceKey:(NSString *)key {
    return [_UserCache objectForKey:key];
}

@end
