







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


@interface CPInnerState : NSObject

+ (instancetype)shared;
@property (atomic, strong) NSHashTable<ChatDelegate> *chatDelegates;


@property (nonatomic, strong) User *loginUser;
@property (nonatomic, strong) WCTDatabase *loginUserDataBase; 

@property (nonatomic, strong) WCTDatabase *allUsersDB; 



@property (nonatomic, strong) NSString *chatToPubkey; 



- (void)userlogin;
- (void)userlogout;


- (BOOL)connectServiceHost:(NSString *)host
                      port:(uint16_t)port;
- (void)disconnect;
- (BOOL)isConnected;
- (BOOL)isNetworkOk;


- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg;
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg autoCallNetStatus:(id)message;


- (void)msgAsynCallBack:(id)msg;
- (void)msgAsynCallRecieveStatusChange:(id)msg;
- (void)msgAsynCallRecieveChatCaches:(NSArray<CPMessage *> *)caches;

- (void)msgAsynCallReceiveGroupChatMsgs:(NSArray<CPMessage *> *)groups;
- (void)msgAsynCallCurrentRoomInfoChange;
- (void)msgAsynCallonUnreadRsp:(NSArray<CPUnreadResponse *> *)response;

- (void)msgAsynCallonReceiveNotify:(CPGroupNotify *)notice;
- (void)msgAsynCallonSessionsChange:(id)approved;

- (void)onLogonNotify:(NCProtoNetMsg *)notify;


- (void)onRecallSuccessNotify:(NCProtoNetMsg *)successNotify;
- (void)onRecallFailedNotify:(NCProtoNetMsg *)failNotify;


- (void)asynDoTask:(dispatch_block_t)task;    
- (void)asynReadTask:(dispatch_block_t)task;  
- (void)asynWriteTask:(dispatch_block_t)task; 


@property (nonatomic, strong) CPImageCaches *imageCaches;
@property (nonatomic, strong) CPOfflineMsgManager *cacheMsgManager;
@property (nonatomic, strong) ChatMessageHandleRecieve *msgRecieve;
@property (nonatomic, strong) GroupChatMessageHandleRecieve *groupMsgRecieve;

@property (nonatomic, strong) LittleArrayStorage<CPContact *> *groupContactCache;


@end


NS_ASSUME_NONNULL_END

#import "CPOfflineMsgManager.h"

