







#import <Foundation/Foundation.h>

@protocol SocketConnectDelegate;

@class NCProtoNetMsg;

NS_ASSUME_NONNULL_BEGIN



@interface SocketConnect : NSObject

- (instancetype)initWithHost:(NSString *)host
                        port:(uint16_t)port
                    delegate:(id<SocketConnectDelegate>)delegate;
@property (nonatomic, weak) id<SocketConnectDelegate> delegate;

- (void)connect;
- (void)disconnect;

- (void)sendMsg:(NCProtoNetMsg *)message;
- (void)sendMsgData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END


@protocol SocketConnectDelegate <NSObject>

- (void)onSocketError;
- (void)onSocketConnectSuccess;
- (void)onSocketReadPack:(NCProtoNetMsg *_Nullable)netmsg;


@end
