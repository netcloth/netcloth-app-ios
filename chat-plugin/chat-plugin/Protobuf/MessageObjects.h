







#ifndef MessageObjects_h
#define MessageObjects_h


#import "MessageObjectsV2Http.h"
#import "CPDataModel.h"
#import <string>


extern  NSString *const kMsg_RegisterRsp;
extern  NSString *const kMsg_Heartbeat;


BOOL CheckSignature(NCProtoNetMsg *net_msg);
extern int32_t GetAppVersion();



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




extern NCProtoNetMsg * CreateGroupCreate(NSString * group_name,
                                         int group_type, 
                                         NSString *owner_nick_name, 
                                         NSArray <NCProtoNetMsg *> *to_invitee_msgs, 
                                         
                                         const std::string &from_public_key,
                                         const std::string &to_public_key, 
                                         const std::string &pri_key 
                                         );

extern NCProtoNetMsg * CreateGroupInvite(NSData * group_private_key,
                                         NSData *group_pub_key,
                                         NSString *group_name,
                                         const std::string &from_public_key,
                                         const std::string &to_public_key, 
                                         const std::string &pri_key
                                         );

extern NCProtoNetMsg * CreateGroupJoin(NSString *nick_name,
                                       NSString * _Nullable desc, 
                                       int source, 
                                       NSString * _Nullable inviter_pub_key,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupUpdateName(NSString *groupName,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupUpdateNotice(NSString *groupNotice,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupUpdateNickName(NSString *nicknameInGroup,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);


extern NCProtoNetMsg * CreateGroupGetMemberReq(const std::string &from_public_key,
                                               const std::string &to_public_key, 
                                               const std::string &pri_key 
                                              );


extern NCProtoNetMsg * CreateGroupText(const std::string &content, 
                                       bool at_all,
                                       NSArray <NSString *> *hexPubkey_at_members,
                                       
                                       const std::string &from_public_key,
                                       const std::string &to_public_key, 
                                       const std::string &pri_key 
                                       );


extern NCProtoNetMsg * CreateGroupAudio(const std::string &content, 
                                        uint32_t playTime,
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupImage(NSString *imageId,
                                        uint32_t width,
                                        uint32_t height,
                                        
                                        const std::string &from_public_key,
                                        const std::string &to_public_key, 
                                        const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupGetMsgReq(int64_t begin_id,
                                            int64_t end_id,
                                            uint32_t count,
                                            const std::string &from_public_key,
                                            const std::string &to_public_key, 
                                            const std::string &pri_key 
);



extern NCProtoGroupUnreadReq * CreateGroupUnreadReq(int64_t lastMsgId,
                                            const std::string &group_public_key 
);


extern NCProtoNetMsg * CreateGroupGetUnreadReq(NSArray<NCProtoGroupUnreadReq *> *req_items,
                                            const std::string &from_public_key,
                                            const std::string &to_public_key, 
                                            const std::string &pri_key 
);



extern NCProtoNetMsg * CreateGroupDismiss(  const std::string &from_public_key,
                                          const std::string &to_public_key, 
                                          const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupKickReq(
                                          NSArray * kickHexpubkeys,
                                          const std::string &from_public_key,
                                          const std::string &to_public_key, 
                                          const std::string &pri_key 
);

extern NCProtoNetMsg * CreateGroupQuit(
                                          const std::string &from_public_key,
                                          const std::string &to_public_key, 
                                          const std::string &pri_key 
);



extern NCProtoNetMsg * CreateGroupUpdateInviteType(
                                                   CPGroupInviteType inviteType,
                                                   const std::string &from_public_key,
                                                   const std::string &to_public_key, 
                                                   const std::string &pri_key 
);


extern NCProtoNetMsg * CreateGroupJoinApproved( NCProtoNetMsg *join_msg,
                                               NSData * group_private_key, 
                                               NSString *group_name, 
                                               const std::string &from_public_key,
                                               const std::string &to_public_key, 
                                               const std::string &pri_key 
);


extern NCProtoNetMsg * CreateDeleteCacheMsg( NCProtoDeleteAction action,
                                            int64_t hash, 
                                            const std::string  &related_pub_key,  
                                            const std::string &from_public_key,
                                            const std::string &pri_key 
);





struct MsgPack {
    int length;
    NSData *pack; 
    int checksum;
};

const size_t kHeaderLen = 4; 
const size_t kChecksumLen = 4; 
const size_t kLeastSize = kChecksumLen; 

const int8_t kSendHeartInterval = 10;
const int8_t kHeartTimeoutInterval = 30;


@interface MessageObjects : NSObject


+ (void)configAction;
+ (SEL)actionSelectorForPack:(NSString *)pbname;



+ (NSData * _Nullable)encodeNetMsg:(NCProtoNetMsg *)pack;
+ (NCProtoNetMsg *_Nullable)decodePackFrom:(NSData *)data;

@end

#endif 
