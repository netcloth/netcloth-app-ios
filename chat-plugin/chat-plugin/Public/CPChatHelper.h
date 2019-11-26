







#import <Foundation/Foundation.h>
#import "CPDataModel.h"

@protocol ChatInterface <NSObject>

@optional
- (void)onReceiveMsg:(CPMessage *_Nonnull)msg;
- (void)onCacheMsgRecieve:(NSArray<CPMessage *> *)caches;

- (void)onMsgSendStateChange:(CPMessage *_Nonnull)msg;

@end


@protocol ChatDBInterface <NSObject>

+ (void)getAllRecentSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete;



+ (void)getMessagesInSession:(NSInteger)sessionId
                  createTime:(double)createTime
                   fromMsgId:(long long)msgId
                        size:(NSInteger)size
                    complete:(void (^)(BOOL success, NSString *msg, NSArray<CPMessage *> * _Nullable recentSessions))complete;


+ (void)setAllReadOfSession:(NSInteger)sessionId
                   complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)setReadOfMessage:(long long)msgId
                complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)deleteSession:(NSInteger)sessionId
             complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)deleteMessage:(long long)msgId
             complete:(void (^)(BOOL success, NSString *msg))complete;



+ (void)markTopOfSession:(NSInteger)sessionId
                complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)unTopOfSession:(NSInteger)sessionId
              complete:(void (^)(BOOL success, NSString *msg))complete;


+ (void)retrySendMsg:(long long)msgId;


@end


NS_ASSUME_NONNULL_BEGIN


@interface CPChatHelper : NSObject <ChatDBInterface>

+ (void)addInterface:(id<ChatInterface>)delegate;
+ (void)removeInterface:(id<ChatInterface>)delegate;


+ (void)sendText:(NSString *)msg
          toUser:(NSString *)pubkey;

+ (void)sendAudioData:(NSData *)data
          toUser:(NSString *)pubkey;


+ (void)sendImageData:(NSData *)data
               toUser:(NSString *)pubkey;



+ (void)setRoomToPubkey:(NSString * _Nullable)topubkey;

@end


NS_ASSUME_NONNULL_END
