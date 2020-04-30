







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface UserSettings : NSObject

+ (void)setObject:(id _Nullable)obj forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)deleteKey:(NSString *)key ofUser:(NSInteger)uid;


+ (NSString *)sourceKey:(NSString *)key ofUser:(NSInteger)uid;
+ (void)setObject:(id _Nullable)obj forSourceKey:(NSString *)key;
+ (id)objectForSourceKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
