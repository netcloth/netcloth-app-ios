







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OC_Chat_Plugin_Bridge : NSObject

+ (NSInteger)byteLengthOfHex:(NSString *)str;

+ (NSString * _Nullable)addressOfLoginUser;

+ (NSString * _Nullable)compressedHexStrPubkeyOfLoginUser;

+ (NSData * _Nullable)signedLoginUserToContentHash:(NSData * _Nullable)contenthash;


@end

NS_ASSUME_NONNULL_END
