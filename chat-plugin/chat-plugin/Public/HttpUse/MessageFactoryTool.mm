







#import "MessageFactoryTool.h"
#import "blake2/blake2.h"
#import "key_tool.h"
#import "CPBridge.h"
#import "zlib.h"
#import <secp256k1/secp256k1_recovery.h>
#import <chat_plugin/chat_plugin-Swift.h>
#import "CPInnerState.h"
#import <YYKit/YYKit.h>
#import <CPMessageRecieveHandleProtocol.h>
#import "CPTools.h"

const uint32_t SIGN_SIZE_RECOVER = 65;

BOOL CheckSignature(NCProtoHttpReq *net_msg) {
    if (net_msg.signature.length != SIGN_SIZE_RECOVER) {
        return false;
    }
    std::string hash = CalcHash(net_msg);
    NSData *hash_d = bytes2nsdata(hash);
    NSData *recoverPubkey =  [CPSignWraper recoverPublicKeyWithHash:hash_d signature:net_msg.signature];
    if ([net_msg.pubKey isEqualToData:recoverPubkey]) {
        return YES;
    }
    return NO;
}



std::string CalcHash(NCProtoHttpReq *net_msg) {
    std::string rtn(32, 0);
    blake2b_state hash_state;
    blake2b_init(&hash_state, 32);
    
    blake2b_update(&hash_state, net_msg.pubKey.bytes, net_msg.pubKey.length);
    int64_t time = net_msg.time;
    blake2b_update(&hash_state, &time, sizeof(time));
    
    blake2b_update(&hash_state, nsstring2cstr(net_msg.name), net_msg.name.length);
    blake2b_update(&hash_state, net_msg.data_p.bytes, net_msg.data_p.length);
    
    blake2b_final(&hash_state, (char*)rtn.data(), rtn.size());
    return rtn;
}


void FillSignature(NCProtoHttpReq *net_msg, const std::string& private_key) {
    std::string hash = CalcHash(net_msg);
    NSData *dhash = bytes2nsdata(hash);
    NSData *prikey = bytes2nsdata(private_key);
    NSData *sign = [CPSignWraper signForRecoveryWithHash:dhash privateKey:prikey];
    net_msg.signature = sign;
    assert(sign.length == SIGN_SIZE_RECOVER);
}

NCProtoHttpReq * CreateNetMsgPackFillName(GPBMessage *body, NSData *pubkey) {
    NCProtoHttpReq *pack = NCProtoHttpReq.alloc.init;
    NSString *name = body.descriptor.fullName;
    pack.name = name;
    pack.pubKey = pubkey;
    
    int64_t time = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    pack.time = time;
    pack.data_p = body.data;
    return pack;
}


NCProtoHttpReq *CreateAndSignPack(const std::string &from_public_key,
                                  const std::string &pri_key,
                                  GPBMessage *body
                                  ) {
    
    NSData *pubkey = bytes2nsdata(from_public_key);
    NCProtoHttpReq *pack = CreateNetMsgPackFillName(body, pubkey);
    FillSignature(pack, pri_key);
    return pack;
}

@implementation MessageFactoryTool

@end
