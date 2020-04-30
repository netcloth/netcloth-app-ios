//
//  CPImageCaches.m
//  chat-plugin
//
//  Created by Grand on 2019/10/31.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPImageCaches.h"
#import "NSString+YYAdd.h"
#import <YYKit/YYKit.h>

@interface CPImageCaches ()
@property (nonatomic, strong) YYCache *cache;
@end

@implementation CPImageCaches

- (instancetype)initWithUid:(NSInteger)uid
{
    self = [super init];
    if (self) {
        _cache = [[YYCache alloc] initWithPath:[self pathCacheForUid:uid]];
        
        [_cache.memoryCache setCountLimit:10];
        [_cache.memoryCache setCostLimit:10*1024*1024];
        
//        [_cache.diskCache setCostLimit:300*1024*1024];
        [_cache.diskCache setAutoTrimInterval:60];
                
        _cache.diskCache.customFileNameBlock = ^NSString * _Nonnull(NSString * _Nonnull key) {
            if (key.length > 32) {
                return  key.sha256String;
            }
            return key;
        };
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(false, @"must use initWithUid");
    }
    return self;
}

- (NSString *)pathCacheForUid:(NSInteger)uid {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@(uid).stringValue];
    path = [path stringByAppendingPathComponent:@"MsgImages"];
    return path;
}

- (nullable id<NSCoding>)objectForKey:(NSString *)key {
    return [_cache objectForKey:key];
}

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key {
    [_cache setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [_cache removeObjectForKey:key];
}

@end
