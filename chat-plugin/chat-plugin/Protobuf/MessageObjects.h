







#ifndef MessageObjects_h
#define MessageObjects_h


#import "Chat.pbobjc.h"
#import "NetMsg.pbobjc.h"
#import <string>
#import "Contacts.pbobjc.h"



struct MsgPack {
    int length;
    NSData *pack;
    int checksum;
};

const size_t kHeaderLen = 4;
const size_t kChecksumLen = 4;
const size_t kLeastSize = kChecksumLen;

const int8_t kSendHeartInterval = 10;
const int8_t kHeartTimeoutInterval = 30;

BOOL CheckSignature(NCProtoNetMsg *net_msg);
extern int32_t GetAppVersion();


extern  NSString *const kMsg_RegisterReq;
extern  NSString *const kMsg_RegisterRsp;
extern  NSString *const kMsg_Heartbeat;

extern  NSString *const kMsg_Text;
extern  NSString *const kMsg_Audio;
extern  NSString *const kMsg_Image;

extern  NSString *const kMsg_ServerReceipt;

extern  NSString *const kMsg_AppleIdBind;
extern  NSString *const kMsg_AppleIdUnbind;

extern  NSString *const kMsg_CacheMsgReq;
extern  NSString *const kMsg_CacheMsgRsp;



extern NCProtoNetMsg * CreateRegister(const std::string& from_public_key, const std::string &pri_key);
extern NCProtoNetMsg * CreateHeartbeat();

extern NCProtoNetMsg * CreateTextMsg(const std::string &from_public_key,
                              const std::string &to_public_key,
                              const std::string &pri_key,
                              const std::string &content);

extern NCProtoNetMsg * CreateAudioMsg(const std::string &from_public_key,
                               const std::string &to_public_key,
                               const std::string &pri_key,
                               const std::string &content,
                               uint32_t playTime);

extern NCProtoNetMsg * CreateImageMsg(const std::string &from_public_key,
                                      const std::string &to_public_key,
                                      const std::string &pri_key,
                                      NSString *imageHash,
                                      int32_t width,
                                      int32_t height);

extern NCProtoNetMsg *CreateRequestCacheMsg(const std::string &pri_key,
                                            uint32_t rand_id,
                                            uint64_t time,
                                            uint64_t hash,
                                            uint32_t size);

extern NCProtoNetMsg * CreateClientReplyMsg(NCProtoNetMsg * targetMsg);

extern NCProtoNetMsg * CreateBindAppleId(const std::string &pri_key,
                                         NSString *apple_id);

extern NCProtoNetMsg * CreateUnBindAppleId(const std::string &pri_key,
                                           NSString *apple_id);




@interface MessageObjects : NSObject

+ (NSString *_Nullable)messageNameForClass:(Class)cls;
+ (Class _Nullable)messageClassForName:(NSString *)name;

+ (NSData * _Nullable)encodeNetMsg:(NCProtoNetMsg *)pack;
+ (NCProtoNetMsg *_Nullable)decodePackFrom:(NSData *)data;

@end


#endif 
