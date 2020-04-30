//
//  MessageObjects.h
//  chat-plugin
//
//  Created by Grand on 2019/10/14.
//  Copyright © 2019 netcloth. All rights reserved.
//

#ifndef MessageObjects_h
#define MessageObjects_h

/// wrapper of pbproto
#import "MessageObjectsV2Http.h"
#import "CPDataModel.h"
#import <string>

//MARK: - Msg Names
extern  NSString *const kMsg_RegisterRsp;
extern  NSString *const kMsg_Heartbeat;


BOOL CheckSignature(NCProtoNetMsg *net_msg);
extern int32_t GetAppVersion();


//MARK:- Send
extern NCProtoNetMsg * CreateRegister(const std::string& from_public_key, const std::string &pri_key);
extern NCProtoNetMsg * CreateHeartbeat();

extern NCProtoNetMsg * CreateTextMsg(const std::string &from_public_key,
                              const std::string &to_public_key,
                              const std::string &pri_key,
                              const std::string &content);

extern NCProtoNetMsg * CreateAudioMsg(const std::string &from_public_key,
                               const std::string &to_public_key,
                               const std::string &pri_key,
                               const std::string &content,
                               uint32_t playTime);

extern NCProtoNetMsg * CreateImageMsg(const std::string &from_public_key,
                                      const std::string &to_public_key,
                                      const std::string &pri_key,
                                      NSString *imageHash,
                                      int32_t width,
                                      int32_t height);

extern NCProtoNetMsg *CreateRequestCacheMsg(const std::string &pri_key,
                                            uint32_t rand_id,
                                            uint64_t time,
                                            uint64_t hash,
                                            uint32_t size);

extern NCProtoNetMsg * CreateClientReplyMsg(NCProtoNetMsg * targetMsg);

extern NCProtoNetMsg * CreateBindAppleId(const std::string &pri_key,
                                         NSString *apple_id);

extern NCProtoNetMsg * CreateUnBindAppleId(const std::string &pri_key,
                                           NSString *apple_id);


//MARK:- Group
//must register ok , then send
extern NCProtoNetMsg * CreateGroupCreate(NSString * group_name,
                                         int group_type, /// 群类型  0: 普通群 1：禁言群
                                         NSString *owner_nick_name, // 群主昵称
                                         NSArray <NCProtoNetMsg *> *to_invitee_msgs, // 转发给邀请人的消息
                                         
                                         const std::string &from_public_key,
                                         const std::string &to_public_key, //group pubkey
                                         const std::string &pri_key //for sign
                                         );

extern NCProtoNetMsg * CreateGroupInvite(NSData * group_private_key,
                                         NSData *group_pub_key,
                                         NSString *group_name,
                                         const std::string &from_public_key,
                                         const std::string &to_public_key, //invite pubkey
                                         const std::string &pri_key
                                         );

extern NCProtoNetMsg * CreateGroupJoin(NSString *nick_name,// 入群者昵称
                                       NSString * _Nullable desc, //入群描述
                                       int source, //0 邀请  1 扫码
                                       NSString * _Nullable inviter_pub_key,// 邀请人公钥 hexstr
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupUpdateName(NSString *groupName,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupUpdateNotice(NSString *groupNotice,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupUpdateNickName(NSString *nicknameInGroup,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

//MARK:- Group Member
extern NCProtoNetMsg * CreateGroupGetMemberReq(const std::string &from_public_key,
                                               const std::string &to_public_key, //group pubkey
                                               const std::string &pri_key //for sign
                                              );

//MARK:- Group Message
extern NCProtoNetMsg * CreateGroupText(const std::string &content, //use encode content
                                       bool at_all,
                                       NSArray <NSString *> *hexPubkey_at_members,
                                       
                                       const std::string &from_public_key,
                                       const std::string &to_public_key, //group pubkey
                                       const std::string &pri_key //for sign
                                       );


extern NCProtoNetMsg * CreateGroupAudio(const std::string &content, //use encode content
                                        uint32_t playTime,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupImage(NSString *imageId,
                                        uint32_t width,
                                        uint32_t height,
                                        
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, //group pubkey
                                        const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupGetMsgReq(int64_t begin_id,
                                            int64_t end_id,
                                            uint32_t count,
                                            const std::string &from_public_key,
                                            const std::string &to_public_key, //group pubkey
                                            const std::string &pri_key //for sign
);



extern NCProtoGroupUnreadReq * CreateGroupUnreadReq(int64_t lastMsgId,
                                            const std::string &group_public_key //group pubkey
);


extern NCProtoNetMsg * CreateGroupGetUnreadReq(NSArray<NCProtoGroupUnreadReq *> *req_items,
                                            const std::string &from_public_key,
                                            const std::string &to_public_key, //group pubkey
                                            const std::string &pri_key //for sign
);


//MARK:- Group Op
extern NCProtoNetMsg * CreateGroupDismiss(  const std::string &from_public_key,
                                          const std::string &to_public_key, //group pubkey
                                          const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupKickReq(
                                          NSArray * kickHexpubkeys,
                                          const std::string &from_public_key,
                                          const std::string &to_public_key, //group pubkey
                                          const std::string &pri_key //for sign
);

extern NCProtoNetMsg * CreateGroupQuit(
                                          const std::string &from_public_key,
                                          const std::string &to_public_key, //group pubkey
                                          const std::string &pri_key //for sign
);


//MARK:- Group Manage
extern NCProtoNetMsg * CreateGroupUpdateInviteType(
                                                   CPGroupInviteType inviteType,
                                                   const std::string &from_public_key,
                                                   const std::string &to_public_key, //group pubkey
                                                   const std::string &pri_key //for sign
);

//同意入群
extern NCProtoNetMsg * CreateGroupJoinApproved( NCProtoNetMsg *join_msg,
                                               NSData * group_private_key, //群私钥
                                               NSString *group_name, //群名称
                                               const std::string &from_public_key,
                                               const std::string &to_public_key, //group pubkey
                                               const std::string &pri_key //for sign
);

//MARK:- 删除消息
extern NCProtoNetMsg * CreateDeleteCacheMsg( NCProtoDeleteAction action,
                                            int64_t hash, // DELETE_ACTION_HASH，要删除的消息hash
                                            const std::string  &related_pub_key,  // DELETE_ACTION_SESSION，传入对方的公钥
                                            const std::string &from_public_key,
                                            const std::string &pri_key //for sign
);



//MARK:- MsgPack

struct MsgPack {
    int length;
    NSData *pack; //pb NetMsg
    int checksum;
};

const size_t kHeaderLen = 4; //4
const size_t kChecksumLen = 4; //4
const size_t kLeastSize = kChecksumLen; //4

const int8_t kSendHeartInterval = 10;
const int8_t kHeartTimeoutInterval = 30;


@interface MessageObjects : NSObject

//MARK:- action mapper
+ (void)configAction;
+ (SEL)actionSelectorForPack:(NSString *)pbname;


//MARK:- for Send
+ (NSData * _Nullable)encodeNetMsg:(NCProtoNetMsg *)pack;
+ (NCProtoNetMsg *_Nullable)decodePackFrom:(NSData *)data;

@end

#endif /* MessageObjects_h */
