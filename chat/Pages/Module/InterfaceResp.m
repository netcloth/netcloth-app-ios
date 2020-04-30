//
//  InterfaceResp.m
//  chat
//
//  Created by Grand on 2019/11/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "InterfaceResp.h"
#import <YYKit/YYKit.h>

@implementation IPALNode
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"endpoints" : IPALServiceAddress.class};
}

- (IPALServiceAddress * _Nullable)cIpalEnd {
    for (IPALServiceAddress *address in _endpoints) {
        if ([address.type isEqualToString:@"1"]) {
            return address;
        }
    }
    return nil;
}

- (IPALServiceAddress * _Nullable)aIpal {
    for (IPALServiceAddress *address in _endpoints) {
        if ([address.type isEqualToString:@"3"] &&
            address.endpoint.length > 0) {
            return address;
        }
    }
    return nil;
}

@end

@implementation IPALServiceAddress
@end

@implementation ChainAssets
@end
