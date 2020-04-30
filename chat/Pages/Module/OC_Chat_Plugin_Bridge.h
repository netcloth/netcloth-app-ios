//
//  OC_Chat_Plugin_Bridge.h
//  chat
//
//  Created by Grand on 2019/8/4.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OC_Chat_Plugin_Bridge : NSObject

+ (NSInteger)byteLengthOfHex:(NSString *)str;

//MARK:-
+ (NSString * _Nullable)addressOfLoginUser;
+ (NSString * _Nullable)compressedHexStrPubkeyOfLoginUser;

/// sign 64 bytes
+ (NSData * _Nullable)signedLoginUserToContentHash:(NSData * _Nullable)contenthash;

+ (NSData * _Nullable)privateKeyOfLoginedUser;

+ (uint64_t)getRandomSign;



//MARK:- For Group
+ (NSData *)createPrivatekey;
+ (NSString *)hexPublicKeyFromPrivatekey:(NSData *)oriPrivateKey;


+ (NSString * _Nullable)addressOfUserPrivateKey:(NSData *)prikey;
+ (NSString * _Nullable)compressedHexStrPubkeyOfUserPrivateKey:(NSData *)prikey;

/// sign 64 bytes
+ (NSData * _Nullable)signedContentHash:(NSData * _Nullable)contenthash
                       ofUserPrivateKey:(NSData *)prikey;

//MARK:- v1.1.1
+ (NSString * _Nullable)compressedHexStrPubkeyOfHexPubkey:(NSString *)hexpubkey;
+ (NSString * _Nullable)unCompressedHexStrPubkeyOfCompressHexPubkey:(NSString *)hexCompressedPubkey;

+ (NSData *)dataFromHexString:(NSString *)hexstr;

//MARK:- v1.1.3
+ (NSString *_Nullable)recoveryHexPubkeyForSign64:(NSString *)hexSign64
                                      contentHash:(NSData *_Nullable)contenthash
                                   judgeHexPubkey:(NSString *)hexpubkey;


@end

NS_ASSUME_NONNULL_END
