







#import "CPSendMsgHelper.h"
#import "CPInnerState.h"
#import "key_tool.h"
#import "string_tools.h"
#import "audio_format_tool.h"

#import "NSDate+YYAdd.h"
#import "NSString+YYAdd.h"
#import "CPBridge.h"

#import <Alamofire/Alamofire-Swift.h>
#import <chat_plugin/chat_plugin-Swift.h>

#import "ConnectManager.h"
#import "MessageObjects.h"
#import "CPAccountHelper.h"
#import "CPChatLog.h"

@implementation CPSendMsgHelper




+ (void)sendAudioData:(NSData *)data toUser:(NSString *)toPubkey {
    if ([NSString cp_isEmpty:toPubkey]) {
        return;
    }
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPMessage *message = [self _msgFromSendToStoreDBMsg:data type:MessageTypeAudio toPubkey:toPubkey];
        
        [CPInnerState.shared.msgRecieve storeMessge:message isCacheMsg:NO];
        
        
        std::string sourceBytes;
        NSData *sd = data;
        std::string audioData((char *)sd.bytes, sd.length);
        AudioFormatTool audio_tool = AudioFormatTool(0, audioData, false);
        
        message.audioTimes = audio_tool.GetSec() + 1;
        [CPInnerState.shared msgAsynCallBack:message];
        
        std::string encode_zip_audio = audio_tool.GetEncodedString();
        sourceBytes = encode_zip_audio;
        
        
        NCProtoNetMsg *netmsg = ({
            
            std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
            NSLog(@">>> end str_pri_key");
            
            std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));
            
            
            std::string str_pub_key(HexAsc2ByteString([toPubkey UTF8String]));
            NSLog(@">>> end str_pub_key");
            
            
            
            
            std::string for_send = [CPBridge coreEcdhEncodeMsg:sourceBytes prikey:str_pri_key toPubkey:str_pub_key];
            message.msgData = dataHexFromBytes(for_send);
            
            NCProtoNetMsg *send_msg = CreateAudioMsg(fromstrpubkey, str_pub_key, str_pri_key, for_send, message.audioTimes);
            send_msg;
        });
        
        [self commonSendNetMsg:netmsg withFactoryMsg:message];
    }];
}


+ (void)sendMsg:(NSString *)text toUser:(NSString *)toPubkey {
    if ([NSString cp_isEmpty:toPubkey]) {
        return;
    }
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPMessage *message = [self _msgFromSendToStoreDBMsg:text type:MessageTypeText toPubkey:toPubkey];
        
        [CPInnerState.shared.msgRecieve storeMessge:message isCacheMsg:NO];
        [CPInnerState.shared msgAsynCallBack:message];
        
        NCProtoNetMsg *netmsg = ({
            NSData *oriData = [(NSString *)text dataUsingEncoding:NSUTF8StringEncoding];
            std::string ori((char *)oriData.bytes,oriData.length);
            std::string sourceBytes = ori;
            
            std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
            std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));
            std::string str_pub_key(HexAsc2ByteString([toPubkey UTF8String]));
            std::string for_send = [CPBridge coreEcdhEncodeMsg:sourceBytes prikey:str_pri_key toPubkey:str_pub_key];
            message.msgData = dataHexFromBytes(for_send);
            NCProtoNetMsg *send_msg = CreateTextMsg(fromstrpubkey, str_pub_key, str_pri_key, for_send);
            send_msg;
        });
        [self commonSendNetMsg:netmsg withFactoryMsg:message];
    }];
}

+ (void)commonSendNetMsg:(NCProtoNetMsg *)netmsg withFactoryMsg:(CPMessage *)message {
    
    long long sign_hash = (long long)GetHash(nsdata2bytes(netmsg.head.signature));
    message.signHash = sign_hash;
    message.version = GetAppVersion();
    
    BOOL update = [CPInnerState.shared.loginUserDataBase
                   updateRowsInTable:kTableName_Message
                   onProperties:{CPMessage.msgData,CPMessage.version, CPMessage.signHash}
                   withObject:message
                   where:CPMessage.msgId == message.msgId];
    
    if (update == NO) {
        NSLog(@">> error >> update db");
    }
    [CPInnerState.shared _pbmsgSend:netmsg autoCallNetStatus:message];
}


+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)toPubkey {
    if ([NSData cp_isEmpty:data]) {
               return;
    }
    UIImage *image = [UIImage imageWithData:data];
    CGImageRef cg = image.CGImage;
    NSInteger W = CGImageGetWidth(cg);
    NSInteger H = CGImageGetHeight(cg);
    
    [CPInnerState.shared asynWriteTask:^{
        
        
        std::string str_pub_key(HexAsc2ByteString([toPubkey UTF8String]));
        
        
        NSString *topubkey = toPubkey;
        CPMessage *message = [self _msgFromSendToStoreDBMsg:data type:MessageTypeImage toPubkey:topubkey];
        
        [CPInnerState.shared.msgRecieve storeMessge:message isCacheMsg:NO]; 
        [CPInnerState.shared msgAsynCallBack:message];
        
        
        std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
        std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));

        std::string sourceBytes = nsdata2bytes(data);
        std::string for_send = [CPBridge coreEcdhEncodeMsg:sourceBytes prikey:str_pri_key toPubkey:str_pub_key];
        
        
        long long sign_hash_first = (long long)GetHash(for_send);
        message.signHash = sign_hash_first;
        
        
        [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Message
                                                    onProperties:CPMessage.signHash
                                                      withObject:message
                                                           where:CPMessage.msgId == message.msgId];
        
        NSData *encodeImageData = bytes2nsdata(for_send);
        NSString *frompbkey = CPInnerState.shared.loginUser.publicKey;
        
        [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:@(sign_hash_first).stringValue];
        
        [CPNetWork uploadImageDataWithData:encodeImageData toUrl:CPNetURL.UploadImage fromPubkey:frompbkey complete:^(BOOL success, id _Nullable response) {
            
            
            if (success &&
                [response isKindOfClass:NSDictionary.class] &&
                [response[@"result"] integerValue] == 0 &&
                [NSString cp_isEmpty:response[@"id"]] == false) {
                
                
                
                NSString *fileHash = response[@"id"];
                NCProtoNetMsg *send_msg_incache = CreateImageMsg(fromstrpubkey, str_pub_key, str_pri_key, fileHash,W,H);
                long long sign_hash = (long long)GetHash(nsdata2bytes(send_msg_incache.head.signature));
                message.signHash = sign_hash; 
                message.version = GetAppVersion();
                message.fileHash = fileHash;
                
                [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:fileHash];
                [CPInnerState.shared.imageCaches removeObjectForKey:@(sign_hash_first).stringValue];
                
                message.toServerState = 3;
                BOOL update = [CPInnerState.shared.loginUserDataBase
                               updateRowsInTable:kTableName_Message
                               onProperties:{CPMessage.version, CPMessage.signHash, CPMessage.fileHash, CPMessage.toServerState}
                               withObject:message
                               where:CPMessage.msgId == message.msgId];
                
                if (update == NO) {
                    NSLog(@">> error >> update db");
                }
                [CPInnerState.shared _pbmsgSend:send_msg_incache autoCallNetStatus:message];
            }
            else {
                
                message.toServerState = 2;
                
                [CPInnerState.shared.loginUserDataBase
                 updateRowsInTable:kTableName_Message
                 onProperties:{CPMessage.toServerState}
                 withObject:message
                 where:CPMessage.msgId == message.msgId];
                
                [CPInnerState.shared msgAsynCallRecieveStatusChange:message];
            }
            
        } uploadProgress:^(double progress) {
            
            if (message.uploadProgressHandle) {
                message.uploadProgressHandle(progress);
            }
        }];
    }];
}

+ (void)onDownloadImageData:(NSData *)encodeData withMessage:(CPMessage *)msg
{
    NSAssert(msg.msgId > 0 , @"msgid must exit");
    NSString *filehash = msg.fileHash;
    if (filehash == nil || [NSData cp_isEmpty:encodeData]) {
        return;
    }

    [CPInnerState.shared.imageCaches setObject:encodeData forKey:filehash];
}




+ (void)retrySendMsg:(long long)msgId
{
    [CPInnerState.shared asynWriteTask:^{
        
        CPMessage *msg = [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPMessage.class fromTable:kTableName_Message where:CPMessage.msgId == msgId];
        if (msg == nil) {
            return;
        }
        
        
        std::string fromstrpubkey = bytesFromHexString(msg.senderPubKey);
        std::string for_send = bytesHexFromData(msg.msgData);
        std::string str_pub_key = bytesFromHexString(msg.toPubkey);
        std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        int type = msg.msgType;
        NCProtoNetMsg *send_msg;
        if (type == MessageTypeText) {
            send_msg = CreateTextMsg(fromstrpubkey, str_pub_key, str_pri_key, for_send);
        }
        else if (type == MessageTypeAudio) {
            send_msg = CreateAudioMsg(fromstrpubkey, str_pub_key, str_pri_key, for_send, 0);
        }
        else if (type == MessageTypeImage) {
            id encodeData = [msg msgDecodeContent];
            if ([NSData cp_isEmpty:encodeData]) {
                return;
            }
            if ([NSString cp_isEmpty:msg.fileHash] == false) {
                send_msg = CreateImageMsg(fromstrpubkey, str_pub_key, str_pri_key, msg.fileHash, msg.pixelWidth, msg.pixelHeight);
            } else {
                
                long long signhash = (long long)msg.signHash;
                id for_send = [CPInnerState.shared.imageCaches objectForKey:@(signhash).stringValue];
                if ([NSData cp_isEmpty:for_send]) {
                    return;
                }
                [CPSendMsgHelper retrySendEncodeData:for_send withinMsg:msg];
                return;
            }
        }
        else {
            return;
        }
        
        [CPInnerState.shared _pbmsgSend:send_msg];
    }];
}

+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message
{
    NSString *frompbkey = message.senderPubKey;
    [CPNetWork uploadImageDataWithData:encodeImageData toUrl:CPNetURL.UploadImage fromPubkey:frompbkey complete:^(BOOL success, id _Nullable response) {
               
               if (success &&
                   [response isKindOfClass:NSDictionary.class] &&
                   [response[@"result"] integerValue] == 0 &&
                   [NSString cp_isEmpty:response[@"id"]] == false) {
                   
                   
                   
                   NSString *fileHash = response[@"id"];
                   message.fileHash = fileHash;
                   
                   long long sign_hash_first = (long long)message.signHash;
                   [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:fileHash];
                   [CPInnerState.shared.imageCaches removeObjectForKey:@(sign_hash_first).stringValue];
                   
                   message.toServerState = 3;
                   
                   
                   std::string str_pub_key(HexAsc2ByteString([message.toPubkey UTF8String]));
                   

                   
                   std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
                   std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));
                   
                   NCProtoNetMsg *send_msg_incache = CreateImageMsg(fromstrpubkey,
                                                                    str_pub_key,
                                                                    str_pri_key,
                                                                    fileHash,
                                                                    message.pixelWidth,
                                                                    message.pixelHeight);
                   
                   long long sign_hash = (long long)GetHash(nsdata2bytes(send_msg_incache.head.signature));
                   message.signHash = sign_hash; 
                   
                   BOOL update = [CPInnerState.shared.loginUserDataBase
                                  updateRowsInTable:kTableName_Message
                                  onProperties:{ CPMessage.signHash, CPMessage.fileHash, CPMessage.toServerState}
                                  withObject:message
                                  where:CPMessage.msgId == message.msgId];
                   
                   if (update == NO) {
                       NSLog(@">> error >> update db");
                   }
                   
                   [CPInnerState.shared _pbmsgSend:send_msg_incache];
               }
               else {
                   
               }
               
    } uploadProgress:nil];
}



+ (CPMessage *)_msgFromSendToStoreDBMsg:(id)sourceMsgContent
                                   type:(MessageType)type
                               toPubkey:(NSString *)toPubkey
{
    CPMessage *message = [[CPMessage alloc] init];
    message.senderPubKey = CPInnerState.shared.loginUser.publicKey;
    message.toPubkey = toPubkey;
    message.msgType = type;
    message.audioRead = YES;
    message.read = YES;
    message.toServerState = 0;
    
    
    if (type == MessageTypeText) {
        message -> _msgDecode = sourceMsgContent;
    } else if (type == MessageTypeAudio) {
        message -> _audioDecode = sourceMsgContent;
    }
    else if (type == MessageTypeImage) {
        message -> _imageDecode = sourceMsgContent;
    }
    
    return  message;
}


NSString *_deviceToken;
+ (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [self bindDeviceToken];
}

+ (void)bindDeviceToken {
    if ([self checkApnsAuthed] == false) {
        return;
    }
    std::string prikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    NCProtoNetMsg *bind = CreateBindAppleId(prikey, _deviceToken);
    [CPInnerState.shared _pbmsgSend:bind];
    NSLog(@"deviceToken bind %@",_deviceToken);
}

+ (void)unbindDeviceTokenComplete:(MsgResponseBack)back {
    if ([self checkApnsAuthed] == false) {
        if (back != nil) {
            back(NSDictionary.dictionary);
        }
        return;
    }
    std::string prikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    NCProtoNetMsg *unbind = CreateUnBindAppleId(prikey,_deviceToken);
    
    if (back != nil) {
        uint64_t sign_hash = GetHash(nsdata2bytes(unbind.head.signature));
        NSString *key = [@(sign_hash) stringValue];
        AllWaitResponse[key] = back;
    }
    
    [CPInnerState.shared _pbmsgSend:unbind];
}

+ (BOOL)checkApnsAuthed {
    if ([NSString cp_isEmpty:_deviceToken]) {
        return false;
    }
    if ([CPInnerState.shared isConnected] == false) {
        return false;
    }
    if (CPInnerState.shared.loginUser == nil) {
        return false;
    }
    return true;
}

@end
