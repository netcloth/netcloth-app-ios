  
  
  
  
  
  
  

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
