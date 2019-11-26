







#import "TestObj.h"
#import <YYKit/YYKit.h>
#import <SBJson5/SBJson5.h>
@implementation TestObj

+ (void)sign {
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    
    NSString *utc =
    [NSDate.date stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" timeZone:tz locale:local];
    
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    
    NSMutableDictionary * subDic = NSMutableDictionary.dictionary;
    subDic[@"expiration"] = @"2019-11-11T16:34:29.269295Z";
    
    NSMutableDictionary * service_info = NSMutableDictionary.dictionary;
    service_info[@"address"] = @"nch19vnsnnseazkyuxgkt0098gqgvfx0wxmv96479m";
    service_info[@"type"] = @1;
    
    
    subDic[@"service_info"] = service_info;
    subDic[@"user_address"] = @"nch12dzjq3u2ufkdaar4uwy75evejygyge09m954zd";
    
    dic[@"params"] = subDic;
    
    SBJson5Writer *writer = [SBJson5Writer writerWithMaxDepth:20 humanReadable:false sortKeys:true];
    NSData * jsonData = [writer dataWithObject:subDic];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *datash = jsonData.sha256String;
    NSString *strhash = jsonStr.sha256String;
    printf(@"1");
}

@end
