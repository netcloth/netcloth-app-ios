







#import "InterfaceResp.h"
#import <YYKit/YYKit.h>

@implementation IPALNode
+ (NSDictionary *)modelContainerPropertyGenericClass {

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

@end

@implementation IPALServiceAddress
@end

@implementation ChainAssets
@end
