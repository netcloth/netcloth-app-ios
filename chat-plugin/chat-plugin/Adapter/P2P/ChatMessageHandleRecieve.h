







#import <Foundation/Foundation.h>
#import <CPMessageRecieveHandleProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@class NCProtoNetMsg, NCProtoRecallMsg;

@interface ChatMessageHandleRecieve : NSObject <CPMessageRecieveHandleProtocol>

- (void)resendLatest_180s_unsendMsg;
- (void)clientReplay:(NCProtoNetMsg *)packin;

- (BOOL)storeMessge:(id)message isCacheMsg:(BOOL)isCache;

- (void)deleteQueryRecallMsgArray:(NSArray<NCProtoRecallMsg *> *)rm
                          endTime:(int64_t)time ;

@end

NS_ASSUME_NONNULL_END
