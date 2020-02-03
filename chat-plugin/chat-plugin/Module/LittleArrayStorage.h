  
  
  
  
  
  
  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LittleArrayStorage<ObjectType> : NSObject

- (BOOL)containsObject:(ObjectType)anObject;

- (id)getObjectBy:(BOOL (^)(id))filter;

- (void)addObject:(ObjectType)object;
- (void)addObjectsFromArray:(NSArray<ObjectType> *)array;

- (void)removeObject:(ObjectType)object;
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
