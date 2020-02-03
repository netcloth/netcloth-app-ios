  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPSessionHelper.h"
#import "CPGroupChatHelper.h"

@protocol ChatDelegate <NSObject>

@optional
- (void)onReceiveMsg:(CPMessage *_Nonnull)msg;

  
- (void)onCacheMsgRecieve:(NSArray<CPMessage *> *)caches;

  
- (void)onMsgSendStateChange:(CPMessage *_Nonnull)msg;

  
- (void)onReceiveGroupChatMsgs:(NSArray<CPMessage *> * _Nonnull)msgs;

  
  
- (void)onCurrentRoomInfoChange;

  
- (void)onUnreadRsp:(NSArray<CPUnreadResponse *> *)response;

  
- (void)onReceiveNotify:(CPGroupNotify * _Nullable)notice;

  
- (void)onSessionNeedChange:(id)change;

  
- (void)onLogonNotify:(NCProtoNetMsg *)notify;


@end

@protocol ChatRoomInterface;

NS_ASSUME_NONNULL_BEGIN

  
@interface CPChatHelper : NSObject <ChatRoomInterface>

+ (void)addInterface:(id<ChatDelegate>)delegate;
+ (void)removeInterface:(id<ChatDelegate>)delegate;

  
  
+ (void)setRoomToPubkey:(NSString * _Nullable)topubkey;

  
+ (void)sendText:(NSString *)msg
          toUser:(NSString *)pubkey;

+ (void)sendAudioData:(NSData *)data
          toUser:(NSString *)pubkey;

  
+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;


  
+ (void)fakeSendMsg:(CPMessage *)msg complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;


  
+ (void)sendDeleteMsgAction:(NCProtoDeleteAction)action
                       hash:(int64_t)hash
            relateHexPubkey:(NSString * _Nullable)hexPubkey
                   complete:(MsgResponseBack)back;


@end


NS_ASSUME_NONNULL_END


@protocol ChatRoomInterface <NSObject>

  
+ (void)getMessagesInSession:(NSInteger)sessionId
                  createTime:(double)createTime   
                   fromMsgId:(long long)msgId   
                        size:(NSInteger)size   
                    complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete;

  
+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete;

  
+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete;


  
+ (void)retrySendMsg:(long long)msgId;


@end
