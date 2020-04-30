//
//  CPChatHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/7/31.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPSessionHelper.h"
#import "CPGroupChatHelper.h"

@protocol ChatDelegate <NSObject>

@optional
- (void)onReceiveMsg:(CPMessage *_Nonnull)msg;

/// 个人离线消息同步（比对是否是这个会话的）
- (void)onCacheMsgRecieve:(NSArray<CPMessage *> *)caches;

/// 发送消息成功状态提示
- (void)onMsgSendStateChange:(CPMessage *_Nonnull)msg;

/// Group Msg
- (void)onReceiveGroupChatMsgs:(NSArray<CPMessage *> * _Nonnull)msgs;

///must setRoomToPubkey before
/// 房间信息变化
- (void)onCurrentRoomInfoChange;

/// 首页 群未读数量
- (void)onUnreadRsp:(NSArray<CPUnreadResponse *> *)response;

/// 群申请通知
- (void)onReceiveNotify:(CPGroupNotify * _Nullable)notice;

/// (群审批通过 加群变化) 首页session 需要刷新
- (void)onSessionNeedChange:(id)change;

/// 多设备登陆
- (void)onLogonNotify:(NCProtoNetMsg *)notify;

/// 消息撤回
- (void)onRecallSuccessNotify:(NCProtoNetMsg *)successNotify;
- (void)onRecallFailedNotify:(NCProtoNetMsg *)failNotify;

@end

@protocol ChatRoomInterface;

NS_ASSUME_NONNULL_BEGIN

/// P2P chat
@interface CPChatHelper : NSObject <ChatRoomInterface>

+ (void)addInterface:(id<ChatDelegate>)delegate;
+ (void)removeInterface:(id<ChatDelegate>)delegate;

/// set current in publick
/// @param topubkey  must set
+ (void)setRoomToPubkey:(NSString * _Nullable)topubkey;

//MARK:- Send Content
+ (void)sendText:(NSString *)msg
          toUser:(NSString *)pubkey;

+ (void)sendAudioData:(NSData *)data
          toUser:(NSString *)pubkey;

//for image
+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;


//for fake, not real send ,just store local
+ (void)fakeSendMsg:(CPMessage *)msg complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;


//MARK:- 删除消息
+ (void)sendDeleteMsgAction:(NCProtoDeleteAction)action
                       hash:(int64_t)hash
            relateHexPubkey:(NSString * _Nullable)hexPubkey
                   complete:(MsgResponseBack)back;


@end


NS_ASSUME_NONNULL_END


@protocol ChatRoomInterface <NSObject>

//cannot repeat because  msg id, and you should order by your self
+ (void)getMessagesInSession:(NSInteger)sessionId
                  createTime:(double)createTime //-1 from latest page
                   fromMsgId:(long long)msgId //-1 from latest page
                        size:(NSInteger)size //default 20
                    complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete;

// delete msg
+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete;

// make msg read
+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete;


//retry msgid
+ (void)retrySendMsg:(long long)msgId;


@end
