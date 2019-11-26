







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserSettings : NSObject

+ (void)setObject:(id)obj forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)deleteKey:(NSString *)key ofUser:(NSInteger)uid;

@end

NS_ASSUME_NONNULL_END
