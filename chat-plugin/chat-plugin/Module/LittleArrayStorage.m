  
  
  
  
  
  
  

#import "LittleArrayStorage.h"

#define Set_LOCK(...) dispatch_semaphore_wait(_setlock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_setlock);

@implementation LittleArrayStorage
{
    NSMutableArray *_Set;
    dispatch_semaphore_t _setlock;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self.class);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Set = NSMutableArray.array;
        _setlock = dispatch_semaphore_create(1);
    }
    return self;
}

- (BOOL)containsObject:(id)anObject
{
    Set_LOCK(BOOL c = [_Set containsObject:anObject]) return c;
}

- (id)getObjectBy:(BOOL (^)(id))filter {
    Set_LOCK(
    __block id find = nil;
    [self->_Set enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(filter(obj)) {
            find = obj;
            *stop = true;
        }
    }];
             )
    return find;
}


- (void)addObject:(id)object {
    Set_LOCK([_Set addObject:object])
}

- (void)addObjectsFromArray:(NSArray<id> *)array {
    Set_LOCK([_Set addObjectsFromArray:array])
}

- (void)removeObject:(id)object {
    Set_LOCK([_Set removeObject:object])
}

- (void)removeAllObjects {
    Set_LOCK([_Set removeAllObjects])
}

@end
