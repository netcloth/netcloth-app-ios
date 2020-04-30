//
//  UserSettings.h
//  chat-plugin
//
//  Created by Grand on 2019/9/18.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 asign to login user
 */
@interface UserSettings : NSObject

+ (void)setObject:(id _Nullable)obj forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)deleteKey:(NSString *)key ofUser:(NSInteger)uid;

//MARK:- Use Source
+ (NSString *)sourceKey:(NSString *)key ofUser:(NSInteger)uid;
+ (void)setObject:(id _Nullable)obj forSourceKey:(NSString *)key;
+ (id)objectForSourceKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
