//
//  CPMsgRecieveHandle.m
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPMsgRecieveHandle.h"

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
#import "CPSendMsgHelper.h"
#import "CPAccountHelper+Private.h"

@implementation CPMsgRecieveHandle

//
////MARK: Helper
///// insert ok, return msg, otherwise, nil
///// @param msg insert ok
///// import cache time only isvalid on isCache
///// data only can is data or GPBMessage
//- (CPMessage * )_dealRecieveNetMsg:(NCProtoNetMsg *)msg
//                           isCache:(BOOL)isCache
//                   storeEncodeData:(id)data
//{
//    std::string fromPubkey = nsdata2bytes(msg.head.fromPubKey);
//    NSString *senderpubkey = hexStringFromBytes(fromPubkey);
//    
//    std::string toPubKey = nsdata2bytes(msg.head.toPubKey);
//    //1 init
//    CPMessage *cpmsg = CPMessage.alloc.init;
//    cpmsg.senderPubKey = senderpubkey;
//    cpmsg.toPubkey = hexStringFromBytes(toPubKey);
//    
//    /// encoded for_send
//    if ([data isKindOfClass:NSData.class]) {
//        cpmsg.msgData = dataHexFromBytes(nsdata2bytes(data));
//    }
//    else if ([data isKindOfClass:GPBMessage.class]) {
//    }
//    else {
//        return nil;
//    }
//    
//    cpmsg.version = GetAppVersion();
//    long long sign_hash = (long long)GetHash(nsdata2bytes(msg.head.signature));
//    cpmsg.signHash = sign_hash;
//    cpmsg.toServerState = 1;
//    
//    if (msg.head.msgTime > 1000) {
//        double server_time = msg.head.msgTime / 1000.0;
//        cpmsg.createTime = server_time;
//    }
//    
//    /// when sender is read
//    BOOL isInRoom = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.chatToPubkey];
//    BOOL isSelfSend = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.loginUser.publicKey];
//    if (isInRoom || isSelfSend) {
//        cpmsg.read = YES;
//    }
//    
//    /// Recieve Msg Name
//    if ([msg.name isEqualToString:(NSString *)kMsg_Audio]) {
//        cpmsg.msgType = MessageTypeAudio;
//    }
//    else if ([msg.name isEqualToString:(NSString *)kMsg_Text]) {
//        cpmsg.msgType = MessageTypeText;
//    }
//    else if ([msg.name isEqualToString:(NSString *)kMsg_Image]) {
//        cpmsg.msgType = MessageTypeImage;
//        cpmsg.msgData = nil;
//        NCProtoImage *image = (NCProtoImage *)data;
//        cpmsg.fileHash = image.id_p;
//        cpmsg.pixelWidth = image.width;
//        cpmsg.pixelHeight = image.height;
//    }
//    else {
//        cpmsg.msgType = MessageTypeUnknown;
//    }
//    
//    // store db
//    BOOL update = [CPInnerState.shared storeMessge:cpmsg isCacheMsg:isCache];
//    return update ? cpmsg : nil;
//}
//
///**
// v1.0 store msg to db
// @param message
// @param isme is self send,
// @return  if message insert ok, return yes, otherwise  no
// */
//- (BOOL)storeMessge:(CPMessage *)message isCacheMsg:(BOOL)isCache
//{
//    BOOL isme =  [message.senderPubKey isEqualToString:self.loginUser.publicKey];
//    //write db. contact -> message ->session  |   <<sesstion user for group
//    int sessionId = 0;
//    long long messageId = 0;
//    SessionType sessionType = SessionTypeP2P;
//    double createTime = [NSDate.date timeIntervalSince1970];
//    
//    //1 query contact
//    NSString *contactPubkey = isme ? message.toPubkey : message.senderPubKey;
//    CPContact *contact = [self selectContactByPubkey:contactPubkey];
//    
//    
//    //2 find sessionID
//    if (contact == nil) {
//        contact = [self create_InsertContactByPubkey:contactPubkey createTime:createTime];
//        if (contact == nil) {
//            NSLog(@"MSG - Contact - err");
//            return NO;
//        }
//    }
//    sessionId = contact.sessionId;
//    
//    if (contact.isBlack) {
//        NSLog(@"MSG - Black - err");
//        return false;
//    }
//    if (contact.isDoNotDisturb) {
//        message.doNotDisturb = true;
//    }
//    
//    
//    //message
//    //same msg should not insert
//    message.senderRemark = contact.remark;
//    message.sessionId = sessionId;
//    if (message.createTime <= 10) {
//        message.createTime = createTime;
//    }
//    message.isAutoIncrement = YES;
//    
//    //maybe repeat //Note: maybe slow //if (isCache) //Note: TODO: send: first signhash is 0
//    CPMessage *findMsg = [self selectMsgBySendPubkey:message.senderPubKey toPubkey:message.toPubkey signHash:message.signHash];
//    if (findMsg != nil) {
//        long long msgid = findMsg.msgId;
//        message.msgId = msgid;
//        NSLog(@"MSG - find - exist msg");
//        return NO; //import: haved, did not show
//    }
//    
//    NSAssert(message.createTime > 0, @"Message create Time Must Set 2");
//    //insert by: multi constraint
//    BOOL update = [self.loginUserDataBase insertObject:message into:kTableName_Message];
//    if (update == NO) {
//        NSLog(@"MSG - error >> insert message db");
//        return NO;
//    }
//    messageId = message.lastInsertedRowID;
//    message.msgId = messageId;
//    
//    // recent session
//    CPSession *haved = [self selectSessionBySessionId:sessionId];
//    if (haved) {
//        //for ordered
//        update = [self.loginUserDataBase updateRowsInTable:kTableName_Session
//                                              onProperties:{CPSession.lastMsgId, CPSession.updateTime}
//                                                   withRow:@[@(messageId), @(createTime)]
//                                                     where:CPSession.sessionId == sessionId];
//    }
//    else {
//        CPSession *insert =
//        [self create_InsertSession:sessionId type:sessionType lastMsgId:messageId ctime:createTime utime:createTime];
//        update = insert ? YES : NO;
//    }
//    if (update == NO) {
//        //update session error
//        NSLog(@"MSG >> error >> insert session db");
//    }
//    return YES;
//}
////MARK: Action for Msg
//- (void)actionForRegisterRsp:(NCProtoNetMsg *)pack {
//    NCProtoRegisterRsp *body = [NCProtoRegisterRsp parseFromData:pack.data_p error:nil];
//    if (body.result != 0) {
//        //error
//        _RegisterOk = false;
//        [self.connectManager disconnect];
//    } else {
//        _RegisterOk = true;
//        [self asynDoTask:^{
//            [NSNotificationCenter.defaultCenter postNotificationName:kServiceConnectStatusChange object:nil];
//        }];
//        
//        [self.cacheMsgManager _bridgeOnLogin];
//        [CPSendMsgHelper bindDeviceToken];
//        [self resendLatest_180s_unsendMsg];
//    }
//    //replay
//    [self clientReplay:pack];
//}
//
//- (void)actionForText:(NCProtoNetMsg *)pack {
//    NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
//    if (!body) {
//        return;
//    }
//    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];
//    //off line sys
//    if (insertOk) {
//        [self asynCallBackMsg:insertOk];
//        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
//    }
//    //replay
//    [self clientReplay:pack];
//}
//
//- (void)actionForAudio:(NCProtoNetMsg *)pack {
//    NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
//    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];
//    //off line sys
//    if (insertOk) {
//        [self asynCallBackMsg:insertOk];
//        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
//    }
//    //replay
//    [self clientReplay:pack];
//}
//
//- (void)actionForImage:(NCProtoNetMsg *)pack {
//    NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
//    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body];
//    //off line sys
//    if (insertOk) {
//        [self asynCallBackMsg:insertOk];
//        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
//    }
//    //replay
//    [self clientReplay:pack];
//}
//
//
//
//- (void)actionForServerReceipt:(NCProtoNetMsg *)pack {
//    
//    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
//    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
//    long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
//    
//    //8 bytes
//    WCTCondition condition =
//    CPMessage.senderPubKey == hexStringFromBytes(fromPubkey) &&
//    CPMessage.toPubkey == hexStringFromBytes(toPubKey) &&
//    CPMessage.signHash == sign_hash;
//    
//    WCTOneRow *row = [self.loginUserDataBase getOneRowOnResults:{
//        CPMessage.msgId}
//                                                      fromTable:kTableName_Message
//                                                          where:condition];
//    if (row == nil) {
//        return;
//    }
//    
//    
//    CPMessage *cpmsg = CPMessage.alloc.init;
//    
//    NCProtoServerReceipt *body = [NCProtoServerReceipt parseFromData:pack.data_p error:nil];
//    int result = 1;
//    if (body.result != 0) {
//        result = 2;
//    }
//    if (body.result == 2) {
//        cpmsg.toUserNotFound = true;
//    }
//    
//    long long msgid = [(NSNumber *)row[0] longLongValue];
//    double server_time = pack.head.msgTime / 1000.0;
//    NSAssert(server_time > 0, @"Message create Time Must Set 1");
//    BOOL update = [self.loginUserDataBase updateRowsInTable:kTableName_Message
//                                               onProperties:{CPMessage.toServerState,CPMessage.createTime}
//                                                    withRow:@[@(result),@(server_time)]
//                                                      where:condition];
//    
//    if (update == false) {
//        return;
//    }
//    
//    cpmsg.msgId = msgid;
//    cpmsg.toServerState = result;
//    [self asynCallStatusChange:cpmsg];
//}
//
////cache msg
//- (void)actionForCacheMsgRsp:(NCProtoNetMsg *)pack {
//    
//    NCProtoCacheMsgRsp *body = [NCProtoCacheMsgRsp parseFromData:pack.data_p error:nil];
//    if (!body) {
//        NSLog(@"coremsg-CacheMsgRsp-body-empty");
//        return;
//    }
//    
//    uint32_t randId = body.roundId;
//    if (randId != self.cacheMsgManager.fetchId) {
//        NSLog(@"coremsg-CacheMsgRsp-fetchid-error");
//        return;
//    }
//    
//    if (body.msgsArray_Count == 0) {
//        NSLog(@"coremsg-CacheMsgRsp-count-0");
//        [self.cacheMsgManager setSysMark:YES];
//        return;
//    }
//    NSLog(@"coremsg-CacheMsgRsp-count-OK");
//
//    NSMutableArray<CPMessage *> *arr = NSMutableArray.array; //have new added
//    //cached
//    for (NCProtoNetMsg *pack in body.msgsArray) {
//        CPMessage *tmpMsg;
//        if ([pack.name isEqualToString:kMsg_Text]) {
//            NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
//            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
//        }
//        else if ([pack.name isEqualToString:kMsg_Audio]) {
//            NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
//            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
//        }
//        else if ([pack.name isEqualToString:kMsg_Image]) {
//              NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
//              tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body];
//        }
//        
//        if (tmpMsg) {
//            [arr addObject:tmpMsg];
//        }
//    }
//    
//    CPMessage *lastMsg;
//    NCProtoNetMsg *lastIn = body.msgsArray.lastObject;
//    
//    if (lastIn != nil) {
//        lastMsg = CPMessage.alloc.init;
//        lastMsg.createTime = lastIn.head.msgTime / 1000.0;
//        long long sign_hash = (long long)GetHash(nsdata2bytes(lastIn.head.signature));
//        lastMsg.signHash = sign_hash;
//    }
//    
//    //terminal
//    if (arr.count > 0) {
//        [self asynCallCaches:arr];
//    }
//    
//    if (lastMsg) {
//        //change start point
//        [self.cacheMsgManager handleCacheMsg:lastMsg];
//        //start next request
//        [self.cacheMsgManager _startFetchCacheMsg];
//    }
//    
//    //replay
//    [self clientReplay:pack];
//}
//
////MARK:- Want Reuse Code
//- (void)resendLatest_180s_unsendMsg {
//    //may be leak long time
//    [self asynWriteTask:^{
//        double expect = NSDate.date.timeIntervalSince1970 - 180;
//        NSArray* msgArray = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPMessage.class
//                                                                           fromTable:kTableName_Message
//                                                                               where:CPMessage.createTime > expect && (CPMessage.toServerState == 0 || CPMessage.toServerState == 3)
//                                                                             orderBy:CPMessage.msgId.order(WCTOrderedDescending)
//                                                                               limit:17];
//        
//        if (msgArray.count == 0) {
//            return;
//        }
//        
//        for (CPMessage *msg in msgArray) {
//            [CPSendMsgHelper retrySendMsg:msg.msgId];
//        }
//    }];
//}
//
//- (void)clientReplay:(NCProtoNetMsg *)packin {
//    NCProtoNetMsg *replay = CreateClientReplyMsg(packin);
//    [self _pbmsgSend:replay];
//}
//
//- (CPContact * _Nullable)selectContactByPubkey:(NSString *)contactPubKey {
//    CPContact * contact =
//    [self.loginUserDataBase getOneObjectOfClass:CPContact.class
//                                      fromTable:kTableName_Contact
//                                          where:CPContact.publicKey == contactPubKey];
//    
//    return contact;
//}
//
//- (CPContact * _Nullable)create_InsertContactByPubkey:(NSString *)contactPubKey createTime:(double)ctime
//{
//    CPContact *contact = [CPContact new];
//    
//    NSString *pubkey_ = contactPubKey;
//    contact.publicKey = pubkey_;
//    contact.remark = [pubkey_ substringToIndex:12];
//    
//    contact.sessionType = SessionTypeP2P;
//    contact.createTime = ctime;
//    
//    if ([contactPubKey isEqualToString:support_account_pubkey]) {
//    } else {
//        contact.status = ContactStatusStrange;
//    }
//    
//    contact.isAutoIncrement = YES;
//    BOOL update = [self.loginUserDataBase insertObject:contact into:kTableName_Contact];
//    if (update == NO) {
//        NSLog(@">> error >> insert contact db");
//        return nil;
//    }
//    contact.sessionId = contact.lastInsertedRowID;
//    return contact;
//}
//
//- (CPMessage * _Nullable)selectMsgBySendPubkey:(NSString *)sendPubkey
//                                      toPubkey:(NSString *)toPubkey
//                                      signHash:(unsigned long long)signHash
//{
//    WCTCondition condition =
//    CPMessage.senderPubKey == sendPubkey &&
//    CPMessage.toPubkey == toPubkey &&
//    CPMessage.signHash == signHash;
//    
//    CPMessage *row =
//    [self.loginUserDataBase getOneObjectOfClass:CPMessage.class
//                                      fromTable:kTableName_Message
//                                          where:condition];
//    
//    return row;
//}
//
//- (CPSession *_Nullable)selectSessionBySessionId:(int)sid {
//    CPSession *haved =
//    [self.loginUserDataBase getOneObjectOfClass:CPSession.class
//                                      fromTable:kTableName_Session
//                                          where:CPSession.sessionId == sid];
//    return haved;
//}
//
//- (CPSession *_Nullable)create_InsertSession:(int)sessionId
//                                        type:(SessionType)sessionType
//                                   lastMsgId:(long long)lastMsgId
//                                       ctime:(double)createTime
//                                       utime:(double)updateTime
//{
//    CPSession *session = [CPSession new];
//    session.sessionId = sessionId;
//    session.sessionType = sessionType;
//    session.lastMsgId = lastMsgId;
//    session.createTime = createTime;
//    session.updateTime = updateTime;
//    BOOL res = [self.loginUserDataBase insertObject:session into:kTableName_Session];
//    return res ? session : nil;
//}
//


@end
