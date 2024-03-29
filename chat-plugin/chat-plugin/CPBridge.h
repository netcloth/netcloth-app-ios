







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#include <string>


NS_ASSUME_NONNULL_BEGIN

extern std::string generationAccountPrivatekey();
extern std::string pubkeyFromPrivateKey(std::string privateKey);


extern std::string getPublicKeyFromUser(User *user);
extern std::string decodePrivateKey;
extern std::string getDecodePrivateKeyForUser(User *user, NSString *password);



extern NSString * _Nullable addressForLoginUser(void);
extern NSString * _Nullable compressedHexPubkeyOfLoginUser(void);
extern NSData * _Nullable GetOriginSignHash(NSData *contenthash, NSData *pri_key);

extern NSString * _Nullable addressForUserPrikey(NSData *privateKey);


extern NSString * _Nullable compressedHexPubkeyOfUserPrikey(NSData *privateKey);


extern NSString * _Nullable compressHexpubkey(NSString *hexpubkey);
extern NSString * _Nullable unCompressHexpubkey(NSString *hexCompressPubkey);



extern id decodeMsgByte(CPMessage *cpmsg) DEPRECATED_MSG_ATTRIBUTE("not use v1");


extern NSString *hexStringFromBytes(std::string bytes);
extern std::string bytesFromHexString(NSString * str);


extern NSData *dataHexFromBytes(std::string bytes);
extern std::string bytesHexFromData(NSData *data);



extern NSData *bytes2nsdata(std::string bytes);
extern std::string nsdata2bytes(NSData *data);


extern NSString *bytes2nsstring(std::string bytes);
extern std::string nsstring2bytes(NSString *string);


extern const char *nsstring2cstr(NSString *string);




@interface CPBridge : NSObject

+ (uint64_t)getRandomHash;

+ (std::string)coreEcdhEncodeMsg:(std::string)sourceBytes
                          prikey:(std::string)str_pri_key
                        toPubkey:(std::string)str_pub_key;

+ (std::string)ecdhDecodeMsg:(std::string)encodeBytes
                          prikey:(std::string)str_pri_key
                        toPubkey:(std::string)str_pub_key;


+ (std::string)aesEncodeData:(std::string)sourceBytes
                byPrivateKey:(std::string)privateKey;
+ (NSData *)aesDecodeData:(std::string)encodeData
             byPrivateKey:(std::string)privateKey;



+ (NSString *_Nullable)recoveryHexPubkeyForSign64:(NSString *)hexSign64
                                    contentHash:(NSData *_Nullable)contenthash
                                   judgeHexPubkey:(NSString *)hexpubkey;

@end

NS_ASSUME_NONNULL_END
