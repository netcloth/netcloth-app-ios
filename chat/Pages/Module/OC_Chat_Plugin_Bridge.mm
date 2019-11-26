







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

@end
