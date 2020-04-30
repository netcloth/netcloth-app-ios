//
//  GroupChatMessageHandleRecieve.m
//  chat-plugin
//
//  Created by Grand on 2019/11/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "GroupChatMessageHandleRecieve.h"
#import "key_tool.h"
#import "string_tools.h"
#import "audio_format_tool.h"

#import <YYKit/YYKit.h>

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

@interface GroupChatMessageHandleRecieve ()
@property (nonatomic, assign) BOOL mockHack; //顺序执行
@end

@implementation GroupChatMessageHandleRecieve
{
    NSTimer *_cacheTimer;
    NSInteger _emptyCount;
    
    NSMutableArray <CPMessage *> * _msgStack;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self.class);
    [self stopTimer];
    _msgStack = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _msgStack = NSMutableArray.array;
        _emptyCount = 0;
    }
    return self;
}


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
                        orOriginData:(id)originData {
    return [self _v3DealRecieveNetMsg:msg isCache:isCache storeEncodeData:data orOriginData:originData finalDealMessage:^(CPMessage *message) {
        if (self.mockHack == true) {
            message.isDelete = 2;
        }
    }];
}

- (CPMessage * )_v3DealRecieveNetMsg:(NCProtoNetMsg *)msg
                             isCache:(BOOL)isCache
                     storeEncodeData:(id)data
                        orOriginData:(id)originData
                    finalDealMessage:(void(^ _Nullable)(CPMessage *message))beforeStore {
    
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
        if ([(NSData *)originData length] == 0) {
            cpmsg.isDelete = 1;
        }
    } else {
        return nil;
    }
    
    cpmsg.version = GetAppVersion();
    long long sign_hash = (long long)GetHash(nsdata2bytes(msg.head.signature));
    cpmsg.signHash = sign_hash;
    cpmsg.toServerState = 1;
    cpmsg.server_msg_id = msg.head.msgId;
    
    if (msg.head.msgTime > 1000) {
        double server_time = msg.head.msgTime / 1000.0;
        cpmsg.createTime = server_time;
    }
    
    /// when sender is read
    BOOL isInRoom = [cpmsg.toPubkey isEqualToString:CPInnerState.shared.chatToPubkey];//group
    BOOL isSelfSend = [cpmsg.senderPubKey isEqualToString:CPInnerState.shared.loginUser.publicKey];
    if (isInRoom || isSelfSend) {
        cpmsg.read = YES;
    }
    
    /// Recieve Msg Name
    NSString *messagename = msg.name;
    
    //control msg
    if ([messagename isEqualToString:NCProtoGroupJoin.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupJoin;
    }
    else if ([messagename isEqualToString:NCProtoGroupKick.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupKick;
    }
    else if ([messagename isEqualToString:NCProtoGroupQuit.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupQuit;
    }
    else if ([messagename isEqualToString:NCProtoGroupUpdateName.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupUpdateName;
    }
    else if ([messagename isEqualToString:NCProtoGroupUpdateNickName.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupUpdateNickName;
        cpmsg.isDelete = 1;
    }
    else if ([messagename isEqualToString:NCProtoGroupUpdateNotice.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeGroupUpdateNotice;
    }
    
    
    
    //text audio image
    else if ([messagename isEqualToString:NCProtoAudio.descriptor.fullName] ||
        [messagename isEqualToString:NCProtoGroupAudio.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeAudio;
        NCProtoGroupAudio *audio = (NCProtoGroupAudio *)data;
        if ([audio isKindOfClass:NCProtoGroupAudio.class]) {
            cpmsg.audioTimes = audio.playTime;
            cpmsg.msgData = dataHexFromBytes(nsdata2bytes(audio.content));
        }
    }
    else if ([messagename isEqualToString:NCProtoText.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeText;
    }
    else if ([messagename isEqualToString:NCProtoGroupText.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeText;
        NCProtoGroupText *body = [NCProtoGroupText parseFromData:msg.data_p error:nil];
        if (body.atAll) {
            cpmsg.useway = MessageUseWayAtAll;
        }
        else  {
            NSString *hexPubkey = CPInnerState.shared.loginUser.publicKey;
            NSData *mePubkey = [NSData dataWithHexString:hexPubkey];
            for (NSData *d in body.atMembersArray) {
                if ([d isEqualToData:mePubkey]) {
                    cpmsg.useway = MessageUseWayAtMe;
                }
            }
        }
    }
    else if ([messagename isEqualToString:NCProtoImage.descriptor.fullName] ||
             [messagename isEqualToString:NCProtoGroupImage.descriptor.fullName]) {
        cpmsg.msgType = MessageTypeImage;
        cpmsg.msgData = nil;
        NCProtoGroupImage *image = (NCProtoGroupImage *)data;
        cpmsg.fileHash = image.id_p;
        cpmsg.pixelWidth = image.width;
        cpmsg.pixelHeight = image.height;
    }
    else {
        cpmsg.msgType = MessageTypeUnknown;
    }
    
    //最后一次机会修改
    if (beforeStore) {
        beforeStore(cpmsg);
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
    //write db. contact -> message ->session  |   <<sesstion user for group
    int sessionId = 0;
    long long messageId = 0;
    SessionType sessionType = SessionTypeGroup;
    double createTime = [NSDate.date timeIntervalSince1970];
    
    //1 query group contact
    NSString *contactPubkey = message.toPubkey;
    
    //group
    CPContact *findGroup = [self selectContactByPubkey:contactPubkey];
    message.isGroupChat = true;
    
    //2 find sessionID
    if (findGroup == nil) {
        NSLog(@"MSG - findGroup - err");
        return NO;
    }
    NSAssert(findGroup.sessionType == SessionTypeGroup, @"sessionType must group");
    sessionId = findGroup.sessionId;
    
    if (findGroup.isBlack) {
        NSLog(@"MSG - Black - err");
        return false;
    }
    if (findGroup.isDoNotDisturb) {
        message.doNotDisturb = true;
    }
    
    //message
    //same msg should not insert
    //    message.senderRemark =
    message.sessionId = sessionId;
    if (message.createTime <= 10) {
        message.createTime = createTime;
    }
    message.isAutoIncrement = YES;
    
    //maybe repeat //Note: maybe slow //if (isCache) //Note: TODO: send: first signhash is 0
    CPMessage *findMsg = [self selectMsgBySendPubkey:message.senderPubKey
                                            toPubkey:message.toPubkey
                                            signHash:message.signHash
                                         serverMsgId:message.server_msg_id];
    if (findMsg != nil) {
        long long msgid = findMsg.msgId;
        message.msgId = msgid;
        NSLog(@"MSG - find - exist msg");
        return NO; //import: haved, did not show
    }
    
    NSAssert(message.createTime > 0, @"Message create Time Must Set 2");
    //insert by: multi constraint
    BOOL update = [self.loginUserDataBase insertObject:message into:kTableName_GroupMessage];
    if (update == NO) {
        NSLog(@"MSG - error >> insert groupmessage db");
        return NO;
    }
    messageId = message.lastInsertedRowID;
    message.msgId = messageId;
    
    // recent session
    CPSession *haved = [self selectSessionBySessionId:sessionId];
    if (haved) {
        //在线情况下 更新 session
        if (isCache == false && message.isDelete != 1) {
            //for group unread count
            if (message.read == false) {
                CPSession *session = [self.loginUserDataBase getOneObjectOnResults:{CPSession.groupUnreadCount} fromTable:kTableName_Session where:CPSession.sessionId == sessionId];
                
                [self.loginUserDataBase updateRowsInTable:kTableName_Session
                                             onProperties:{CPSession.groupUnreadCount}
                                                  withRow:@[@(session.groupUnreadCount + 1)]
                                                    where:CPSession.sessionId == sessionId];
            }
            update = [self.loginUserDataBase updateRowsInTable:kTableName_Session
                                                  onProperties:{CPSession.lastMsgId, CPSession.updateTime}
                                                       withRow:@[@(messageId), @(createTime)]
                                                         where:CPSession.sessionId == sessionId];
        }
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

//MARK:-  消息响应
//for mock server
- (void)actionForGroupReceipt:(NCProtoNetMsg *)pack {
    NCProtoServerReceipt *body = [NCProtoServerReceipt parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    
    //8 bytes
    uint64_t sign_hash = GetHash(nsdata2bytes(pack.head.signature));
    long long sign_hash_t = (long long)sign_hash;
    
    //response
    NSString *key = [@(sign_hash) stringValue];
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
    
    WCTCondition condition =
    CPMessage.senderPubKey == hexStringFromBytes(fromPubkey) &&
    CPMessage.toPubkey == hexStringFromBytes(toPubKey) &&
    CPMessage.signHash == sign_hash_t &&
    CPMessage.server_msg_id == 0;
    
    WCTOneRow *row = [self.loginUserDataBase getOneRowOnResults:{CPMessage.msgId}
                                                      fromTable:kTableName_GroupMessage
                                                          where:condition];
    if (row == nil) {
        NSLog(@"group >> error >> find status");
        return;
    }
    
    CPMessage *cpmsg = CPMessage.alloc.init;
    int result = 1;
    if (body.result != ChatErrorCodeOK) {
        result = 2;
    }
    
    int64_t server_msg_id = pack.head.msgId;
    long long msgid = [(NSNumber *)row[0] longLongValue];
    double server_time = pack.head.msgTime / 1000.0;
    NSAssert(server_time > 0, @"Message create Time Must Set 2");
    BOOL update = [self.loginUserDataBase updateRowsInTable:kTableName_GroupMessage
                                               onProperties:{CPMessage.toServerState,CPMessage.createTime, CPMessage.server_msg_id}
                                                    withRow:@[@(result),@(server_time),@(server_msg_id)]
                                                      where:condition];
    
    if (update == false) {
        NSLog(@"group >> error >> update status");
        return;
    }
    
    cpmsg.msgId = msgid;
    cpmsg.toServerState = result;
    cpmsg.server_msg_id = server_msg_id;
    [CPInnerState.shared msgAsynCallRecieveStatusChange:cpmsg];
}




//MARK:- Group Msgs
- (void)actionForGroupText:(NCProtoNetMsg *)pack {
    [self _actionForGroupText:pack isCache:false];
}

- (void)_actionForGroupText:(NCProtoNetMsg *)pack  isCache:(BOOL)isCache {
    NCProtoGroupText *body = [NCProtoGroupText parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:isCache storeEncodeData:body.content];
    if (insertOk) {
        [self addStack:insertOk];
    }
    if (isCache == false) {
        //replay
        [self clientReplay:pack];
    }
}


- (void)actionForGroupAudio:(NCProtoNetMsg *)pack {
    [self _actionForGroupAudio:pack isCache:false];
}

- (void)_actionForGroupAudio:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupAudio *body = [NCProtoGroupAudio parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body];
    if (insertOk) {
        [self addStack:insertOk];
    }
    if (isCache == false) {
        //replay
        [self clientReplay:pack];
    }
}


- (void)actionForGroupImage:(NCProtoNetMsg *)pack {
    [self _actionForGroupImage:pack isCache:false];
}
- (void)_actionForGroupImage:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupImage *body = [NCProtoGroupImage parseFromData:pack.data_p error:nil];
    CPMessage *insertOk = [self _dealRecieveNetMsg:pack isCache:false storeEncodeData:body];
    
    if (insertOk) {
        [self addStack:insertOk];
    }
    if (isCache == false) {
        //replay
        [self clientReplay:pack];
    }
}

//MARK:- 首页获取 未读数量
- (void)actionForGroupGetUnreadRsp:(NCProtoNetMsg *)pack {
    NSError *error;
    NCProtoGroupGetUnreadRsp *body = [NCProtoGroupGetUnreadRsp parseFromData:pack.data_p error:&error];
    if (!body) {
        return;
    }
    NSMutableArray *responseArray = NSMutableArray.array;
    for (NCProtoGroupUnreadRsp *rsp  in body.rspItemsArray) {
        if (rsp.result == ChatErrorCodeOK) {
            CPUnreadResponse *unRead = CPUnreadResponse.alloc.init;
            unRead.groupHexPubkey = [rsp.groupPubKey hexString_lower];
            unRead.unreadCount = rsp.unreadCount;
            unRead.lastMsg = nil;
            
            [responseArray addObject:unRead];
            
            //Note： 解析最后一次的msg
            self.mockHack = true;
            [self doLogicForMsg:rsp.lastMsg isCache:false];
            self.mockHack = false;
        }
    }
    if (responseArray.count > 0) {
        [CPInnerState.shared msgAsynCallonUnreadRsp:responseArray];
    }
}

//MARK:- Group OP
//MARK: 修改群名

- (void)actionForGroupUpdateName:(NCProtoNetMsg *)pack {
    [self _actionForGroupUpdateName:pack isCache:false];
}

- (void)_actionForGroupUpdateName:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupUpdateName *body = [NCProtoGroupUpdateName parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    NSString *name = body.name;
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    
    CPContact *find = [self findCacheContactByGroupPubkey:pubkey];
    if (find == nil) {
        NSLog(@"group >> error >> notfound >> GroupUpdateName");
        return;
    }
    
    //sender master name
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    NSString *hexpubkey = hexStringFromBytes(fromPubkey);
    
    CPContact *contact =
    [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPContact.class fromTable:kTableName_Contact where:CPContact.publicKey == hexpubkey];
    
    CPGroupMember *member =
    [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPGroupMember.class fromTable:kTableName_GroupMember where:CPGroupMember.hexPubkey == hexpubkey];
    
    NSString *owerName = contact.remark ?: member.nickName;
    NSString *tips = [NSString stringWithFormat:@"\"%@\"%@\"%@\"",owerName,@"modify group name".localized,name];
    NSData *data = [tips dataUsingEncoding:NSUTF8StringEncoding];
    
    CPMessage *insertOk = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:data];
    
    if (insertOk) {
        [self addStack:insertOk];
    }
    
    //info change
    if (isCache == false) {
        
        [CPGroupManagerHelper updateGroupName:name byGroupPubkey:pubkey callback:nil];
        
        [self clientReplay:pack];
        
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}

//MARK: 群公告

- (void)actionForGroupUpdateNotice:(NCProtoNetMsg *)pack {
    [self _actionForGroupUpdateNotice:pack isCache:false];
}
- (void)_actionForGroupUpdateNotice:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupUpdateNotice *body = [NCProtoGroupUpdateNotice parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    NSString *notice = body.notice;
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    CPContact *find = [self findCacheContactByGroupPubkey:pubkey];
    if (find == nil) {
        NSLog(@"group >> error >> notfound >> GroupUpdateNotice");
        return;
    }
    
    double diff_s = pack.head.msgTime / 1000.0;
    
    std::string fromPubkey = nsdata2bytes(pack.head.fromPubKey);
    NSString *hexpubkey = hexStringFromBytes(fromPubkey);
    
    //group notice //encode
    NSData *data = [notice dataUsingEncoding:NSUTF8StringEncoding];
    CPMessage *insertOk = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:data];
    if (insertOk) {
        [self addStack:insertOk];
    }
    
    
    if (isCache == false) {
        [CPGroupManagerHelper updateGroupNotice:notice
                                     modifyTime:diff_s
                                      publisher:hexpubkey
                                  byGroupPubkey:pubkey
                                       callback:nil];
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
        
        [self clientReplay:pack];
    }
}

//MARK: 修改群昵称
- (void)actionForGroupUpdateNickName:(NCProtoNetMsg *)pack {
    [self _actionForGroupUpdateNickName:pack isCache:false];
}

- (void)_actionForGroupUpdateNickName:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupUpdateNickName *body = [NCProtoGroupUpdateNickName parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    NSString *nickname = body.nickName;
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    CPContact *find = [self findCacheContactByGroupPubkey:pubkey];
    if (find == nil) {
        NSLog(@"group >> error >> notfound >> GroupUpdateNickName");
        return;
    }
    
    std::string fromPubKey = nsdata2bytes(pack.head.fromPubKey);
    NSString *memberPubkey = hexStringFromBytes(fromPubKey);
    
    //hidden delete //set delete
    CPMessage *insertOk = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:NSData.data];
    
    if (isCache == false) {
        //change member nickname
        [CPGroupManagerHelper updateMemberNickName:nickname memberHexPubkey:memberPubkey byGroupPubkey:pubkey callback:nil];
        [self clientReplay:pack];
        
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}

//MARK: 加入群
- (void)actionForGroupJoin:(NCProtoNetMsg *)pack {
    [self _actionForGroupJoin:pack isCache:false];
}

- (void)_actionForGroupJoin:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    
    NCProtoGroupJoin *body = [NCProtoGroupJoin parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    CPMessage *insertOk;
    NSString *fromHexpub = [pack.head.fromPubKey hexString_lower];
    NSString *nickname = body.nickName;
    
    NSString *groupPubkey =  [pack.head.toPubKey hexString_lower];
    CPContact *find = [self findCacheContactByGroupPubkey:groupPubkey];
    if (find == nil) {
        NSLog(@"group >> error >> notfound >> groupjoin");
        return;
    }
    
    if ([fromHexpub isEqualToString:CPAccountHelper.loginUser.publicKey]) {
        NSString *rl = @"Group_Join_Suc_tip".localized;
        NSData *data = [rl dataUsingEncoding:NSUTF8StringEncoding];
        insertOk = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:data];
    }
    else {
        NSString *rl = @"Group_Joined_tip".localized;
        rl = [rl stringByReplacingOccurrencesOfString:@"#mark#" withString:nickname];
        NSData *data = [rl dataUsingEncoding:NSUTF8StringEncoding];
        insertOk = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:data];
    }
    
    //off line sys
    if (insertOk) {
        [self addStack:insertOk];
    }
    
    if (isCache == false) {
        //save member
        CPGroupMember *gm = [self groupMemberFactory:find.sessionId hexpubkey:fromHexpub nickName:nickname role:GroupRoleMember joinTime:pack.head.msgTime];
        [CPGroupManagerHelper insertOrReplaceOneGroupMember:gm callback:nil];
        
        //replay
        [self clientReplay:pack];
        
        //info change
        std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
        NSString *pubkey = hexStringFromBytes(toPubKey);
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}

//MARK: 群解散
- (void)actionForGroupDismiss:(NCProtoNetMsg *)pack {
    NCProtoGroupDismiss *body = [NCProtoGroupDismiss parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    
    [CPGroupManagerHelper updateGroupProgress:GroupCreateProgressDissolve orIpalHash:nil byPubkey:pubkey callback:^(BOOL succss, NSString * _Nonnull msg) {
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }];
}

//MARK: 群主T人响应 动作 没有 msg id
//群主 t人 响应
- (void)actionForGroupKickRsp:(NCProtoNetMsg *)pack {
    NCProtoGroupKickRsp *body = [NCProtoGroupKickRsp parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    //response //8 bytes
    uint64_t sign_hash = GetHash(nsdata2bytes(pack.head.signature));
    long long sign_hash_t = (long long)sign_hash;
    NSString *key = [@(sign_hash) stringValue];
    MsgResponseBack back = SpecWaitResponse[key];
    if (back != nil) {
        NSMutableDictionary *response = NSMutableDictionary.dictionary;
        response[@"code"] = @(body.result);
        response[@"msg"] = NCProtoGroupKickRsp.descriptor.fullName;
        [CPInnerState.shared asynDoTask:^{
            back(response);
        }];
    }
    [SpecWaitResponse removeObjectForKey:key];
    
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    
    CPContact *group = [self findCacheContactByGroupPubkey:pubkey];
    if (!group) {
        NSLog(@"group >> error >> notfound >> GroupKickRsp");
        return;
    }
    
    //task response
    NSMutableArray *array = NSMutableArray.array;
    for(NCProtoGroupKickResult *kick in body.kickResultArray) {
        if (kick.result == ChatErrorCodeOK) {
            NSString *hexPubkey = hexStringFromBytes(nsdata2bytes(kick.kickPubKey));
            [array addObject:hexPubkey];
        }
    }
    
    //fake send msg
    NSString *hexpubkey = array.firstObject;
    if ([NSString cp_isEmpty:hexpubkey] == false) {
        CPGroupMember *findMember =  [CPInnerState.shared.loginUserDataBase getOneObjectOnResults:{CPGroupMember.nickName}
                                                                                        fromTable:kTableName_GroupMember
                                                                                            where:CPGroupMember.sessionId == group.sessionId &&
                                      CPGroupMember.hexPubkey == hexpubkey];
        if ([NSString cp_isEmpty:findMember.nickName] == false) {
            
            CPMessage *msg = CPMessage.alloc.init;
            msg.senderPubKey = [self loginUser].publicKey;
            msg.toPubkey = pubkey;
            msg.msgType = MessageTypeGroupKick;
            NSString *content = @"Group_Room_Kick_Master".localized;
            content = [content stringByReplacingOccurrencesOfString:@"#mark#" withString:findMember.nickName];
            
            msg.msgData = [content dataUsingEncoding:NSUTF8StringEncoding];
            msg.signHash = [CPBridge getRandomHash];
            [CPGroupChatHelper fakeSendMsg:msg complete:nil];
        }
    }
    
    //del
    [CPGroupManagerHelper deleteGroupMembers:array inSession:group.sessionId callback:nil];
    
    //info change
    if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
        [self callCurrentRoomInfoChange];
    }
}


//MARK: T人通知
- (void)actionForGroupKick:(NCProtoNetMsg *)pack {
    [self _actionForGroupKick:pack isCache:false];
}

- (void)_actionForGroupKick:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupKick *body = [NCProtoGroupKick parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    //group info
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    
    CPContact *group = [self findCacheContactByGroupPubkey:pubkey];
    if (!group) {
        NSLog(@"group >> error >> notfind GroupKick");
        return;
    }
    
    //task response
    NSMutableArray *array = NSMutableArray.array;
    for(NSData *kickPub in body.kickedPubKeysArray) {
        NSString *hexPubkey =  hexStringFromBytes(nsdata2bytes(kickPub));
        [array addObject:hexPubkey];
    }
    
    //store to db
    CPMessage *insert;
    NSString *mepubkey = CPAccountHelper.loginUser.publicKey;
    if ([array containsObject:mepubkey]) {
        //self kicked
        if (isCache == false) {
            [CPGroupManagerHelper updateGroupProgress:GroupCreateProgressKicked orIpalHash:nil byPubkey:pubkey callback:nil];
        }
        NSData *data = [@"Group_Room_Kick_Msg".localized dataUsingEncoding:NSUTF8StringEncoding];
        insert = [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:data];
    }
    else {
        [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:NSData.data];
    }
    
    if (insert) {
        [self addStack:insert];
    }
    
    if (isCache == false) {
        [CPGroupManagerHelper deleteGroupMembers:array inSession:group.sessionId callback:nil];
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}

//MARK: 群成员离开
- (void)actionForGroupQuit:(NCProtoNetMsg *)pack {
    [self _actionForGroupQuit:pack isCache:false];
}
- (void)_actionForGroupQuit:(NCProtoNetMsg *)pack isCache:(BOOL)isCache {
    NCProtoGroupQuit *body = [NCProtoGroupQuit parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    //group info
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    CPContact *group = [self findCacheContactByGroupPubkey:pubkey];
    if (!group) {
        return;
    }
    //set not show
    [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:NSData.data];
    
    if (isCache == false) {
        std::string fromPubKey = nsdata2bytes(pack.head.fromPubKey);
        NSString *fromPubHex = hexStringFromBytes(fromPubKey);
        
        [CPGroupManagerHelper deleteOneGroupMember:fromPubHex inSession:group.sessionId callback:nil];
        
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}

//MARK: 群 邀请机制
- (void)actionForGroupUpdateInviteType:(NCProtoNetMsg *)pack {
    [self _actionForGroupUpdateInviteType:pack isCache:false];
}
- (void)_actionForGroupUpdateInviteType:(NCProtoNetMsg *)pack isCache:(BOOL)isCache
{
    NCProtoGroupUpdateInviteType *body = [NCProtoGroupUpdateInviteType parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    //group info
    std::string toPubKey = nsdata2bytes(pack.head.toPubKey);
    NSString *pubkey = hexStringFromBytes(toPubKey);
    CPContact *group = [self findCacheContactByGroupPubkey:pubkey];
    if (!group) {
        return;
    }
    
    //set not show
    [self _v2DealRecieveNetMsg:pack isCache:isCache storeEncodeData:nil orOriginData:NSData.data];
    
    if (isCache == false) {
        [CPGroupManagerHelper updateGroupInviteType:body.inviteType byGroupPubkey:pubkey callback:nil];
        
        //info change
        if ([pubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
    }
}


//MARK:- 群历史消息 同步
- (void)actionForGroupGetMsgRsp:(NCProtoNetMsg *)pack {
    NCProtoGroupGetMsgRsp *body = [NCProtoGroupGetMsgRsp parseFromData:pack.data_p error:nil];
    if (!body) {
        return;
    }
    
    //先去刷新 handle all msgs
    for (NCProtoNetMsg *msg in body.msgsArray) {
        [self doLogicForMsg:msg isCache:true];
    }
    
    //response back
    uint64_t sign_hash = GetHash(nsdata2bytes(pack.head.signature));
    NSString *key = [@(sign_hash) stringValue];
    SynMsgComplete back = (SynMsgComplete)SpecWaitResponse[key];
    if (back != nil) {
        [CPInnerState.shared asynDoTask:^{
            back(body);
        }];
        [SpecWaitResponse removeObjectForKey:key];
    }
    
 
    
    [self clientReplay:pack];
}

- (void)doLogicForMsg:(NCProtoNetMsg *)msg isCache:(BOOL)isCache {
    if (msg == nil) {
        return;
    }
    NSString *msgName = msg.name;
    if ([msgName isEqualToString:NCProtoGroupText.descriptor.fullName]) {
        [self _actionForGroupText:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupAudio.descriptor.fullName]) {
        [self _actionForGroupAudio:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupImage.descriptor.fullName]) {
        [self _actionForGroupImage:msg isCache:isCache];
    }
    
    //for control
    else if ([msgName isEqualToString:NCProtoGroupUpdateName.descriptor.fullName]) {
        [self _actionForGroupUpdateName:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupUpdateNotice.descriptor.fullName]) {
        [self _actionForGroupUpdateNotice:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupUpdateNickName.descriptor.fullName]) {
        [self _actionForGroupUpdateNickName:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupJoin.descriptor.fullName]) {
        [self _actionForGroupJoin:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupDismiss.descriptor.fullName]) {
        [self actionForGroupDismiss:msg];
    }
    else if ([msgName isEqualToString:NCProtoGroupKick.descriptor.fullName]) {
        [self _actionForGroupKick:msg isCache:isCache];
    }
    else if ([msgName isEqualToString:NCProtoGroupQuit.descriptor.fullName]) {
        [self _actionForGroupQuit:msg isCache:isCache];
    }
}


//MARK:- 群成员人列表
- (void)actionForGroupGetMemberRsp:(NCProtoNetMsg *)pack {
    
    NCProtoGroupGetMemberRsp *body = [NCProtoGroupGetMemberRsp parseFromData:pack.data_p error:nil];
    int result = body.result;
    NSString *groupPubkey =  [pack.head.toPubKey hexString_lower];
    
    if (result != 0) {
        
        if (result == ChatErrorCodeMemberNotExist) {
            //被t
            [CPGroupManagerHelper updateGroupProgress:GroupCreateProgressKicked orIpalHash:nil byPubkey:groupPubkey callback:nil];
        }
        else if (result == ChatErrorCodeGroupNotExist) {
            //解散
            [CPGroupManagerHelper updateGroupProgress:GroupCreateProgressDissolve orIpalHash:nil byPubkey:groupPubkey callback:nil];
        }
        //info change
        if ([groupPubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
            [self callCurrentRoomInfoChange];
        }
        NSLog(@"group >> error >> result %d",result);
        return;
    }
    
    
    CPContact *find = [self findCacheContactByGroupPubkey:groupPubkey];
    if (find == nil) {
        NSLog(@"group >> error >> notfound");
        return;
    }
    
    int64_t modified_time = body.modifiedTime;
    
    NSMutableArray<NCProtoGroupMember*> * members =  body.membersArray;
    NSAssert(members.count > 0, @"group >> error >> members empty");
    NSMutableArray *groups = NSMutableArray.array;
    for (NCProtoGroupMember *item in members) {
        CPGroupMember *gm = [self groupMemberFactory:find.sessionId
                                           hexpubkey:[item.pubKey hexString_lower]
                                            nickName:item.nickName
                            role:GroupRole((int)NCProtoGroupMember_Role_RawValue(item))
                                            joinTime:item.joinTime];
        [groups addObject:gm];
    }
    
    void (^sucExe)() = ^{
        [CPGroupManagerHelper updateGroupModifyTime:modified_time byPubkey:groupPubkey callback:nil];
        
        //response back
        uint64_t sign_hash = GetHash(nsdata2bytes(pack.head.signature));
        NSString *key = [@(sign_hash) stringValue];
        MsgResponseBack back = SpecWaitResponse[key];
        if (back != nil) {
            NSMutableDictionary *response = NSMutableDictionary.dictionary;
            response[@"code"] = @(result);
            response[@"msg"] = @"succ";
            response[@"id"] = @(pack.head.msgId);
            [CPInnerState.shared asynDoTask:^{
                back(response);
            }];
        }
        [SpecWaitResponse removeObjectForKey:key];
    };
    
    if (members.count == 0) {
        [CPGroupManagerHelper deleteGroupAllMembersInSession:find.sessionId callback:^(BOOL succss, NSString * _Nonnull msg) {
            if (succss) {
                sucExe();
            }
        }];
    }
    else {
        [CPGroupManagerHelper insertOrReplaceOneGroupAllMember:groups callback:^(BOOL succss, NSString * _Nonnull msg) {
            if (succss == true) {
                sucExe();
            }
        }];
    }
    
    //info change
    if ([groupPubkey isEqualToString:CPInnerState.shared.chatToPubkey]) {
        [self callCurrentRoomInfoChange];
    }
    
    //replay
    [self clientReplay:pack];
}







//MARK:- Tool
- (void)callCurrentRoomInfoChange {
    [CPInnerState.shared msgAsynCallCurrentRoomInfoChange];
}


- (CPContact * _Nullable)findCacheContactByGroupPubkey:(NSString *)groupPubkey {
    CPContact *find = [CPInnerState.shared.groupContactCache getObjectBy:^BOOL(CPContact *contact) {
        if ([contact.publicKey isEqualToString:groupPubkey] &&
            (contact.sessionType == SessionTypeGroup)) {
            return YES;
        }
        return false;
    }];
    if (find == nil) {
        NSLog(@"group >> issue >> notfound");
        CPContact *db =
        
        [CPInnerState.shared.loginUserDataBase
         getOneObjectOfClass:CPContact.class
         fromTable:kTableName_Contact
         where:CPContact.publicKey == groupPubkey];
        
        if (db.sessionType == SessionTypeGroup) {
            find = db;
            [CPInnerState.shared.groupContactCache addObject:find];
        }
        else {
            NSLog(@"group >> error >> notfound");
        }
    }
    return find;
}

//MARK:- Timer
- (void)startTimer {
    [self stopTimer];
    @weakify(self);
    _cacheTimer = [NSTimer timerWithTimeInterval:0.2 block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        [self onTimerIntervalFire];
    } repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:_cacheTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_cacheTimer invalidate];
    _cacheTimer = nil;
}

- (void)onTimerIntervalFire {
    [self dispatchStack];
}

//MARK:- Msg Patch
- (void)addStack:(CPMessage *)msg {
    msg.isGroupChat = true;
    dispatch_async_on_main_queue(^{
        if (self->_cacheTimer.isValid == NO) {
            [self startTimer];
        }
        [self->_msgStack addObject:msg];
        if (self->_msgStack.count > 10) {
            [self dispatchStack];
        }
    });
}

- (void)dispatchStack {
    dispatch_async_on_main_queue(^{
        if (self->_msgStack.count <= 0) {
            //累计10s 无人发群消息，暂停timer
            self->_emptyCount += 1;
            if (self->_emptyCount > 5 * 10) {
                [self stopTimer];
                self->_emptyCount = 0;
            }
            return;
        }
        
        NSArray *pop = [self->_msgStack copy]; //Note:
        [CPInnerState.shared msgAsynCallReceiveGroupChatMsgs:pop];
        [self->_msgStack removeAllObjects];
    });
}



//MARK:- Want Reuse Code
- (CPGroupMember *)groupMemberFactory:(int)sessionId
                            hexpubkey:(NSString *)pubkey
                             nickName:(NSString *)name
                                 role:(GroupRole)memberRole
                             joinTime:(int64_t)time {
    CPGroupMember *gm = CPGroupMember.alloc.init;
    gm.sessionId = sessionId;
    gm.hexPubkey = pubkey;
    gm.nickName = name;
    gm.role =  memberRole;
    gm.join_time =  time;
    return gm;
}

- (void)resendLatest_180s_unsendMsg {
    
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
    return nil;
}

- (CPMessage * _Nullable)selectMsgBySendPubkey:(NSString *)sendPubkey
                                      toPubkey:(NSString *)toPubkey
                                      signHash:(unsigned long long)signHash
                                   serverMsgId:(int64_t)smid
{
    WCTCondition condition =
    CPMessage.senderPubKey == sendPubkey &&
    CPMessage.toPubkey == toPubkey &&
    CPMessage.signHash == signHash &&
    CPMessage.server_msg_id == smid;
    
    CPMessage *row =
    [self.loginUserDataBase getOneObjectOfClass:CPMessage.class
                                      fromTable:kTableName_GroupMessage
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

@end
