//
//  CPImageCaches.h
//  chat-plugin
//
//  Created by Grand on 2019/10/31.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPImageCaches : NSObject

- (instancetype)initWithUid:(NSInteger)uid;

- (nullable id<NSCoding>)objectForKey:(NSString *)key;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
