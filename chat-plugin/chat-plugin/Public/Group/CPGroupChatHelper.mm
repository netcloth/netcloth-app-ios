//
//  CPGroupChatHelper.m
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "CPGroupChatHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <WCDB/WCDB.h>
#import <WCDB/WCTMultiSelect.h>
#import "CPBridge.h"
#import "MessageObjects.h"
#import "CPGroupSendMsgHelper.h"
#import "CPAccountHelper.h"
#import "CPContactHelper.h"
#include <string>
#import <string_tools.h>
#import "key_tool.h"

CPTimeoutDictionary<NSString *,MsgResponseBack> * const AllWaitResponse = CPTimeoutDictionary.dictionary;
NSMutableDictionary * const SpecWaitResponse = NSMutableDictionary.dictionary;

@implementation CPGroupChatHelper

//MARK:- Create
+ (void)sendCreateGroupNotify:(NSString *)groupName
                         type:(int)groupType
                ownerNickName:(NSString *)owner_nick_name
                 inviteeUsers:(NSArray *)inviteePubkeys
              groupPrivateKey:(NSData *)groupPrivateKey
                     complete:(MsgResponseBack)back {
    
    [CPInnerState.shared asynWriteTask:^{
        
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        NSData *groupPubkey = bytes2nsdata(toStrpubkey);
        NSMutableArray *array = @[].mutableCopy;
        for (NSString *pubkey in inviteePubkeys) {
            std::string str_pub_key(HexAsc2ByteString([pubkey UTF8String]));
            NCProtoNetMsg *nt = CreateGroupInvite(groupPrivateKey,groupPubkey,groupName, fromstrpubkey, str_pub_key, mySignPrikey);
            [array addObject:nt];
        }
        
        NCProtoNetMsg *nt = CreateGroupCreate(groupName, groupType, owner_nick_name, array, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        
        [CPInnerState.shared _pbmsgSend:nt];
        
    }];
}

+ (void)sendGroupInvite:(NSString *)groupName
        groupPrivateKey:(NSData *)groupPrivateKey
        groupPubKey:(NSData *)groupPubkey
          toInviteeUser:(NSString *)inviteePubkey {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = HexAsc2ByteString([inviteePubkey UTF8String]);
        
        //fake send p2p
        CPMessage *msg = [[CPMessage alloc] init];
        msg.senderPubKey = CPAccountHelper.loginUser.publicKey;
        msg.toPubkey = inviteePubkey;
        msg.msgType = MessageTypeInviteeUser;
        msg.version = GetAppVersion();
        
        NSString *fake = @"Group_Invit_Msg_Content".localized;
        fake = [fake stringByReplacingOccurrencesOfString:@"#groupname#" withString:groupName];
        fake = [fake stringByReplacingOccurrencesOfString:@"#sendername#" withString:CPInnerState.shared.loginUser.accountName];
        
        msg.msgData = [fake dataUsingEncoding:NSUTF8StringEncoding];
        msg.groupName = groupName;
        
        //encode
        std::string encode = [CPBridge aesEncodeData:nsdata2bytes(groupPrivateKey) byPrivateKey:mySignPrikey];
        NSData *datap = bytes2nsdata(encode);
        msg.encodePrivateKey = datap;
        msg.group_pub_key = groupPubkey;
        
        NCProtoNetMsg *nt = CreateGroupInvite(groupPrivateKey,groupPubkey,groupName, fromstrpubkey, toStrpubkey, mySignPrikey);
        long long sign_hash = (long long)GetHash(nsdata2bytes(nt.head.signature));
        msg.signHash = sign_hash;
        
        [CPChatHelper fakeSendMsg:msg complete:^(BOOL success, NSString * _Nonnull msg) {
            [CPInnerState.shared _pbmsgSend:nt];
        }];
    }];
}


+ (void)fakeSendMsg:(CPMessage *)msg complete:(void (^ __nullable)(BOOL success, NSString *msg))complete {
    [CPInnerState.shared asynWriteTask:^{
        BOOL r = [CPInnerState.shared.groupMsgRecieve storeMessge:msg isCacheMsg:false];
        if (r) {
            [CPInnerState.shared msgAsynCallBack:msg];
        }
        
        if (complete == nil) {
            return;
        }
        [CPInnerState.shared asynDoTask:^{
            complete(r,nil);
        }];
    }];
}

+ (void)sendRequestMemberListInGroupPublickey:(NSString *)groupPubKey
                                     complete:(MsgResponseBack)back {
    
    [CPInnerState.shared asynWriteTask:^{
        
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = bytesFromHexString(groupPubKey);
        
        NCProtoNetMsg *nt = CreateGroupGetMemberReq(fromstrpubkey, toStrpubkey, mySignPrikey);
        
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            SpecWaitResponse[key] = back;
        }
        
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}
//MARK:- Update
+ (void)sendGroupJoin:(NSString *)nickName
                 desc:(NSString * _Nullable)desc //入群描述
               source:(int)source //0 邀请  1 扫码 //2群推荐  3应用区 群推荐
        inviterPubkey:(NSString * _Nullable )inviter_pub_key// 邀请人公钥 hexstr
          groupPubkey:(NSString *)hexPubkey
             complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        std::string toStrpubkey = bytesFromHexString(hexPubkey);
        
        NCProtoNetMsg *nt = CreateGroupJoin(nickName, desc, source, inviter_pub_key,fromstrpubkey, toStrpubkey, mySignPrikey);
        
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}





+ (void)sendGroupUpdateName:(NSString *)name
            groupPrivateKey:(NSData *)groupPrivateKey
                   complete:(MsgResponseBack)back {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupUpdateName(name, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupUpdateNotice:(NSString *)notice
              groupPrivateKey:(NSData *)groupPrivateKey
                     complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupUpdateNotice(notice, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupUpdateNickName:(NSString *)nickname
                groupPrivateKey:(NSData *)groupPrivateKey
                       complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupUpdateNickName(nickname, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}
//MARK:- 群邀请机制
+ (void)sendGroupUpdateInviteType:(CPGroupInviteType)type
                  groupPrivateKey:(NSData *)groupPrivateKey
                         complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupUpdateInviteType(type, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupJoinApproved:(NCProtoNetMsg *)join_msg
              groupPrivateKey:(NSData *)groupPrivateKey
                    groupName:(NSString *)groupName
                     complete:(MsgResponseBack)back {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupJoinApproved(join_msg, groupPrivateKey, groupName, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}




//MARK:- Group Msg

+ (void)sendGroupGetMsgReq:(int64_t)beginId
                       end:(int64_t)endId
                     count:(uint32_t)count
         inGroupPrivateKey:(NSData *)groupPrivateKey
                  complete:(SynMsgComplete)back {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupGetMsgReq(beginId, endId, count, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            SpecWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupGetUnreadReq {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        NSArray<CPContact *> *array = [CPInnerState.shared.loginUserDataBase getObjectsOfClass:CPContact.class
                                                                                     fromTable:kTableName_Contact
                                                                                         where:CPContact.sessionType == SessionTypeGroup && CPContact.groupProgress >= GroupCreateProgressCreateOK];
        
        NSMutableArray *rav = NSMutableArray.array;
        for (CPContact *contact in array) {
           NSNumber *maxV = [CPInnerState.shared.loginUserDataBase
                             getOneValueOnResult:CPMessage.server_msg_id.max()
                             fromTable:kTableName_GroupMessage
                             where:CPMessage.sessionId == contact.sessionId
                             && CPMessage.isDelete != 2
                             && CPMessage.read == true];
            
            std::string pubkey = GetPublicKeyByPrivateKey(nsdata2bytes(contact.decodePrivateKey));
            NCProtoGroupUnreadReq *req =  CreateGroupUnreadReq(maxV.longLongValue, pubkey);
            [rav addObject:req];
            
        }
        
        NCProtoNetMsg *nt = CreateGroupGetUnreadReq(rav, fromstrpubkey, "", mySignPrikey);
        [CPInnerState.shared _pbmsgSend:nt];
    }];
    
}

//MARK:- Group Op
+ (void)sendGroupDismissInGroupPrivateKey:(NSData *)groupPrivateKey
                                 complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupDismiss(fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupKickReq:(NSArray *)kickPubkey
       inGroupPrivateKey:(NSData *)groupPrivateKey
                complete:(MsgResponseBack)back {
    
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupKickReq(kickPubkey, fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            SpecWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}

+ (void)sendGroupQuitInGroupPrivateKey:(NSData *)groupPrivateKey
                              complete:(MsgResponseBack)back {
    [CPInnerState.shared asynWriteTask:^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        std::string toStrpubkey = GetPublicKeyByPrivateKey(nsdata2bytes(groupPrivateKey));
        
        NCProtoNetMsg *nt = CreateGroupQuit(fromstrpubkey, toStrpubkey, mySignPrikey);
        if (back != nil) {
            uint64_t sign_hash = GetHash(nsdata2bytes(nt.head.signature));
            NSString *key = [@(sign_hash) stringValue];
            AllWaitResponse[key] = back;
        }
        [CPInnerState.shared _pbmsgSend:nt];
    }];
}


//MARK:- Join


+ (void)sendText:(NSString *)msg
         toGroup:(NSString *)pubkey
          at_all:(BOOL)atAll
      at_members:(NSArray <NSString *> *)members
{
    NSAssert(CPInnerState.shared.chatToPubkey != nil, @"must use setRoomToPubkey 2");
    [CPGroupSendMsgHelper sendMsg:msg toUser:pubkey at_all:atAll at_members:members];
}

+ (void)sendAudioData:(NSData *)data
              toGroup:(NSString *)pubkey
{
    [CPGroupSendMsgHelper sendAudioData:data toUser:pubkey];
}

+ (void)sendImageData:(NSData *)data
              toGroup:(NSString *)pubkey
{
    [CPGroupSendMsgHelper sendImageData:data toUser:pubkey];
}

@end
