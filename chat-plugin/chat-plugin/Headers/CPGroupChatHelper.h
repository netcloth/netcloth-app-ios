//
//  CPGroupChatHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPTimeoutDictionary.h"

/*
 response[@"code"] = @(body.result);
 response[@"msg"] = body.msgName;
 */
typedef void(^__nullable MsgResponseBack)(NSDictionary *response);

/// 同步group 消息 回调
typedef void(^ __nullable SynMsgComplete)(NCProtoGroupGetMsgRsp *response);

extern CPTimeoutDictionary <NSString *,MsgResponseBack> * const AllWaitResponse;
extern NSMutableDictionary * const SpecWaitResponse;

//for result of Receipt
typedef NS_ENUM(NSInteger, ChatErrorCode) {
    ChatErrorCodeOK                 = 0,
    ChatErrorCodePartialOK          = 1001, //部分成功
    ChatErrorCodeInternalServer     = 1002,
    ChatErrorCodeMessageInvalid     = 1003,
    ChatErrorCodeMessageUnsupport   = 1004,
    
    ChatErrorCodeGroupDuplicate     = 1005,
    ChatErrorCodeGroupNotExist      = 1006,
    ChatErrorCodeNoPermission       = 1007,
    
    ChatErrorCodeMemberDuplicate    = 1008,
    ChatErrorCodeMemberNotExist     = 1009,
    ChatErrorCodeMemberExceed       = 1010,
    
    ChatErrorCodeGroupPubKeyInvalid = 1011,
    ChatErrorCodeGroupNotClaim      = 1012,
    ChatErrorCodeGroupNotBelongToMe = 1013,
};


@interface CPGroupChatHelper : NSObject


+ (void)fakeSendMsg:(CPMessage *)msg complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

//MARK:- 创建 加入
//send if it ipal ok
+ (void)sendCreateGroupNotify:(NSString *)groupName
                         type:(int)groupType
                ownerNickName:(NSString *)owner_nick_name
                 inviteeUsers:(NSArray *)inviteePubkeys
              groupPrivateKey:(NSData *)groupPrivateKey
                     complete:(MsgResponseBack)back;

+ (void)sendGroupJoin:(NSString *)nickName
                 desc:(NSString * _Nullable)desc //入群描述
               source:(int)source //0 邀请  1 扫码
        inviterPubkey:(NSString * _Nullable )inviter_pub_key// 邀请人公钥 hexstr
          groupPubkey:(NSString *)hexPubkey
             complete:(MsgResponseBack)back;


//MARK:- Update
+ (void)sendGroupUpdateName:(NSString *)name
            groupPrivateKey:(NSData *)groupPrivateKey
                   complete:(MsgResponseBack)back;

+ (void)sendGroupUpdateNotice:(NSString *)notice
              groupPrivateKey:(NSData *)groupPrivateKey
                     complete:(MsgResponseBack)back;

+ (void)sendGroupUpdateNickName:(NSString *)nickname
                groupPrivateKey:(NSData *)groupPrivateKey
                       complete:(MsgResponseBack)back;

//MARK:- 群邀请机制
//群邀请
+ (void)sendGroupInvite:(NSString *)groupName
        groupPrivateKey:(NSData *)groupPrivateKey
            groupPubKey:(NSData *)groupPubkey
          toInviteeUser:(NSString *)inviteePubkey;

+ (void)sendGroupUpdateInviteType:(CPGroupInviteType)type
                  groupPrivateKey:(NSData *)groupPrivateKey
                       complete:(MsgResponseBack)back;

//审批通过
+ (void)sendGroupJoinApproved:(NCProtoNetMsg *)join_msg
              groupPrivateKey:(NSData *)groupPrivateKey
                    groupName:(NSString *)groupName
                     complete:(MsgResponseBack)back;

//MARK:- OP
+ (void)sendGroupDismissInGroupPrivateKey:(NSData *)groupPrivateKey
                                 complete:(MsgResponseBack)back;

+ (void)sendGroupKickReq:(NSArray *)kickPubkey
       inGroupPrivateKey:(NSData *)groupPrivateKey
                complete:(MsgResponseBack)back;

+ (void)sendGroupQuitInGroupPrivateKey:(NSData *)groupPrivateKey
         complete:(MsgResponseBack)back;



//MARK:- 消息同步
+ (void)sendGroupGetMsgReq:(int64_t)beginId
                       end:(int64_t)endId
                     count:(uint32_t)count
         inGroupPrivateKey:(NSData *)groupPrivateKey
                  complete:(SynMsgComplete)back;

+ (void)sendRequestMemberListInGroupPublickey:(NSString *)groupPubKey
                                     complete:(MsgResponseBack)back;


//MARK:- 群聊未读数
+ (void)sendGroupGetUnreadReq;


//MARK:- <#[注释]#>


//auto save to db
+ (void)sendText:(NSString *)msg
         toGroup:(NSString *)pubkey
          at_all:(BOOL)atAll
      at_members:(NSArray <NSString *> *)members;

+ (void)sendAudioData:(NSData *)data
              toGroup:(NSString *)pubkey;

//for image
+ (void)sendImageData:(NSData *)data
              toGroup:(NSString *)pubkey;

@end


