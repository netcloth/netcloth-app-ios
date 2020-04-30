//
//  CPGroupSendMsgHelper.m
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPGroupSendMsgHelper.h"

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

@implementation CPGroupSendMsgHelper


//MARK:- send Msg
// audio
+ (void)sendAudioData:(NSData *)data toUser:(NSString *)toPubkey {
    if ([NSString cp_isEmpty:toPubkey]) {
        return;
    }
    
    [CPInnerState.shared asynWriteTask:^{
        //1、 refactor msg
        CPMessage *message = [self _msgFromSendToStoreDBMsg:data type:MessageTypeAudio toPubkey:toPubkey];
        
        //3
        std::string sourceBytes;
        NSData *sd = data;
        std::string audioData((char *)sd.bytes, sd.length);
        AudioFormatTool audio_tool = AudioFormatTool(0, audioData, false);
        //3、Note: show
        int timeLen =  MIN(audio_tool.GetSec() + 1, 60);
        message.audioTimes = timeLen;
        message.isGroupChat = YES;
        
        //2、store msgId；  session | session user | message
        [CPInnerState.shared.groupMsgRecieve storeMessge:message isCacheMsg:NO];
        
        [CPInnerState.shared msgAsynCallBack:message];
        
        std::string encode_zip_audio = audio_tool.GetEncodedString();
        sourceBytes = encode_zip_audio;
        
        
        NCProtoNetMsg *netmsg = ({
            //me
            std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
            NSLog(@">>> end str_pri_key");
            
            std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));
            
            //to
            std::string str_pub_key(HexAsc2ByteString([toPubkey UTF8String]));
            NSLog(@">>> end str_pub_key");
            
            std::string for_send = [CPBridge coreEcdhEncodeMsg:sourceBytes prikey:str_pri_key toPubkey:str_pub_key];
            message.msgData = dataHexFromBytes(for_send);
            
            NCProtoNetMsg *send_msg = CreateGroupAudio(for_send, timeLen, fromstrpubkey, str_pub_key, str_pri_key);
            send_msg;
        });
        
        [self commonSendNetMsg:netmsg withFactoryMsg:message];
    }];
}

//MARK:- Text
+ (void)sendMsg:(NSString *)text
         toUser:(NSString *)toPubkey
         at_all:(BOOL)atAll
     at_members:(NSArray <NSString *> *)members {
    
    if ([NSString cp_isEmpty:toPubkey]) {
        return;
    }
    
    [CPInnerState.shared asynWriteTask:^{
        //1、 refactor msg
        CPMessage *message = [self _msgFromSendToStoreDBMsg:text type:MessageTypeText toPubkey:toPubkey];
        //2、store msgId；  session | session user | message
        [CPInnerState.shared.groupMsgRecieve storeMessge:message isCacheMsg:NO];
        message.isGroupChat = YES;
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
            NCProtoNetMsg *send_msg = CreateGroupText(for_send, atAll, members, fromstrpubkey, str_pub_key, str_pri_key);
            send_msg;
        });
        [self commonSendNetMsg:netmsg withFactoryMsg:message];
    }];
}

+ (void)commonSendNetMsg:(NCProtoNetMsg *)netmsg withFactoryMsg:(CPMessage *)message {
    //6 update db
    long long sign_hash = (long long)GetHash(nsdata2bytes(netmsg.head.signature));
    message.signHash = sign_hash;
    message.version = GetAppVersion();
    
    BOOL update = [CPInnerState.shared.loginUserDataBase
                   updateRowsInTable:kTableName_GroupMessage
                   onProperties:{CPMessage.msgData,CPMessage.version, CPMessage.signHash}
                   withObject:message
                   where:CPMessage.msgId == message.msgId];
    
    if (update == NO) {
        NSLog(@">> error >> update db");
    }
    [CPInnerState.shared _pbmsgSend:netmsg autoCallNetStatus:message];
}

//MARK:- send img
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
        
        //1、save data to local file cache
        std::string str_pub_key(HexAsc2ByteString([toPubkey UTF8String]));
        
        //factory CPMessage to store
        NSString *topubkey = toPubkey;
        CPMessage *message = [self _msgFromSendToStoreDBMsg:data type:MessageTypeImage toPubkey:topubkey];
        message.pixelWidth = W;
        message.pixelHeight = H;
        
        [CPInnerState.shared.groupMsgRecieve storeMessge:message isCacheMsg:NO]; //get msg id
        message.isGroupChat = YES;
        [CPInnerState.shared msgAsynCallBack:message];
        
        //2、 upload data to http storage
        std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
        std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));

        std::string sourceBytes = nsdata2bytes(data);
        std::string for_send = [CPBridge coreEcdhEncodeMsg:sourceBytes prikey:str_pri_key toPubkey:str_pub_key];
        
        //this sign hash is not msg send sha
        long long sign_hash_first = (long long)GetHash(for_send);
        message.signHash = sign_hash_first;
        
        //update sign hash
        [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_GroupMessage
                                                    onProperties:CPMessage.signHash
                                                      withObject:message
                                                           where:CPMessage.msgId == message.msgId];
        
        NSData *encodeImageData = bytes2nsdata(for_send);
        NSString *frompbkey = CPInnerState.shared.loginUser.publicKey;
        
        [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:@(sign_hash_first).stringValue];
        
        [CPNetWork uploadImageDataWithData:encodeImageData toUrl:CPNetURL.UploadImage fromPubkey:frompbkey complete:^(BOOL success, id _Nullable response) {
            
            //send
            if (success &&
                [response isKindOfClass:NSDictionary.class] &&
                [response[@"result"] integerValue] == 0 &&
                [NSString cp_isEmpty:response[@"id"]] == false) {
                
                //3、send msg to pubkey succss or fail
                //upload hash who in cache store
                NSString *fileHash = response[@"id"];
                NCProtoNetMsg *send_msg_incache = CreateGroupImage(fileHash, W, H, fromstrpubkey, str_pub_key, str_pri_key);
            
                long long sign_hash = (long long)GetHash(nsdata2bytes(send_msg_incache.head.signature));
                message.signHash = sign_hash; //the push sign
                message.version = GetAppVersion();
                message.fileHash = fileHash;
                
                [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:fileHash];
                [CPInnerState.shared.imageCaches removeObjectForKey:@(sign_hash_first).stringValue];
                
                message.toServerState = 3;
                BOOL update = [CPInnerState.shared.loginUserDataBase
                               updateRowsInTable:kTableName_GroupMessage
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
                //update db
                [CPInnerState.shared.loginUserDataBase
                 updateRowsInTable:kTableName_GroupMessage
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
//    msg.msgData = encodeData;
    [CPInnerState.shared.imageCaches setObject:encodeData forKey:filehash];
}

//MARK:- Resend


+ (void)retrySendMsg:(long long)msgId
{
    [CPInnerState.shared asynWriteTask:^{
        
        CPMessage *msg = [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPMessage.class fromTable:kTableName_GroupMessage where:CPMessage.msgId == msgId];
        if (msg == nil) {
            return;
        }
        
        //5 send
        std::string fromstrpubkey = bytesFromHexString(msg.senderPubKey);
        std::string for_send = bytesHexFromData(msg.msgData);
        std::string str_pub_key = bytesFromHexString(msg.toPubkey);
        std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        int type = msg.msgType;
        NCProtoNetMsg *send_msg;
        if (type == MessageTypeText) {
            send_msg = CreateGroupText(for_send, false, nil, fromstrpubkey, str_pub_key, str_pri_key);
        }
        else if (type == MessageTypeAudio) {
            send_msg = CreateGroupAudio(for_send, msg.audioTimes, fromstrpubkey, str_pub_key, str_pri_key);
        }
        else if (type == MessageTypeImage) {
            id encodeData = [msg msgDecodeContent];
            if ([NSData cp_isEmpty:encodeData]) {
                return;
            }
            if ([NSString cp_isEmpty:msg.fileHash] == false) {
                send_msg = CreateGroupImage(msg.fileHash, msg.pixelWidth, msg.pixelHeight, fromstrpubkey, str_pub_key, str_pri_key);
            } else {
                //resent encode forsend
                long long signhash = (long long)msg.signHash;
                id for_send = [CPInnerState.shared.imageCaches objectForKey:@(signhash).stringValue];
                if ([NSData cp_isEmpty:for_send]) {
                    return;
                }
                [CPGroupSendMsgHelper retrySendEncodeData:for_send withinMsg:msg];
                return;
            }
        }
        else {
            return;
        }
        //to send
        [CPInnerState.shared _pbmsgSend:send_msg];
    }];
}

+ (void)retrySendEncodeData:(NSData *)encodeImageData withinMsg:(CPMessage *)message
{
    NSString *frompbkey = message.senderPubKey;
    [CPNetWork uploadImageDataWithData:encodeImageData toUrl:CPNetURL.UploadImage fromPubkey:frompbkey complete:^(BOOL success, id _Nullable response) {
               //send
               if (success &&
                   [response isKindOfClass:NSDictionary.class] &&
                   [response[@"result"] integerValue] == 0 &&
                   [NSString cp_isEmpty:response[@"id"]] == false) {
                   
                   //3、send msg to pubkey succss or fail
                   //upload hash who in cache store
                   NSString *fileHash = response[@"id"];
                   message.fileHash = fileHash;
                   
                   long long sign_hash_first = (long long)message.signHash;
                   [CPInnerState.shared.imageCaches setObject:encodeImageData forKey:fileHash];
                   [CPInnerState.shared.imageCaches removeObjectForKey:@(sign_hash_first).stringValue];
                   
                   message.toServerState = 3;
                   
                   //1、save data to local file cache
                   std::string str_pub_key(HexAsc2ByteString([message.toPubkey UTF8String]));
                   

                   //2、 upload data to http storage
                   std::string str_pri_key(getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password));
                   std::string fromstrpubkey(getPublicKeyFromUser(CPInnerState.shared.loginUser));
                   
                   NCProtoNetMsg *send_msg_incache = CreateGroupImage(fileHash, message.pixelWidth, message.pixelHeight, fromstrpubkey, str_pub_key, str_pri_key);
                   
                   long long sign_hash = (long long)GetHash(nsdata2bytes(send_msg_incache.head.signature));
                   message.signHash = sign_hash; //the push sign
                   
                   BOOL update = [CPInnerState.shared.loginUserDataBase
                                  updateRowsInTable:kTableName_GroupMessage
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

//MARK: Helper

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
    message.server_msg_id = 0;
    
    //decode
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



@end
