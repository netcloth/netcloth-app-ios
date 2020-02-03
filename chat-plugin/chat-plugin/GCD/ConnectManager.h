  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class NCProtoNetMsg;

@protocol ConnectManagerDelegate;

#define SharedConnect ([ConnectManager shared])

  
@interface ConnectManager : NSObject

+ (instancetype)shared;

@property (atomic, assign) BOOL isConnected;

- (void)connectHost:(NSString *)host
               port:(uint16_t)port
           delegate:(id<ConnectManagerDelegate>)delegate;

  
- (void)sendMsg:(NCProtoNetMsg *)message;

  
- (void)disconnect;

- (void)disconnectDeleteStore:(BOOL)del;


- (void)reconnect;

@end

NS_ASSUME_NONNULL_END


@protocol ConnectManagerDelegate <NSObject>

- (void)onConnectError;
- (void)onConnectSuccess;
- (void)onConnectReadPack:(NCProtoNetMsg * _Nullable)netmsg;

  
- (void)onShouldReinitConnectToUseNewHostAndPort;

@end
