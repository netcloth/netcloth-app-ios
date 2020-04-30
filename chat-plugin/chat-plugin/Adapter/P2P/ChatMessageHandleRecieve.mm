//
//  ChatMessageHandleRecieve.m
//  chat-plugin
//
//  Created by Grand on 2019/11/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "ChatMessageHandleRecieve.h"
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

#import "CPInnerState.h"

@implementation ChatMessageHandleRecieve


//MARK: Helper
/// insert ok, return msg, otherwise, nil
/// @param msg insert ok
/// import cache time only isvalid on isCache
/// data only can is data or GPBMessage
- (CPMessage * )_dealRecieveNetMsg:(NCProtoNetMsg *)msg
                           isCache:(BOOL)isCache
                   storeEncodeData:(id)data
{
    return [self _v2DealRecieveNetMsg:msg isCache:isCache storeEncodeData:data orOriginData:nil];
}

- (CPMessage * )_v2DealRecieveNetMsg:(NCProtoNetMsg *)msg
                             isCache:(BOOL)isCache
                     storeEncodeData:(id)data
                        orOriginData:(id)originData
{
    std::string fromPubkey = nsdata2bytes(msg.head.fromPubKey);
    NSString *senderpubkey = hexStringFromBytes(fromPubkey);
    
    std::string toPubKey = nsdata2bytes(msg.head.toPubKey);
    //1 init
    CPMessage *cpmsg = CPMessage.alloc.init;
    cpmsg.senderPubKey = senderpubkey;
    cpmsg.toPubkey = hexStringFromBytes(toPubKey);
    
    /// encoded for_send    
    if ([data isKindOfClass:NSData.class]) {
        cpmsg.msgData = dataHexFromBytes(nsdata2bytes(data));
    }
    else if ([data isKindOfClass:GPBMessage.class]) {
    }
    else if ([originData isKindOfClass:NSData.class]) {
        cpmsg.msgData = originData;
    } else {
        return nil;
    }
    
    
    
    cpmsg.version = GetAppVersion();
    long long sign_hash = (long long)GetHash(nsdata2bytes(msg.head.signature));
    cpmsg.signHash = sign_hash;
    cpmsg.toServerState = 1;
    
    if (msg.head.msgTime > 1000) {
        double server_time = msg.head.msgTime / 1000.0;
        cpmsg.createTime = server_time;
    }
    
    /// when sender is read
    BOOL isInRoom = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.chatToPubkey];
    BOOL isSelfSend = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.loginUser.publicKey];
    if (isInRoom || isSelfSend) {
        cpmsg.read = YES;
    }
    
    /// Recieve Msg Name
    if ([msg.name isEqualToString:(NSString *)NCProtoAudio.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeAudio;
    }
    else if ([msg.name isEqualToString:(NSString *)NCProtoText.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeText;
    }
    else if ([msg.name isEqualToString:(NSString *)NCProtoImage.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeImage;
        cpmsg.msgData = nil;
        NCProtoImage *image = (NCProtoImage *)data;
        cpmsg.fileHash = image.id_p;
        cpmsg.pixelWidth = image.width;
        cpmsg.pixelHeight = image.height;
    }
    else if ([msg.name isEqualToString:NCProtoGroupInvite.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeInviteeUser;
    }
    else {
        cpmsg.msgType = MessageTypeUnknown;
    }
    
    // store db
    BOOL update = [self storeMessge:cpmsg isCacheMsg:isCache];
    return update ? cpmsg : nil;
}

/**
 v1.0 store msg to db
 @param message
 @param isme is self send,
 @return  if message insert ok, return yes, otherwise  no
 */
- (BOOL)storeMessge:(CPMessage *)message isCacheMsg:(BOOL)isCache
{
    BOOL isme =  [message.senderPubKey isEqualToString:self.loginUser.publicKey];
    //write db. contact -> message ->session  |   <<sesstion user for group
    int sessionId = 0;
    long long messageId = 0;
    SessionType sessionType = SessionTypeP2P;
    double createTime = [NSDate.date timeIntervalSince1970];
    
    //1 query contact
    NSString *contactPubkey = isme ? message.toPubkey : message.senderPubKey;
    CPContact *contact = [self selectContactByPubkey:contactPubkey];
    
    
    //2 find sessionID
    if (contact == nil) {
        contact = [self create_InsertContactByPubkey:contactPubkey createTime:createTime];
        if (contact == nil) {
            NSLog(@"MSG - Contact - err");
            return NO;
        }
    }
    sessionId = contact.sessionId;
    
    if (contact.isBlack) {
        NSLog(@"MSG - Black - err");
        return false;
    }
    if (contact.isDoNotDisturb) {
        message.doNotDisturb = true;
    }
    
    
    //message
    //same msg should not insert
    message.senderRemark = contact.remark;
    message.sessionId = sessionId;
    if (message.createTime <= 10) {
        message.createTime = createTime;
    }
    message.isAutoIncrement = YES;
    
    //maybe repeat //Note: maybe slow //if (isCache) //Note: TODO:  for send first signhash is 0
    CPMessage *findMsg = [self selectMsgBySendPubkey:message.senderPubKey toPubkey:message.toPubkey signHash:message.signHash];
    if (findMsg != nil) {
        long long msgid = findMsg.msgId;
        message.msgId = msgid;
        NSLog(@"MSG - find - exist msg");
        return NO; //import: haved, did not show
    }
    
    NSAssert(message.createTime > 0, @"Message create Time Must Set 2");
    //insert by: multi constraint
    BOOL update = [self.loginUserDataBase insertObject:message into:kTableName_Message];
    if (update == NO) {
        NSLog(@"MSG - error >> insert message db");
        return NO;
    }
    messageId = message.lastInsertedRowID;
    message.msgId = messageId;
    
    // recent session
    CPSession *haved = [self selectSessionBySessionId:sessionId];
    if (haved) {
        //for ordered
        update = [self.loginUserDataBase updateRowsInTable:kTableName_Session
                                              onProperties:{CPSession.lastMsgId, CPSession.updateTime}
                                                   withRow:@[@(messageId), @(createTime)]
                                                     where:CPSession.sessionId == sessionId];
    }
    else {
        CPSession *insert =
        [self create_InsertSession:sessionId type:sessionType lastMsgId:messageId ctime:createTime utime:createTime];
        update = insert ? YES : NO;
    }
    if (update == NO) {
        //update session error
        NSLog(@"MSG >> error >> insert session db");
    }
    return YES;
}
//MARK: Action for Msg


- (void)actionForText:(NCProtoNetMsg *)pack {
    NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];
    //off line sys
    if (insertOk) {
        [CPInnerState.shared msgAsynCallBack:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }
    //replay
    [self clientReplay:pack];
}

- (void)actionForAudio:(NCProtoNetMsg *)pack {
    NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body.content];
    //off line sys
    if (insertOk) {
        [CPInnerState.shared msgAsynCallBack:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }
    //replay
    [self clientReplay:pack];
}

- (void)actionForImage:(NCProtoNetMsg *)pack {
    NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body];
    //off line sys
    if (insertOk) {
        [CPInnerState.shared msgAsynCallBack:insertOk];
        [CPInnerState.shared.cacheMsgManager handleOnlineMsg:insertOk];
    }
    //replay
    [self clientReplay:pack];
}

//MARK:- 群邀请
- (void)actionForGroupInvite:(NCProtoNetMsg *)pack {
    CPMessage *msg = [self _actionForGroupInvite:pack isCache:false];
    if (msg) {
        [CPInnerState.shared msgAsynCallBack:msg];
    }
}

- (CPMessage *)_actionForGroupInvite:(NCProtoNetMsg *)pack isCache:(BOOL)iscache {
    NCProtoGroupInvite *body = [NCProtoGroupInvite parseFromData:pack.data_p error:nil];
    if (!body) {
        return nil;
    }
    
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    
    User *loginUser = CPInnerState.shared.loginUser;
    std::string mePubkey = getPublicKeyFromUser(loginUser);
    std::string str_pri_key = getDecodePrivateKeyForUser(loginUser, loginUser.password);
    
    std::string decode;
    if (fromPubkey == mePubkey) {
        decode = [CPBridge ecdhDecodeMsg:nsdata2bytes(body.groupPrivateKey) prikey:str_pri_key toPubkey:toPubKey];
    } else {
        decode = [CPBridge ecdhDecodeMsg:nsdata2bytes(body.groupPrivateKey) prikey:str_pri_key toPubkey:fromPubkey];
    }
    
    NSString *groupName = body.groupName;
    NSData *groupPrivateKey = bytes2nsdata(decode);
    
    //fake send p2p
    CPMessage *msg = [[CPMessage alloc] init];
    msg.senderPubKey = hexStringFromBytes(fromPubkey);
    msg.toPubkey = hexStringFromBytes(toPubKey);
    msg.msgType = MessageTypeInviteeUser;
    msg.version = GetAppVersion();
    if (pack.head.msgTime > 1000) {
        double server_time = pack.head.msgTime / 1000.0;
        msg.createTime = server_time;
    }
    
    NSString *fake = @"Group_Invit_Msg_Content".localized;
    fake = [fake stringByReplacingOccurrencesOfString:@"#groupname#" withString:groupName];
    
    msg.msgData = [fake dataUsingEncoding:NSUTF8StringEncoding];
    msg.groupName = body.groupName;
    
    //encode
    std::string encode = [CPBridge aesEncodeData:nsdata2bytes(groupPrivateKey) byPrivateKey:str_pri_key];
    NSData *datap = bytes2nsdata(encode);
    msg.encodePrivateKey = datap;
    
    long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
    msg.signHash = sign_hash;
    
    msg.group_pub_key = body.groupPubKey;
    
    //store
    BOOL r = [self storeMessge:msg isCacheMsg:iscache];
    
    //replay
    [self clientReplay:pack];
    
    if (r) {
        return msg;
    }
    return nil;
}


//MARK:- 来了一个 群申请通知
- (void)actionForGroupJoinApproveNotify:(NCProtoNetMsg *)pack {
    [self _actionForGroupJoinApproveNotify:pack isCache:false];
}
- (CPMessage *)_actionForGroupJoinApproveNotify:(NCProtoNetMsg *)pack isCache:(BOOL)iscache
{
    NCProtoGroupJoinApproveNotify *body = [NCProtoGroupJoinApproveNotify parseFromData:pack.data_p error:nil];
    if (!body) {
        return nil;
    }
    //group info
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    CPContact *group = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:pubkey];
    if (!group) {
        return nil;
    }
    
    //store 通知
    CPGroupNotify *notify = CPGroupNotify.alloc.init;
    notify.sessionId = group.sessionId;
    notify.type = DMNotifyTypeApprove;
    notify.status = DMNotifyStatusUnread;
    notify.createTime = pack.head.msgTime / 1000;
    NSString *fromPubkey = [pack.head.fromPubKey hexString_lower];
    notify.senderPublicKey = fromPubkey;
    
    long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
    notify.signHash =  sign_hash;
    notify.approveNotify = body.data;
    notify.isAutoIncrement = true;
    BOOL r = [CPInnerState.shared.loginUserDataBase insertObject:notify into:kTableName_GroupNotify];
    if (r) {
        notify.noticeId = notify.lastInsertedRowID;
        
        [CPInnerState.shared msgAsynCallonReceiveNotify:notify];
    }
    
    return nil;
}

//MARK: 被群 群审批同意
- (void)actionForGroupJoinApproved:(NCProtoNetMsg *)pack {
    [self _actionForGroupJoinApproved:pack isCache:false];
}

- (CPMessage *)_actionForGroupJoinApproved:(NCProtoNetMsg *)pack isCache:(BOOL)iscache {
    NCProtoGroupJoinApproved *body = [NCProtoGroupJoinApproved parseFromData:pack.data_p error:nil];
    if (!body) {
        return nil;
    }
    //request info
    NCProtoGroupJoin *groupJoin =  [NCProtoGroupJoin parseFromData:body.joinMsg.data_p error:nil];
    if (!groupJoin) {
        return nil;
    }
    NSString * requestHex = [body.joinMsg.head.fromPubKey hexString_lower];
    NSString * mePubhex = [self.loginUser publicKey];
    if ([requestHex isEqualToString:mePubhex] == false) {
        return nil;
    }
    
    NSString *requestGroupPublic = [body.joinMsg.head.toPubKey hexString_lower];
    NSString *recGroupPub = [pack.head.toPubKey hexString_lower];
    if ([requestGroupPublic isEqualToString:recGroupPub] == false) {
        return nil;
    }
    
    //join private
    CPContact *group = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:recGroupPub];
    BOOL needMock = false;
    if (!group) {
        needMock = true;
    }
    
    NSString *groupName = body.groupName;
    
    //Note：解密
    std::string mePrikey = getDecodePrivateKeyForUser(self.loginUser, self.loginUser.password);
    std::string senderPubkey = nsdata2bytes(pack.head.fromPubKey);
    std::string prikeyDecode = [CPBridge ecdhDecodeMsg:nsdata2bytes(body.groupPrivateKey) prikey:mePrikey toPubkey:senderPubkey];
    
    NSData *groupPrikey = bytes2nsdata(prikeyDecode);
    
    
    [CPGroupManagerHelper joinGroupByGroupName:groupName groupPrivateKey:groupPrikey groupNotice:@"" callback:^(BOOL succss, NSString * _Nonnull msg, CPContact * _Nullable contact) {
        if (succss && needMock) {
            [CPInnerState.shared asynReadTask:^{
                NSString *rl = @"Group_Join_Suc_tip".localized;
                NSData *data = [rl dataUsingEncoding:NSUTF8StringEncoding];
                CPMessage *insertOk = [CPInnerState.shared.groupMsgRecieve _v2DealRecieveNetMsg:body.joinMsg isCache:iscache storeEncodeData:nil orOriginData:data];
                if (insertOk) {
                    [CPInnerState.shared.groupMsgRecieve addStack:insertOk];
                }
            }];
        }
    }];
    
    //notify refresh
//    [CPInnerState.shared msgAsynCallonSessionsChange:body];
    
    return nil;
}


//MARK:- 消息响应
- (void)actionForServerReceipt:(NCProtoNetMsg *)pack {
    NCProtoServerReceipt *body = [NCProtoServerReceipt parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    //去除 群邀请
    if ([body.msgName containsString:@"Group"] &&
        (![body.msgName isEqualToString:NCProtoGroupInvite.descriptor.fullName])) {
        [CPInnerState.shared.groupMsgRecieve actionForGroupReceipt:pack];
        return;
    }
    
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    
    uint64_t sign_hash_t = GetHash(nsdata2bytes(pack.head.signature));
    long long sign_hash = (long long)sign_hash_t;
    
    //response callback
    NSString *key = [@(sign_hash_t) stringValue];
    MsgResponseBack back = AllWaitResponse[key];
    if (back != nil) {
        NSMutableDictionary *response = NSMutableDictionary.dictionary;
        response[@"code"] = @(body.result);
        response[@"msg"] = body.msgName;
        [CPInnerState.shared asynDoTask:^{
            back(response);
        }];
    }
    [AllWaitResponse removeObjectForKey:key];
    
    
    //8 bytes
    WCTCondition condition =
    CPMessage.senderPubKey == hexStringFromBytes(fromPubkey) &&
    CPMessage.toPubkey == hexStringFromBytes(toPubKey) &&
    CPMessage.signHash == sign_hash;
    
    WCTOneRow *row = [self.loginUserDataBase getOneRowOnResults:{
        CPMessage.msgId}
                                                      fromTable:kTableName_Message
                                                          where:condition];
    if (row == nil) {
        return;
    }
    
    
    CPMessage *cpmsg = CPMessage.alloc.init;
    
    
    int result = 1;
    if (body.result != 0) {
        result = 2;
    }
    if (body.result == 2) {
        cpmsg.toUserNotFound = true;
    }
    
    long long msgid = [(NSNumber *)row[0] longLongValue];
    double server_time = pack.head.msgTime / 1000.0;
    NSAssert(server_time > 0, @"Message create Time Must Set 1");
    BOOL update = [self.loginUserDataBase updateRowsInTable:kTableName_Message
                                               onProperties:{CPMessage.toServerState,CPMessage.createTime}
                                                    withRow:@[@(result),@(server_time)]
                                                      where:condition];
    
    if (update == false) {
        return;
    }
    
    cpmsg.msgId = msgid;
    cpmsg.toServerState = result;
    [CPInnerState.shared msgAsynCallRecieveStatusChange:cpmsg];
}

//MARK:- 离线消息
- (void)actionForCacheMsgRsp:(NCProtoNetMsg *)pack {
    
    NCProtoCacheMsgRsp *body = [NCProtoCacheMsgRsp parseFromData:pack.data_p error:nil];
    if (!body) {
        NSLog(@"coremsg-CacheMsgRsp-body-empty");
        return;
    }
    
    uint32_t randId = body.roundId;
    if (randId != self.cacheMsgManager.fetchId) {
        NSLog(@"coremsg-CacheMsgRsp-fetchid-error");
        return;
    }
    
    if (body.msgsArray_Count == 0) {
        NSLog(@"coremsg-CacheMsgRsp-count-0");
        [self.cacheMsgManager setSysMark:YES];
        return;
    }
    NSLog(@"coremsg-CacheMsgRsp-count-OK");

    NSMutableArray<CPMessage *> *arr = NSMutableArray.array; //have new added
    //cached
    for (NCProtoNetMsg *pack in body.msgsArray) {
        CPMessage *tmpMsg;
        NSString *msgName = pack.name;
        if ([msgName isEqualToString:NCProtoText.descriptor.fullName]) {
            NCProtoText *body = [NCProtoText parseFromData:pack.data_p error:nil];
            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
        }
        else if ([msgName isEqualToString:NCProtoAudio.descriptor.fullName]) {
            NCProtoAudio *body = [NCProtoAudio parseFromData:pack.data_p error:nil];
            tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body.content];
        }
        else if ([msgName isEqualToString:NCProtoImage.descriptor.fullName]) {
              NCProtoImage *body = [NCProtoImage parseFromData:pack.data_p error:nil];
              tmpMsg = [self _dealRecieveNetMsg:pack isCache:true storeEncodeData:body];
        }
        else if ([msgName isEqualToString:NCProtoGroupInvite.descriptor.fullName]) {
            tmpMsg = [self _actionForGroupInvite:pack isCache:true];
        }
        else if ([msgName isEqualToString:NCProtoGroupJoinApproveNotify.descriptor.fullName]) {
            tmpMsg = [self _actionForGroupJoinApproveNotify:pack isCache:true];
        }
        else if ([msgName isEqualToString:NCProtoGroupJoinApproved.descriptor.fullName]) {
            tmpMsg = [self _actionForGroupJoinApproved:pack isCache:true];
        }
        
        else {
            NSLog(@"group >> chat unknown pack name %@", msgName);
        }
        
        if (tmpMsg) {
            [arr addObject:tmpMsg];
        }
    }
    
    CPMessage *lastMsg;
    NCProtoNetMsg *lastIn = body.msgsArray.lastObject;
    
    if (lastIn != nil) {
        NSLog(@"lastin %@",lastIn.descriptor.fullName);
//        NSAssert(lastIn.head.msgTime > 0, @"must > 0");
        lastMsg = CPMessage.alloc.init;
        lastMsg.createTime = lastIn.head.msgTime / 1000.0;
        long long sign_hash = (long long)GetHash(nsdata2bytes(lastIn.head.signature));
        lastMsg.signHash = sign_hash;
    }
    
    //terminal
    if (arr.count > 0) {
        [CPInnerState.shared msgAsynCallRecieveChatCaches:arr];
    }
    
    if (lastMsg && lastMsg.createTime > 0) {
        //change start point
        [self.cacheMsgManager handleCacheMsg:lastMsg];
        //start next request
        [self.cacheMsgManager _startFetchCacheMsg];
    }
    
    //replay
    [self clientReplay:pack];
}

//MARK:- 多设备登陆
- (void)actionForLogonNotify:(NCProtoNetMsg *)pack {
    [CPInnerState.shared  onLogonNotify:pack];
}

//MARK:- Recall Msg
- (void)deleteQueryRecallMsgArray:(NSArray<NCProtoRecallMsg *> *)rm
                         endTime:(int64_t)time {
    [CPInnerState.shared asynWriteTask:^{
        NSString *f, *t;
        NCProtoChatType type;
        int64_t rtime = 0;
        for (NCProtoRecallMsg *item in rm) {
            f = [item.fromPubKey hexString_lower];
            t = [item.toPubKey hexString_lower];
            type = item.chatType;
            rtime = item.timestamp / 1000.0;
            NSAssert(f.length == 130, @"uncompress");
            BOOL r = [self _recallFromHex:f toHex:t type:type time:rtime];
            if (r == YES) {
                NSLog(@"recall Msg >> query Delete Ok");
            } else {
                NSLog(@"recall Msg >> query Delete Ok");
                LogFormat(@"recall msg >> del err");
            }
        }
        
        if ([rm count] > 0) {
            [UserSettings setObject:@(time) forKey:kStart_query_time];
            [CPInnerState.shared msgAsynCallonSessionsChange:nil];
        }
    }];
}

- (void)actionForRecallMsgNotify:(NCProtoNetMsg *)pack {
    NCProtoRecallMsgNotify *body = [NCProtoRecallMsgNotify parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    NSString* fromPubkey = [pack.head.fromPubKey hexString_lower];
    NSString* toPubKey = [pack.head.toPubKey hexString_lower];
    
    double time = body.timestamp / 1000.0;
    BOOL result = [self _recallFromHex:fromPubkey toHex:toPubKey type:body.chatType time:time];
    if (result) {
        NSLog(@"recall Msg >> Delete Ok");
    }
    else {
        /// magic
        result = [self _recallFromHex:fromPubkey toHex:toPubKey type:body.chatType time:time];
        if (result == false) {
            NSLog(@"recall Msg >> Delete Error");
            LogFormat(@"recall msg >> del err");
        }
    }
    if (result) {
        CPMessage *msg = CPMessage.alloc.init;
        msg.senderPubKey = fromPubkey;
        msg.toPubkey = toPubKey;
        msg.msgType = MessageTypeWelcomNewFriends;
        msg.createTime = time + 0.001;
        long long sign_hash = (long long)GetHash(nsdata2bytes(pack.head.signature));
        msg.signHash = sign_hash;
        
        if (body.chatType == NCProtoChatType_ChatTypeSingle) {
            NSString *content;
            if ([fromPubkey isEqualToString:self.loginUser.publicKey]) {
                content = @"您的全部发言已成功撤回";
            } else {
                content = @"对方的发言已全部撤回";
            }
            msg.msgData = [content dataUsingEncoding:NSUTF8StringEncoding];
            [CPChatHelper fakeSendMsg:msg complete:nil];
        }
        else if (body.chatType == NCProtoChatType_ChatTypeGroup) {
            NSString *content;
            if ([fromPubkey isEqualToString:self.loginUser.publicKey]) {
                content = @"您的全部发言已成功撤回";
                msg.isDelete = 10;
                msg.server_msg_id = pack.head.msgId;
                msg.msgData = [content dataUsingEncoding:NSUTF8StringEncoding];
                [CPGroupChatHelper fakeSendMsg:msg complete:nil];
            }
        }
    }
    
    [CPInnerState.shared onRecallSuccessNotify:pack];
}

- (void)actionForRecallMsgFailedNotify:(NCProtoNetMsg *)pack {
    NCProtoRecallMsgFailedNotify *body = [NCProtoRecallMsgFailedNotify parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    [CPInnerState.shared onRecallFailedNotify:pack];
}


//MARK: del helper
- (BOOL)_recallFromHex:(NSString *)f
                 toHex:(NSString *)t
                  type:(NCProtoChatType)type
                  time:(double)time {
    BOOL result = false;
    if (type == NCProtoChatType_ChatTypeGroup) {
        CPContact *group = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:t];
        if (!group) {
            return false;
        }
        //Note: may infect vm syn msg
        result = [self.loginUserDataBase deleteObjectsFromTable:kTableName_GroupMessage
                                                 where:CPMessage.senderPubKey == f
                  && CPMessage.toPubkey == t
                  && CPMessage.createTime <= time];
        
    }
    else {
        
        result = [self.loginUserDataBase deleteObjectsFromTable:kTableName_Message
                                                          where:CPMessage.toPubkey == t
                  && CPMessage.senderPubKey == f
                  && CPMessage.createTime <= time];
    }
    return result;
}


//MARK:- Want Reuse Code
- (void)resendLatest_180s_unsendMsg {
    //may be leak long time
    [CPInnerState.shared asynWriteTask:^{
        double expect = NSDate.date.timeIntervalSince1970 - 180;
        NSArray* msgArray = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPMessage.class
                                                                           fromTable:kTableName_Message
                                                                               where:CPMessage.createTime > expect && (CPMessage.toServerState == 0 || CPMessage.toServerState == 3)
                                                                             orderBy:CPMessage.msgId.order(WCTOrderedDescending)
                                                                               limit:17];
        
        if (msgArray.count == 0) {
            return;
        }
        
        for (CPMessage *msg in msgArray) {
            [CPSendMsgHelper retrySendMsg:msg.msgId];
        }
    }];
}

- (void)clientReplay:(NCProtoNetMsg *)packin {
    NCProtoNetMsg *replay = CreateClientReplyMsg(packin);
    [CPInnerState.shared _pbmsgSend:replay];
}

- (CPContact * _Nullable)selectContactByPubkey:(NSString *)contactPubKey {
    CPContact * contact =
    [self.loginUserDataBase getOneObjectOfClass:CPContact.class
                                      fromTable:kTableName_Contact
                                          where:CPContact.publicKey == contactPubKey];
    
    return contact;
}

- (CPContact * _Nullable)create_InsertContactByPubkey:(NSString *)contactPubKey createTime:(double)ctime
{
    CPContact *contact = [CPContact new];
    
    NSString *pubkey_ = contactPubKey;
    contact.publicKey = pubkey_;
    contact.remark = [pubkey_ substringToIndex:12];
    
    contact.sessionType = SessionTypeP2P;
    contact.createTime = ctime;
    
    contact.status = ContactStatusStrange;
    
    contact.isAutoIncrement = YES;
    BOOL update = [self.loginUserDataBase insertObject:contact into:kTableName_Contact];
    if (update == NO) {
        NSLog(@">> error >> insert contact db");
        return nil;
    }
    contact.sessionId = contact.lastInsertedRowID;
    return contact;
}

- (CPMessage * _Nullable)selectMsgBySendPubkey:(NSString *)sendPubkey
                                      toPubkey:(NSString *)toPubkey
                                      signHash:(unsigned long long)signHash
{
    WCTCondition condition =
    CPMessage.senderPubKey == sendPubkey &&
    CPMessage.toPubkey == toPubkey &&
    CPMessage.signHash == signHash;
    
    CPMessage *row =
    [self.loginUserDataBase getOneObjectOfClass:CPMessage.class
                                      fromTable:kTableName_Message
                                          where:condition];
    
    return row;
}

- (CPSession *_Nullable)selectSessionBySessionId:(int)sid {
    CPSession *haved =
    [self.loginUserDataBase getOneObjectOfClass:CPSession.class
                                      fromTable:kTableName_Session
                                          where:CPSession.sessionId == sid];
    return haved;
}

- (CPSession *_Nullable)create_InsertSession:(int)sessionId
                                        type:(SessionType)sessionType
                                   lastMsgId:(long long)lastMsgId
                                       ctime:(double)createTime
                                       utime:(double)updateTime
{
    CPSession *session = [CPSession new];
    session.sessionId = sessionId;
    session.sessionType = sessionType;
    session.lastMsgId = lastMsgId;
    session.createTime = createTime;
    session.updateTime = updateTime;
    BOOL res = [self.loginUserDataBase insertObject:session into:kTableName_Session];
    return res ? session : nil;
}


//MARK:- Helper
- (User *)loginUser {
    return CPInnerState.shared.loginUser;
}

- (WCTDatabase *)loginUserDataBase {
    return CPInnerState.shared.loginUserDataBase;
}

- (CPOfflineMsgManager *)cacheMsgManager {
    return CPInnerState.shared.cacheMsgManager;
}



@end
