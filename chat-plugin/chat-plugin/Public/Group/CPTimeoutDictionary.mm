  
  
  
  
  
  
  

#import "CPTimeoutDictionary.h"
#import "CPGroupChatHelper.h"
#import "CPInnerState.h"

@implementation CPTimeoutDictionary {
    NSMutableDictionary *_dictionary;
}

#pragma mark Required NSDictionary overrides

- (instancetype)initWithObjects:(const id [])objects
                        forKeys:(const id<NSCopying> [])keys
                          count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects
                                                           forKeys:keys
                                                             count:count];
    }
    return self;
}

- (NSUInteger)count {
    return [_dictionary count];
}

- (id)objectForKey:(id)aKey {
    return [_dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    if (_dictionary == nil) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return [_dictionary keyEnumerator];
}

#pragma mark Required NSMutableDictionary overrides
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (_dictionary == nil) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    [_dictionary setObject:anObject forKey:aKey];
    if (anObject != nil) {
        [self startTimeoutKey:aKey];
    }
}

- (void)removeObjectForKey:(id)aKey {
    [_dictionary removeObjectForKey:aKey];
}

#pragma mark Extra things hooked

- (id)copyWithZone:(NSZone *)zone {
    if (_dictionary == nil) {
        return [[NSMutableDictionary allocWithZone:zone] init];
    }
    return [_dictionary copyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    if (_dictionary == nil) {
        return [[NSMutableDictionary allocWithZone:zone] init];
    }
    return [_dictionary mutableCopyWithZone:zone];
}

  
  
- (id)objectForKeyedSubscript:(id)key {
    return [_dictionary objectForKeyedSubscript:key];
}

  
  
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (_dictionary == nil) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    [_dictionary setObject:obj forKeyedSubscript:key];
    if (obj != nil) {
        [self startTimeoutKey:key];
    }
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key,
                                                                id obj,
                                                                BOOL *stop))block {
    [_dictionary enumerateKeysAndObjectsUsingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts
                                usingBlock:(void (NS_NOESCAPE ^)(id key,
                                                                 id obj,
                                                                 BOOL *stop))block {
    [_dictionary enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}


  
- (void)startTimeoutKey:(id<NSCopying>)key {
    [self performSelector:@selector(onTimeoutActionKey:) withObject:key afterDelay:20];
}

- (void)onTimeoutActionKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    @try {
        MsgResponseBack back = (MsgResponseBack)obj;
        if (back != nil) {
            NSMutableDictionary *response = NSMutableDictionary.dictionary;
            response[@"code"] = @(-1001);    
            response[@"msg"] = @"null.timeout";
            [CPInnerState.shared asynDoTask:^{
                back(response);
            }];
        }
        [self removeObjectForKey:key];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}



@end
