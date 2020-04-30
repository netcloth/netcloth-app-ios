//
//  WKWebView+Hook.m
//  chat
//
//  Created by Grand on 2020/3/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import "WKWebView+Hook.h"
#import <objc/runtime.h>

@implementation WKWebView (Hook)

NSArray *list;
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method origin = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method hook = class_getClassMethod(self, @selector(cdz_handlesURLScheme:));
        method_exchangeImplementations(origin, hook);
        
        list = @[@"http", @"https", @"ws",@"socks5"];
    });
}

+ (BOOL)cdz_handlesURLScheme:(NSString *)urlScheme {
    if ([self isInWhiteList:urlScheme]) {
        return NO;
    }
    NSLog(@"<< 代理协议不支持 %@",urlScheme);
    return [self cdz_handlesURLScheme:urlScheme];
}


+ (BOOL)isInWhiteList:(NSString *)urlScheme {
    return [list containsObject:urlScheme];
}


@end
