//
//  GTableDelegateContainer.m
//  Demo
//
//  Created by Grand on 2018/9/25.
//  Copyright © 2018年 G.Y. All rights reserved.
//

#import "GTableDelegateContainer.h"

@interface GTableDelegateContainer ()

@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation GTableDelegateContainer

- (void)dealloc
{
    NSLog(@"dealloc %s", __func__);
}

- (void)addDelegate:(id)delegate {
    if (!delegate) {
        return;
    }
    id v = [NSValue valueWithNonretainedObject:delegate];
    [self.delegates addObject:v];
}

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = @[].mutableCopy;
    }
    return _delegates;
}


- (id)forwardingTargetForSelector:(SEL)aSelector {
    for (NSValue *v in self.delegates) {
        if (v.nonretainedObjectValue && [v.nonretainedObjectValue respondsToSelector:aSelector]) {
            return v.nonretainedObjectValue;
        }
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    for (NSValue *v in self.delegates) {
        if (v.nonretainedObjectValue && [v.nonretainedObjectValue respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

@end
