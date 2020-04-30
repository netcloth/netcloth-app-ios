//
//  OC_Chat_Plugin_Bridge.m
//  chat
//
//  Created by Grand on 2019/8/4.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "OC_Chat_Plugin_Bridge.h"

#import <chat_plugin/chat_plugin.h>
#import <chat_plugin/CPBridge.h>

@implementation OC_Chat_Plugin_Bridge

+ (NSInteger)byteLengthOfHex:(NSString *)str {
    std::string to = bytesFromHexString(str);
    return to.length();
}

+ (NSString *)addressOfLoginUser {
    NSString *address = addressForLoginUser();
    return address;
}

+ (NSString * _Nullable)compressedHexStrPubkeyOfLoginUser {
    NSString *pbkey = compressedHexPubkeyOfLoginUser();
    return pbkey;
}

//delete last index v
+ (NSData * _Nullable)signedLoginUserToContentHash:(NSData *)contenthash {
    if (contenthash.length == 0) {
        return nil;
    }
    
    User *user = CPAccountHelper.loginUser;
    std::string privateKey = getDecodePrivateKeyForUser(user, user.password);
    NSData *oriData = bytes2nsdata(privateKey);
    NSData *sign = GetOriginSignHash(contenthash, oriData);
    
    if(sign.length == 65) {
        return [sign subdataWithRange:NSMakeRange(0, 64)];
    }
    
    return sign;
}

+ (NSData * _Nullable)privateKeyOfLoginedUser {
    User *user = CPAccountHelper.loginUser;
    std::string privateKey = getDecodePrivateKeyForUser(user, user.password);
    return bytes2nsdata(privateKey);
}

+ (uint64_t)getRandomSign {
    return [CPBridge getRandomHash];
}

//MARK:- Group
+ (NSData *)createPrivatekey {
    std::string privateKey = generationAccountPrivatekey();
    NSData *oriData = bytes2nsdata(privateKey);
    return oriData;
}

+ (NSString *)hexPublicKeyFromPrivatekey:(NSData *)oriPrivateKey {
    std::string prikey = nsdata2bytes(oriPrivateKey);
    std::string calPubkey = pubkeyFromPrivateKey(prikey);
    return hexStringFromBytes(calPubkey);
}


+ (NSString * _Nullable)addressOfUserPrivateKey:(NSData *)prikey {
    return addressForUserPrikey(prikey);
}

+ (NSString * _Nullable)compressedHexStrPubkeyOfUserPrivateKey:(NSData *)prikey
{
    return compressedHexPubkeyOfUserPrikey(prikey);
}
+ (NSData * _Nullable)signedContentHash:(NSData * _Nullable)contenthash
                       ofUserPrivateKey:(NSData *)prikey
{
    NSData *sign = GetOriginSignHash(contenthash, prikey);
    if(sign.length == 65) {
        return [sign subdataWithRange:NSMakeRange(0, 64)];
    }
    return sign;
}

//MARK:- v1.1.1
+ (NSString * _Nullable)compressedHexStrPubkeyOfHexPubkey:(NSString *)hexpubkey {
    return compressHexpubkey(hexpubkey);
}
+ (NSString * _Nullable)unCompressedHexStrPubkeyOfCompressHexPubkey:(NSString *)hexCompressedPubkey {
    return  unCompressHexpubkey(hexCompressedPubkey);
}

+ (NSData *)dataFromHexString:(NSString *)hexstr {
    std::string bytes = bytesFromHexString(hexstr);
    return bytes2nsdata(bytes);
}

//MARK:- v1.1.3
+ (NSString *_Nullable)recoveryHexPubkeyForSign64:(NSString *)hexSign64
                                      contentHash:(NSData *_Nullable)contenthash
                                   judgeHexPubkey:(NSString *)hexpubkey {
    return [CPBridge recoveryHexPubkeyForSign64:hexSign64 contentHash:contenthash judgeHexPubkey:hexpubkey];
}

@end
