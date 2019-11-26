







#import "CPBridge.h"
#import "CPDataModel+secpri.h"
#include "key_tool.h"
#include "string_tools.h"
#include "audio_format_tool.h"
#import "CPInnerState.h"
#import <chat_plugin/chat_plugin-Swift.h>

std::string decodePrivateKey;

@implementation CPBridge




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
    
    NSError *err;
    NSString *address = [CPAddressWraper addressForPrivateKey:pkData error:&err];
    if (err) {
        return nil;
    }
    return address;
}

NSString *compressedHexPubkeyOfLoginUser(void) {
    User *loginUser = CPInnerState.shared.loginUser;
    if (!loginUser) {
        return nil;
    }
    std::string pubkey = getPublicKeyFromUser(loginUser);
    NSData *oridata = bytes2nsdata(pubkey);
    
    NSError *err;
    NSString *hexPubkeyCompressed = [CPAddressWraper compressedHexPubkey:oridata error:&err];
    if (err || [NSString cp_isEmpty:hexPubkeyCompressed]) {
        return nil;
    }
    return hexPubkeyCompressed;
}

NSData * GetOriginSignHash(NSData *contenthash, NSData *pri_key) {
    NSData *recover_serial_sign = [CPSignWraper OrignSignForRecoveryWithHash:contenthash privateKey:pri_key];
    return recover_serial_sign;
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
    std::string ss(p,data.length);//Note:
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
    const char *p = bytes.c_str();
    NSString *r = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
    return r;
}

std::string nsstring2bytes(NSString *string) {
    const char *p = [string cStringUsingEncoding:NSUTF8StringEncoding];
    std::string r = std::string(p, string.length);
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


@end
