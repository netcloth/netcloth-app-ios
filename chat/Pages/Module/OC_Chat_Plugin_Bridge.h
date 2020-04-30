







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OC_Chat_Plugin_Bridge : NSObject

+ (NSInteger)byteLengthOfHex:(NSString *)str;


+ (NSString * _Nullable)addressOfLoginUser;
+ (NSString * _Nullable)compressedHexStrPubkeyOfLoginUser;


+ (NSData * _Nullable)signedLoginUserToContentHash:(NSData * _Nullable)contenthash;

+ (NSData * _Nullable)privateKeyOfLoginedUser;

+ (uint64_t)getRandomSign;




+ (NSData *)createPrivatekey;
+ (NSString *)hexPublicKeyFromPrivatekey:(NSData *)oriPrivateKey;


+ (NSString * _Nullable)addressOfUserPrivateKey:(NSData *)prikey;
+ (NSString * _Nullable)compressedHexStrPubkeyOfUserPrivateKey:(NSData *)prikey;


+ (NSData * _Nullable)signedContentHash:(NSData * _Nullable)contenthash
                       ofUserPrivateKey:(NSData *)prikey;


+ (NSString * _Nullable)compressedHexStrPubkeyOfHexPubkey:(NSString *)hexpubkey;
+ (NSString * _Nullable)unCompressedHexStrPubkeyOfCompressHexPubkey:(NSString *)hexCompressedPubkey;

+ (NSData *)dataFromHexString:(NSString *)hexstr;


+ (NSString *_Nullable)recoveryHexPubkeyForSign64:(NSString *)hexSign64
                                      contentHash:(NSData *_Nullable)contenthash
                                   judgeHexPubkey:(NSString *)hexpubkey;


@end

NS_ASSUME_NONNULL_END
