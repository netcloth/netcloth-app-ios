







#import "TestObj.h"
#import <YYKit/YYKit.h>
#import <SBJson5/SBJson5.h>
#import "OC_Chat_Plugin_Bridge.h"

@implementation TestObj

+ (void)testRandom {
    
    for (int i = 0; i < 1000; i++) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"test random %zi",i);
            [weak_self testRandom1_1];
        });
    }
}

+ (void)testRandom1_1 {
    NSMutableArray *mArr = NSMutableArray.array;
    NSData *prikey;
    for (int i = 0 ; i < 10000; i++) {
        prikey = [OC_Chat_Plugin_Bridge createPrivatekey];
        [mArr addObject:prikey];
    }
    
    
    NSInteger mArrCount = [mArr count];
    NSMutableSet *mSet = [NSMutableSet setWithArray:mArr];
    NSInteger mSetCount = [mSet count];
    if (mArrCount != mSetCount) {
        NSAssert(false, @"same error");
    }
}


+ (void)sign {
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    
    NSString *utc =
    [NSDate.date stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" timeZone:tz locale:local];
    
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    
    NSMutableDictionary * subDic = NSMutableDictionary.dictionary;
    subDic[@"expiration"] = @"2019-12-16T13:59:59Z";
    
    NSMutableDictionary * service_info = NSMutableDictionary.dictionary;
    service_info[@"address"] = @"nch19vnsnnseazkyuxgkt0098gqgvfx0wxmv96479m";
    service_info[@"type"] = @2;
    
    
    subDic[@"service_info"] = service_info;
    subDic[@"user_address"] = @"nch1n7e0u4k7gsu4l27ugvr88pu32qc5qfusx86eh5";
    
    dic[@"params"] = subDic;

    
    SBJson5Writer *writer = [SBJson5Writer writerWithMaxDepth:20 humanReadable:false sortKeys:true];
    NSData * jsonData = [writer dataWithObject:subDic];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *datash = jsonData.sha256String;
    NSString *strhash = jsonStr.sha256String;
    printf(@"1");
}

@end
