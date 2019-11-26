







#import <Foundation/Foundation.h>
#import "MessageObjects.h"
#import "blake2/blake2.h"
#import "key_tool.h"
#import "CPBridge.h"
#import "zlib.h"
#import <secp256k1/secp256k1_recovery.h>
#import <chat_plugin/chat_plugin-Swift.h>
#import "CPInnerState.h"


NSString *const kMsg_RegisterReq = @"netcloth.RegisterReq";
NSString *const kMsg_RegisterRsp = @"netcloth.RegisterRsp";
NSString *const kMsg_Heartbeat = @"netcloth.Heartbeat";

NSString *const kMsg_Text = @"netcloth.Text";
NSString *const kMsg_Audio = @"netcloth.Audio";
NSString *const kMsg_Image = @"netcloth.Image";

NSString *const kMsg_ServerReceipt = @"netcloth.ServerReceipt";
NSString *const kMsg_ClientReceipt = @"netcloth.ClientReceipt";

NSString *const kMsg_AppleIdBind = @"netcloth.AppleIdBind";
NSString *const kMsg_AppleIdUnbind = @"netcloth.AppleIdUnbind";

NSString *const kMsg_CacheMsgReq = @"netcloth.CacheMsgReq";
NSString *const kMsg_CacheMsgRsp = @"netcloth.CacheMsgRsp";





std::string CalcHash(NCProtoNetMsg *net_msg) {
    std::string rtn(32, 0);
    blake2b_state hash_state;
    blake2b_init(&hash_state, 32);
    blake2b_update(&hash_state, nsstring2cstr(net_msg.name), net_msg.name.length);
    blake2b_update(&hash_state, net_msg.data_p.bytes, net_msg.data_p.length);
    bool compress = net_msg.compress;
    blake2b_update(&hash_state, &compress, sizeof(compress));
    blake2b_update(&hash_state, net_msg.head.fromPubKey.bytes, net_msg.head.fromPubKey.length);
    blake2b_update(&hash_state, net_msg.head.toPubKey.bytes, net_msg.head.toPubKey.length);
    blake2b_final(&hash_state, (char*)rtn.data(), rtn.size());
    return rtn;
}

const uint32_t SIGN_SIZE_RECOVER = 65;
NSData * GetSignByPrivateKeyRecover(const uint8_t* contenthash, size_t contenthash_len, const std::string pri_key){
    NSData *hash = [NSData dataWithBytes:contenthash length:contenthash_len];
    NSData *prikey = bytes2nsdata(pri_key);
    NSData *recover_serial_sign = [CPSignWraper signForRecoveryWithHash:hash privateKey:prikey];
    return recover_serial_sign;
}


BOOL CheckSignature(NCProtoNetMsg *net_msg) {
    if (net_msg.head.signature.length != SIGN_SIZE_RECOVER) {
        return false;
    }
    std::string hash = CalcHash(net_msg);
    NSData *hash_d = bytes2nsdata(hash);
    NSData *recoverPubkey =  [CPSignWraper recoverPublicKeyWithHash:hash_d signature:net_msg.head.signature];
    if ([net_msg.head.fromPubKey isEqualToData:recoverPubkey]) {
        return YES;
    }
    return NO;
}



void FillSignature(NCProtoNetMsg *net_msg, const std::string& private_key) {
    std::string hash = CalcHash(net_msg);
    NSData *sign = GetSignByPrivateKeyRecover((uint8_t*)hash.data(), hash.size(), private_key);
    net_msg.head.signature = sign;
    assert(sign.length == SIGN_SIZE_RECOVER);
}




NCProtoNetMsg * CreateNetMsgPackFillName(GPBMessage *body, NCProtoHead *head ,bool compress = false) {
    NCProtoNetMsg *pack = NCProtoNetMsg.alloc.init;
    NSString *name = [MessageObjects messageNameForClass:body.class];
    pack.name = name;
    pack.head = head;
    pack.data_p = body.data;
    pack.compress = compress;
    return pack;
}



NCProtoNetMsg * CreateRegister(const std::string& from_public_key, const std::string &pri_key) {

    NCProtoHead *head = NCProtoHead.alloc.init;
    head.fromPubKey = bytes2nsdata(from_public_key);
    

    NCProtoRegisterReq *body = NCProtoRegisterReq.alloc.init;
    body.version = GetAppVersion();
    body.deviceType = NCProtoDeviceType_Ios;
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

NCProtoNetMsg * CreateHeartbeat() {
    NCProtoHead *head = NCProtoHead.alloc.init;
    NCProtoHeartbeat *body = NCProtoHeartbeat.alloc.init;
    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    return pack;
}

NCProtoNetMsg * CreateTextMsg(const std::string &from_public_key,
                              const std::string &to_public_key,
                              const std::string &pri_key,
                              const std::string &content) {

    NCProtoHead *head = NCProtoHead.alloc.init;
    head.fromPubKey = bytes2nsdata(from_public_key);
    head.toPubKey = bytes2nsdata(to_public_key);
    

    NCProtoText *body = NCProtoText.alloc.init;
    body.content = bytes2nsdata(content);
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

NCProtoNetMsg * CreateAudioMsg(const std::string &from_public_key,
                              const std::string &to_public_key,
                              const std::string &pri_key,
                              const std::string &content,
                               uint32_t playTime) {

    NCProtoHead *head = NCProtoHead.alloc.init;
    head.fromPubKey = bytes2nsdata(from_public_key);
    head.toPubKey = bytes2nsdata(to_public_key);
    

    NCProtoAudio *body = NCProtoAudio.alloc.init;
    body.content = bytes2nsdata(content);
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

extern NCProtoNetMsg * CreateImageMsg(const std::string &from_public_key,
                                      const std::string &to_public_key,
                                      const std::string &pri_key,
                                      NSString *imageHash,
                                      int32_t width,
                                      int32_t height) {
    

    NCProtoHead *head = NCProtoHead.alloc.init;
    head.fromPubKey = bytes2nsdata(from_public_key);
    head.toPubKey = bytes2nsdata(to_public_key);
    

    NCProtoImage *body = NCProtoImage.alloc.init;
    body.id_p = imageHash;
    body.width = width;
    body.height = height;
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

NCProtoNetMsg *CreateRequestCacheMsg(const std::string &pri_key,
                                     uint32_t rand_id,
                                     uint64_t time,
                                     uint64_t hash,
                                     uint32_t size) {
    
    std::string from_public_key = GetPublicKeyByPrivateKey(pri_key);

    NCProtoHead *head = NCProtoHead.alloc.init;
    head.fromPubKey = bytes2nsdata(from_public_key);
    

    NCProtoCacheMsgReq *body = NCProtoCacheMsgReq.alloc.init;
    body.roundId = rand_id;
    body.time = time;
    body.hash_p = hash;
    body.size = size;
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

NCProtoNetMsg * CreateClientReplyMsg(NCProtoNetMsg * targetMsg)
{
    NCProtoHead *head = targetMsg.head;
    NCProtoClientReceipt *body = NCProtoClientReceipt.alloc.init;
    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    return pack;
}



NCProtoNetMsg * CreateBindAppleId(const std::string &pri_key,
                              NSString *apple_id) {

    NCProtoHead *head = NCProtoHead.alloc.init;
    std::string from_public_key = GetPublicKeyByPrivateKey(pri_key);
    head.fromPubKey = bytes2nsdata(from_public_key);
    

    NCProtoAppleIdBind *body = NCProtoAppleIdBind.alloc.init;
    body.appleId = apple_id;
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}

NCProtoNetMsg * CreateUnBindAppleId(const std::string &pri_key,
                              NSString *apple_id) {

    NCProtoHead *head = NCProtoHead.alloc.init;
    std::string from_public_key = GetPublicKeyByPrivateKey(pri_key);
    head.fromPubKey = bytes2nsdata(from_public_key);
    

    NCProtoAppleIdUnbind *body = NCProtoAppleIdUnbind.alloc.init;
    body.appleId = apple_id;
    

    NCProtoNetMsg *pack = CreateNetMsgPackFillName(body, head);
    FillSignature(pack, pri_key);
    return pack;
}




int32_t GetAppVersion() {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSArray *vers = [app_Version componentsSeparatedByString:@"."];
    int32_t v = 0;
    v += ([vers[0] intValue] * 10000);
    v += ([vers[1] intValue] * 100);
    v += ([vers[2] intValue] * 1);
    return v;
}



void TestSignLogic() {
    
}




NSMutableDictionary *_PBNameClassMapper;
@implementation MessageObjects

+ (void)load {
    if (_PBNameClassMapper) {
        return;
    }
    _PBNameClassMapper = NSMutableDictionary.dictionary;
    _PBNameClassMapper[kMsg_RegisterReq] = NCProtoRegisterReq.class;
    _PBNameClassMapper[kMsg_Heartbeat] = NCProtoHeartbeat.class;
    _PBNameClassMapper[kMsg_RegisterRsp] = NCProtoRegisterRsp.class;
    
    _PBNameClassMapper[kMsg_Text] = NCProtoText.class;
    _PBNameClassMapper[kMsg_Audio] = NCProtoAudio.class;
    _PBNameClassMapper[kMsg_Image] = NCProtoImage.class;
    
    _PBNameClassMapper[kMsg_ServerReceipt] = NCProtoServerReceipt.class;
    _PBNameClassMapper[kMsg_ClientReceipt] = NCProtoClientReceipt.class;
    
    _PBNameClassMapper[kMsg_AppleIdBind] = NCProtoAppleIdBind.class;
    _PBNameClassMapper[kMsg_AppleIdUnbind] = NCProtoAppleIdUnbind.class;
    
    _PBNameClassMapper[kMsg_CacheMsgReq] = NCProtoCacheMsgReq.class;
    _PBNameClassMapper[kMsg_CacheMsgRsp] = NCProtoCacheMsgRsp.class;
    
}

+ (NSString *)messageNameForClass:(Class)cls {
    id find;
    for (NSString *key in _PBNameClassMapper) {
        find = _PBNameClassMapper[key];
        if ([find isEqual: cls]) {
            return key;
        }
    }
    return nil;
}

+ (Class)messageClassForName:(NSString *)name {
    return _PBNameClassMapper[name];
}

+ (NSData * _Nullable)encodeNetMsg:(NCProtoNetMsg *)pack {
    MsgPack bytes;
    bytes.pack = pack.data;
    uint32_t checksum = adler32(1, (const Byte *)bytes.pack.bytes, bytes.pack.length);
    bytes.checksum = checksum;
    bytes.length = bytes.pack.length + kChecksumLen;
    
    int total = bytes.length + kHeaderLen;
    char *buff = (char *)malloc(sizeof(char) * (total + 10));
    

    __uint32_t len = htonl(bytes.length);
    memcpy(buff, &len, kHeaderLen);

    memcpy(buff + kHeaderLen, bytes.pack.bytes, bytes.pack.length);

    __uint32_t checksum_nl= htonl(bytes.checksum);
    memcpy(buff + kHeaderLen + bytes.pack.length, &checksum_nl, kChecksumLen);
    
    NSData *data = [NSData dataWithBytes:buff length:total];
    free(buff);
    return data;
}

+ (NCProtoNetMsg *_Nullable)decodePackFrom:(NSData *)data {
    
    if (!data ||
        ![data isKindOfClass:NSData.class] ||
        data.length == 0 ||
        data == NULL ||
        [data isEqual: NSNull.null]) {
        NSLog(@"coremsg-decode-nil");
        return nil;
    }
    
    char *buffer =  (char *)data.bytes;
    if (buffer == NULL) {
        NSLog(@"coremsg-decode-nil-1");
        return nil;
    }
    
    MsgPack pack;
    memcpy(&pack.length, buffer, kHeaderLen);
    
    uint32_t body_check_len = ntohl(pack.length);
    if (body_check_len+kHeaderLen > data.length) {
        NSLog(@"coremsg-decode-nil-2");
        return nil;
    }
    
    uint32_t body_len = body_check_len - kChecksumLen;
    
    NSRange body_range = NSMakeRange(kHeaderLen, body_len);
    NSData *body_data = [data subdataWithRange:body_range];
    pack.pack = body_data;
    




    
    memcpy(&pack.checksum, buffer+kHeaderLen + body_len, kChecksumLen);
    
    uint32_t checksum_cal = adler32(1, (const Byte *)pack.pack.bytes, pack.pack.length);
    uint32_t checksum_recieve = ntohl(pack.checksum);
    
    if (checksum_cal != checksum_recieve) {
        NSLog(@"coremsg-checksum-fail");
        return nil;
    }
        
    NSError *err;
    NCProtoNetMsg *nm = [NCProtoNetMsg parseFromData:pack.pack error:&err];
    if (err) {
        NSLog(@"coremsg-parseFromData-err");
        return nil;
    }

    if ([self shouldCheckSign:nm]) {
        BOOL valid = CheckSignature(nm);
        if (!valid) {
            NSLog(@"coremsg-CheckSignature-err");
            return nil;
        }
    }
    
    
    return nm;
}

+ (BOOL)shouldCheckSign:(NCProtoNetMsg *)msg {
    
    if ([msg.name isEqualToString:kMsg_Text]) {
        return YES;
    }
    if ([msg.name isEqualToString:kMsg_Audio]) {
        return YES;
    }
    if ([msg.name isEqualToString:kMsg_Image]) {
        return YES;
    }
    return false;
}

@end
