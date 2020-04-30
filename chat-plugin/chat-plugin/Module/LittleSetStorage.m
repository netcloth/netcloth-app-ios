//
//  LittleSetStorage.m
//  chat-plugin
//
//  Created by Grand on 2019/10/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "LittleSetStorage.h"

#define Set_LOCK(...) dispatch_semaphore_wait(_setlock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_setlock);

@implementation LittleSetStorage
{
    NSMutableSet *_Set;
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
        _Set = NSMutableSet.set;
        _setlock = dispatch_semaphore_create(1);
    }
    return self;
}

- (BOOL)containsObject:(id)anObject
{
    Set_LOCK(BOOL c = [_Set containsObject:anObject]) return c;
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
