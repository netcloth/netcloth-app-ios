  
  
  
  
  
  
  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LittleSetStorage<ObjectType> : NSObject

- (BOOL)containsObject:(ObjectType)anObject;

- (void)addObject:(ObjectType)object;
- (void)addObjectsFromArray:(NSArray<ObjectType> *)array;

- (void)removeObject:(ObjectType)object;
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
