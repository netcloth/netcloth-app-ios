







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPChatHelper.h"
#import "CPGroupChatHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPGroupManagerHelper : NSObject <ChatRoomInterface>


+ (void)createNormalGroupByGroupName:(NSString *)groupName
                       ownerNickName:(NSString *)owner_nick_name
                     groupPrivateKey:(NSData *)privateKey
                       groupProgress:(GroupCreateProgress)progress
                       serverAddress:(NSString * _Nullable)serverAddress
                            callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;

+ (void)joinGroupByGroupName:(NSString *)groupName
             groupPrivateKey:(NSData *)privateKey
                 groupNotice:(NSString * _Nullable)encNotice
                            callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPContact * _Nullable contact))result;





+ (void)requestServerGroupInfo:(NSString *)groupPubkey
                      callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupInfoResp * _Nullable info))result;


+ (void)updateGroupModifyTime:(int64_t)modifyTime
                    byPubkey:(NSString *)pubkey
                     callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateGroupProgress:(GroupCreateProgress)progress
                 orIpalHash:(NSString * _Nullable)txhash
                   byPubkey:(NSString *)pubkey
                   callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateGroupName:(NSString *)name
          byGroupPubkey:(NSString *)hexpubkey
               callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateGroupNotice:(NSString *)encNotice
               modifyTime:(NSTimeInterval)changeTime 
                publisher:(NSString *)changerHexPubkey
            byGroupPubkey:(NSString *)hexpubkey
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateGroupMyAlias:(NSString *)nickname
            byGroupPubkey:(NSString *)hexpubkey
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateMemberNickName:(NSString *)nickname
             memberHexPubkey:(NSString *)memberPubkey
               byGroupPubkey:(NSString *)hexpubkey
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;




+ (void)updateGroupInviteType:(int)type
          byGroupPubkey:(NSString *)hexpubkey
               callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)getGroupNotifyPreviewSessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupNotifyPreview * _Nullable preview))result;


+ (void)getDistinctGroupNotifySessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotifySession *>* notifys))result;


+ (void)getGroupDistinctSenderOfLatestNotifyInSession:(int)sessionId
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result;


+ (void)getGroupNotifyInSession:(int)sessionId
                  ofRequestUser:(NSString *)hexPubkey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result;


+ (void)updateGroupNotifyInSession:(int)sessionId
                     ofRequestUser:(NSString *)hexPubkey
                          toStatus:(DMNotifyStatus)status
                          callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)updateGroupNotifyToReadInSession:(int)sessionId
                   whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)updateGroupNotifyToReadInNoticeId:(int64_t)noticeId
                    whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;








+ (void)insertOrReplaceGroupAllMember:(NSArray<CPGroupMember *> *)member
                             callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)insertOrReplaceOneGroupAllMember:(NSArray<CPGroupMember *> *)member
                                callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)insertOrReplaceOneGroupMember:(CPGroupMember *)member
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)deleteOneGroupMember:(NSString *)memberPubkey
                   inSession:(NSInteger)sessionId
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)deleteGroupMembers:(NSArray<NSString *> *)memberPubkeys
                   inSession:(NSInteger)sessionId
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)deleteGroupAllMembersInSession:(NSInteger)sessionId
                  callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;



+ (void)getOneGroupMember:(NSString *)memberPubkey
                   inSession:(NSInteger)sessionId
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupMember *member))result;

+ (void)getAllMemberListInGroupSession:(NSInteger)sessionId
                              callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray<CPGroupMember *> * _Nullable memebers))result;





+ (void)searchContacts:(NSString *)text
              callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray<CPContact *> * _Nullable contact))result;


@end

@interface CPGroupManagerHelper ()

+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)queryMessagesInSession:(NSInteger)sessionId
              lessThenServerId:(int64_t)serverId 
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete;


+ (void)v2_queryMessagesInSession:(NSInteger)sessionId
                          beginId:(int64_t)beginId 
                            endId:(int64_t)endid
                             count:(NSInteger)wantCount 
                         complete:(void (^ __nullable)(BOOL needSyn,
                                                       int realCount,
                                                       int64_t realBeginId,
                                                       int64_t realEndId))complete;




+ (void)V2GetMessagesInSession:(NSInteger)sessionId
              beforeCreateTime:(double)createTime
                beforeServerId:(long long)serverMsgId 
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success,
                                         NSString *msg,
                                         NSArray<CPMessage *> * _Nullable recentSessions,
                                         long long firstReadServerMsgId,
                                         CPMessage * __nullable firstReadMsg, 
                                         CPMessage * __nullable atRelateMsg))complete;


@end




NS_ASSUME_NONNULL_END
