







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#include <string>

NS_ASSUME_NONNULL_BEGIN


extern std::string getPublicKeyFromUser(User *user);
extern std::string getDecodePrivateKeyForUser(User *user, NSString *password);
extern std::string decodePrivateKey;


extern NSString * _Nullable addressForLoginUser(void);
extern NSString * _Nullable compressedHexPubkeyOfLoginUser(void);
extern NSData * _Nullable GetOriginSignHash(NSData *contenthash, NSData *pri_key);



extern id decodeMsgByte(CPMessage *cpmsg);


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

@end

NS_ASSUME_NONNULL_END
