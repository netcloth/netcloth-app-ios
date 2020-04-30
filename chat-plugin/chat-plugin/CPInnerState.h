//
//  CPInnerHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/7/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPDataModel+secpri.h"
#import <WCDB/WCDB.h>
#import "CPChatHelper.h"
#import "LittleSetStorage.h"
#import "LittleArrayStorage.h"
#import "CPImageCaches.h"
#import "CPTools.h"

#import "ChatMessageHandleRecieve.h"
#import "GroupChatMessageHandleRecieve.h"

NS_ASSUME_NONNULL_BEGIN

@class
CPOfflineMsgManager,NCProtoNetMsg;

/// Storage for all
@interface CPInnerState : NSObject

+ (instancetype)shared;
@property (atomic, strong) NSHashTable<ChatDelegate> *chatDelegates;

//MARK:- User
@property (nonatomic, strong) User *loginUser;
@property (nonatomic, strong) WCTDatabase *loginUserDataBase; //content db

@property (nonatomic, strong) WCTDatabase *allUsersDB; //all users


//MARK:- Room In pubkey
@property (nonatomic, strong) NSString *chatToPubkey; //in this room


//MARK:-  now reset resource
- (void)userlogin;
- (void)userlogout;

//MARK:- Connect
- (BOOL)connectServiceHost:(NSString *)host
                      port:(uint16_t)port;
- (void)disconnect;
- (BOOL)isConnected;
- (BOOL)isNetworkOk;

//MARK:- Public
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg;
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg autoCallNetStatus:(id)message;

//MARK:- Msg Asyn Call Delegate
- (void)msgAsynCallBack:(id)msg;
- (void)msgAsynCallRecieveStatusChange:(id)msg;
- (void)msgAsynCallRecieveChatCaches:(NSArray<CPMessage *> *)caches;

- (void)msgAsynCallReceiveGroupChatMsgs:(NSArray<CPMessage *> *)groups;
- (void)msgAsynCallCurrentRoomInfoChange;
- (void)msgAsynCallonUnreadRsp:(NSArray<CPUnreadResponse *> *)response;

- (void)msgAsynCallonReceiveNotify:(CPGroupNotify *)notice;
- (void)msgAsynCallonSessionsChange:(id)approved;

- (void)onLogonNotify:(NCProtoNetMsg *)notify;

/// 消息撤回
- (void)onRecallSuccessNotify:(NCProtoNetMsg *)successNotify;
- (void)onRecallFailedNotify:(NCProtoNetMsg *)failNotify;

//MARK:- Task Helper
- (void)asynDoTask:(dispatch_block_t)task;    // on main queue
- (void)asynReadTask:(dispatch_block_t)task;  // readSerialQueue , read msg
- (void)asynWriteTask:(dispatch_block_t)task; // writeSerialQueue

//MARK:- Storage
@property (nonatomic, strong) CPImageCaches *imageCaches;
@property (nonatomic, strong) CPOfflineMsgManager *cacheMsgManager;
@property (nonatomic, strong) ChatMessageHandleRecieve *msgRecieve;
@property (nonatomic, strong) GroupChatMessageHandleRecieve *groupMsgRecieve;

@property (nonatomic, strong) LittleArrayStorage<CPContact *> *groupContactCache;


@end


NS_ASSUME_NONNULL_END

#import "CPOfflineMsgManager.h"

