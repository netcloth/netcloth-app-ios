//
//  CPGroupManagerHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/12/2.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPChatHelper.h"
#import "CPGroupChatHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPGroupManagerHelper : NSObject <ChatRoomInterface>

//MARK:- Insert
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



//MARK:- Update GroupInfo
///Http request
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
               modifyTime:(NSTimeInterval)changeTime //"2019-12-12T08:55:21.135Z" ->  xxx.123
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


//MARK:- 申请 和 通知
//群主设置邀请机制
+ (void)updateGroupInviteType:(int)type
          byGroupPubkey:(NSString *)hexpubkey
               callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

//通知 未读预览
+ (void)getGroupNotifyPreviewSessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, CPGroupNotifyPreview * _Nullable preview))result;

//群 通知会话
+ (void)getDistinctGroupNotifySessionCallback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotifySession *>* notifys))result;

//群通知会话内 所有不同发送者消息
+ (void)getGroupDistinctSenderOfLatestNotifyInSession:(int)sessionId
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result;

//同一个人 最近三条
+ (void)getGroupNotifyInSession:(int)sessionId
                  ofRequestUser:(NSString *)hexPubkey
                       callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray <CPGroupNotify *>* notices))result;

/// 更新一个人发送通知状态
+ (void)updateGroupNotifyInSession:(int)sessionId
                     ofRequestUser:(NSString *)hexPubkey
                          toStatus:(DMNotifyStatus)status
                          callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

/// 更新session 所有 未读通知到 已读
+ (void)updateGroupNotifyToReadInSession:(int)sessionId
                   whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

/// 更新person 未读消息 到 已读
+ (void)updateGroupNotifyToReadInNoticeId:(int64_t)noticeId
                    whereInUnreadCallback:(void(^ __nullable)(BOOL succss, NSString *msg))result;




//MARK:- Group Member

///批量更新一组群成员数据
//may many group
+ (void)insertOrReplaceGroupAllMember:(NSArray<CPGroupMember *> *)member
                             callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

//one group
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




//MARK:- Module Search
+ (void)searchContacts:(NSString *)text
              callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSArray<CPContact *> * _Nullable contact))result;


@end

@interface CPGroupManagerHelper ()

+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete;

//MARK:- Query DB
+ (void)queryMessagesInSession:(NSInteger)sessionId
              lessThenServerId:(int64_t)serverId //-1 from last
                          size:(NSInteger)size //default 20
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete;

//[)
+ (void)v2_queryMessagesInSession:(NSInteger)sessionId
                          beginId:(int64_t)beginId // must >= 1
                            endId:(int64_t)endid
                             count:(NSInteger)wantCount //default 20
                         complete:(void (^ __nullable)(BOOL needSyn,
                                                       int realCount,
                                                       int64_t realBeginId,
                                                       int64_t realEndId))complete;


/// 第一次 serverMsgId || createTime == -1 时候，
/// firstReadServerMsgId 才有效果， 其他都是0,  atRelateMsg 才有值
+ (void)V2GetMessagesInSession:(NSInteger)sessionId
              beforeCreateTime:(double)createTime
                beforeServerId:(long long)serverMsgId //-1 from latest page
                          size:(NSInteger)size //default 20
                      complete:(void (^)(BOOL success,
                                         NSString *msg,
                                         NSArray<CPMessage *> * _Nullable recentSessions,
                                         long long firstReadServerMsgId,
                                         CPMessage * __nullable firstReadMsg, // serid == firstread
                                         CPMessage * __nullable atRelateMsg))complete;


@end




NS_ASSUME_NONNULL_END
