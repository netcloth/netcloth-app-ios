







#import "CPBridge.h"
#import "CPDataModel+secpri.h"
#include "key_tool.h"
#include "string_tools.h"
#include "audio_format_tool.h"
#import "CPInnerState.h"
#import <chat_plugin/chat_plugin-Swift.h>
#include "key_tool.h"
#import <YYKit/YYKit.h>

std::string decodePrivateKey;


std::string generationAccountPrivatekey() {
    std::string prikey;
    for (int i = 0; i < 1024; i++) {
        prikey =  CreatePrivateKey();
        NSData *keyData = bytes2nsdata(prikey);
        if ([CPWalletWraper verifyPrivateKeyWithPrivateKey:keyData] == false) {
            continue;
        }
        return prikey;
    }
    return prikey;
}

std::string pubkeyFromPrivateKey(std::string privateKey) {
    std::string publickey = GetPublicKeyByPrivateKey(privateKey);
    return publickey;
}


std::string getPublicKeyFromUser(User *user) {
    NSString *pbkey = user.publicKey;
    std::string pbkey_ = bytesFromHexString(pbkey);
    return pbkey_;
}


std::string getDecodePrivateKeyForUser(User *user, NSString *password) {
    
    if (decodePrivateKey.length() == kPrivateKeySize) {
        return decodePrivateKey;
    }
    
    NSError *err;
    NSData *oriPk =
    [NCKeyStore.shared nsdataPrikeyOfLoginUser:password error:&err];
    if (err) {
        return "";
    };
    std::string deprikey = nsdata2bytes(oriPk);
    decodePrivateKey = deprikey;
    return deprikey;
}



NSString *addressForLoginUser(void) {
    
    User *loginUser = CPInnerState.shared.loginUser;
    std::string prikey =
    getDecodePrivateKeyForUser(loginUser, loginUser.password);
    
    NSData *pkData = bytes2nsdata(prikey);
    return addressForUserPrikey(pkData);
    
}

NSString *compressedHexPubkeyOfLoginUser(void) {
    User *loginUser = CPInnerState.shared.loginUser;
    if (!loginUser) {
        return nil;
    }
    std::string loginPrikey = getDecodePrivateKeyForUser(loginUser, loginUser.password);
    return compressedHexPubkeyOfUserPrikey(bytes2nsdata(loginPrikey));
    
}

NSData * GetOriginSignHash(NSData *contenthash, NSData *pri_key) {
    NSData *recover_serial_sign = [CPSignWraper OrignSignForRecoveryWithHash:contenthash privateKey:pri_key];
    return recover_serial_sign;
}

NSString * _Nullable addressForUserPrikey(NSData *privateKey) {
    NSError *err;
    NSString *address = [CPAddressWraper addressForPrivateKey:privateKey error:&err];
    if (err) {
        return nil;
    }
    return address;
}

NSString * _Nullable compressedHexPubkeyOfUserPrikey(NSData *privateKey) {
    std::string str_pri_key = nsdata2bytes(privateKey);
    std::string pubkey = GetPublicKeyByPrivateKey(str_pri_key);
    NSData *oridata = bytes2nsdata(pubkey);
    
    NSError *err;
    NSString *hexPubkeyCompressed = [CPAddressWraper compressedHexPubkey:oridata error:&err];
    if (err || [NSString cp_isEmpty:hexPubkeyCompressed]) {
        return nil;
    }
    return hexPubkeyCompressed;
}


NSString * _Nullable compressHexpubkey(NSString *hexpubkey) {
    
    if (([hexpubkey hasPrefix:@"02"] || [hexpubkey hasPrefix:@"03"]) &&
        hexpubkey.length == 66) {
        return hexpubkey;
    }
    
    std::string pubkey = bytesFromHexString(hexpubkey);
    NSData *oridata = bytes2nsdata(pubkey);
    
    NSError *err;
    NSString *hexPubkeyCompressed = [CPAddressWraper compressedHexPubkey:oridata error:&err];
    if (err || [NSString cp_isEmpty:hexPubkeyCompressed]) {
        return nil;
    }
    return hexPubkeyCompressed;
}

NSString * _Nullable unCompressHexpubkey(NSString *hexCompressPubkey) {
    
    if (([hexCompressPubkey hasPrefix:@"04"]) &&
        hexCompressPubkey.length == 130) {
        return hexCompressPubkey;
    }
    
    std::string pubkey = bytesFromHexString(hexCompressPubkey);
    NSData *oridata = bytes2nsdata(pubkey);
    
    NSError *err;
    NSString *hexPubkeyUnCom = [CPAddressWraper unCompressedHexPubkey:oridata error:&err];
    if (err || [NSString cp_isEmpty:hexPubkeyUnCom]) {
        return nil;
    }
    return hexPubkeyUnCom;
}



NSString *hexStringFromBytes(std::string bytes)
{
    std::string str = Byte2HexAsc(bytes);
    return [NSString stringWithCString:str.c_str() encoding:NSUTF8StringEncoding];
}

std::string bytesFromHexString(NSString * str)
{
    char *p = (char *)[str UTF8String];
    std::string ss(p,str.length); 
    return  HexAsc2ByteString(ss);
}

NSData *dataHexFromBytes(std::string bytes)
{
    std::string str = Byte2HexAsc(bytes);
    return  [NSData dataWithBytes:str.c_str() length:str.length()];
}

std::string bytesHexFromData(NSData *data)
{
    char*p =  (char *)data.bytes;
    std::string ss(p,data.length);
    std::string byte =  HexAsc2ByteString(ss);
    return byte;
}


NSData *bytes2nsdata(std::string bytes)
{
    NSData *data = [NSData dataWithBytes:bytes.c_str() length:bytes.length()];
    return data;
}

std::string nsdata2bytes(NSData *data)
{
    std::string str((char *)data.bytes, data.length);
    return str;
}


NSString *bytes2nsstring(std::string bytes) {
    NSData *data = [NSData dataWithBytes:bytes.c_str() length:bytes.length()];
    NSString* msgContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return msgContent;
}

std::string nsstring2bytes(NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    std::string r = std::string((char *)data.bytes, data.length);
    return r;
}
const char *nsstring2cstr(NSString *string) {
    const char *p = [string cStringUsingEncoding:NSUTF8StringEncoding];
    return p;
}



id decodeMsgByte(CPMessage *cpmsg)
{
    
    if (cpmsg.msgData.length < 16) {
        return nil;
    }
    
    std::string bytes;
    if (cpmsg.msgType == MessageTypeImage) {
        bytes = nsdata2bytes(cpmsg.msgData);
    } else {
        bytes = bytesHexFromData(cpmsg.msgData);
    }
    
    std::string msg_org = bytes;
    std::string iv = msg_org.substr(0,16);
    std::string msg_tmp = msg_org.substr(16,bytes.length() - 16);
    
    
    std::string frompbkey;
    if ([cpmsg.senderPubKey isEqualToString:CPInnerState.shared.loginUser.publicKey]) {
        frompbkey = bytesFromHexString(cpmsg.toPubkey);
    } else {
        frompbkey = bytesFromHexString(cpmsg.senderPubKey);
    }
    
    std::string meprikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    std::string ecc_shared_key = GetEcdhKey(frompbkey, meprikey);
    
    std::string msg_decoded;
    @try  {
        std::string out;
        
        std::string content = msg_tmp;
        BOOL decR = AesDecode(ecc_shared_key, iv, content, out);
        NSLog(@"解密结果：%@",decR ? @"成功":@"失败");
        msg_decoded = out;
    }
    @finally {
        
        if (cpmsg.msgType == MessageTypeImage) {
            NSData *data = bytes2nsdata(msg_decoded);
            return data;
        }
        
        else if (cpmsg.msgType == MessageTypeText) {
            NSData *data = [NSData dataWithBytes:msg_decoded.c_str() length:msg_decoded.length()];
            NSString* msgContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return msgContent;
        }
        else if (cpmsg.msgType == MessageTypeAudio) {
            AudioFormatTool audio_tool = AudioFormatTool(0, msg_decoded, true);
            cpmsg.audioTimes = audio_tool.GetSec() + 1;
            std::string for_play = audio_tool.GetPCMString();
            NSData *data = [NSData dataWithBytes:for_play.c_str() length:for_play.length()];
            return data;
        }
        else {
            return nil;
        }
    }
}

@implementation CPBridge

+ (NSString *_Nullable)recoveryHexPubkeyForSign64:(NSString *)hexSign64
                                      contentHash:(NSData *_Nullable)contenthash
                                   judgeHexPubkey:(NSString *)hexpubkey {
    
    std::string bytes = bytesFromHexString(hexSign64);
    std::string pubkey = bytesFromHexString(hexpubkey);
    
    NSData *recoveryKey =
    [CPSignWraper recoverUnzipPublicKeyWithHash:contenthash signature_64:bytes2nsdata(bytes) judgePubkey_unzip:bytes2nsdata(pubkey)];
    
    return [recoveryKey hexString_lower];
}

+ (uint64_t)getRandomHash {
    std::string sign =  nsstring2bytes(NSUUID.UUID.UUIDString);
    return GetHash(sign);
}

+ (std::string)ecdhDecodeMsg:(std::string)encodeBytes
prikey:(std::string)str_pri_key
toPubkey:(std::string)str_pub_key {
    
    
    
    if (encodeBytes.length() < 16) {
        return "";
    }
    
    std::string bytes = encodeBytes;
    std::string msg_org = bytes;
    std::string iv = msg_org.substr(0,16);
    std::string msg_tmp = msg_org.substr(16,bytes.length() - 16);
    
    
    std::string frompbkey = str_pub_key;
    std::string meprikey = str_pri_key;
    std::string ecc_shared_key = GetEcdhKey(frompbkey, meprikey);
    
    std::string msg_decoded;
    @try  {
        std::string out;
        
        std::string content = msg_tmp;
        BOOL decR = AesDecode(ecc_shared_key, iv, content, out);
        NSLog(@"解密结果：%@",decR ? @"成功":@"失败");
        msg_decoded = out;
    }
    @finally {
        return  msg_decoded;
    }
}


+ (std::string)coreEcdhEncodeMsg:(std::string)sourceBytes
prikey:(std::string)str_pri_key
toPubkey:(std::string)str_pub_key
{
    
    std::string iv = CreateAesIVKey();
    
    std::string shared_key = GetEcdhKey(str_pub_key, str_pri_key);
    
    std::string msg_encoded;
    @try  {
        std::string out;
        
        std::string content = sourceBytes;
        AesEncode(shared_key, iv, content, out);
        msg_encoded = out;
    }
    @finally {
    }
    
    std::string for_send = iv + msg_encoded;
    
    return for_send;
}


+ (std::string)aesEncodeData:(std::string)sourceBytes  byPrivateKey:(std::string)privateKey {
    
    if (privateKey.length() < PRI_KEY_SIZE) {
        return "";
    }
    
    std::string iv = CreateAesIVKey();
    std::string str_pri_key = privateKey;
    
    NSData *data_prikey =  bytes2nsdata(str_pri_key);
    NSData *data_256 = [data_prikey sha256Data];
    
    std::string shared_key = nsdata2bytes(data_256);
    
    
    std::string msg_encoded;
    @try  {
        std::string out;
        
        std::string content = sourceBytes;
        AesEncode(shared_key, iv, content, out);
        msg_encoded = out;
    }
    @finally {
        
    }
    std::string for_send = iv + msg_encoded;
    return for_send;
}



+ (NSData *)aesDecodeData:(std::string)encodeData  byPrivateKey:(std::string)privateKey {
    if (encodeData.length() < 16) {
        return nil;
    }
    if (privateKey.length() < PRI_KEY_SIZE) {
        return nil;
    }
    
    std::string str_pri_key = privateKey;
    NSData *data_prikey =  bytes2nsdata(str_pri_key);
    NSData *data_256 = [data_prikey sha256Data];
    std::string shared_key = nsdata2bytes(data_256);
    
    std::string msg_org = encodeData;
    std::string iv = msg_org.substr(0,16);
    std::string msg_tmp = msg_org.substr(16,encodeData.length() - 16);
    
    std::string msg_decoded;
    BOOL decR = false;
    @try  {
        std::string out;
        std::string content = msg_tmp;
        decR = AesDecode(shared_key, iv, content, out);
        msg_decoded = out;
    }
    @finally {
        if (decR == false || msg_decoded.length() == 0) {
            return nil;
        }
        return bytes2nsdata(msg_decoded);
    }
}




@end
