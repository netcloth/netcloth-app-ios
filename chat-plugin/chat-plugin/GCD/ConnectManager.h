//
//  ConnectManager.h
//  chat-plugin
//
//  Created by Grand on 2019/10/14.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class NCProtoNetMsg;

@protocol ConnectManagerDelegate;

#define SharedConnect ([ConnectManager shared])

/// heart 、 autoconnect
@interface ConnectManager : NSObject

+ (instancetype)shared;

@property (atomic, assign) BOOL isConnected;

- (void)connectHost:(NSString *)host
               port:(uint16_t)port
           delegate:(id<ConnectManagerDelegate>)delegate;

//Note: not data, because of easy debug
- (void)sendMsg:(NCProtoNetMsg *)message;

//initiative disconnect
- (void)disconnect;

- (void)disconnectDeleteStore:(BOOL)del;


- (void)reconnect;

@end

NS_ASSUME_NONNULL_END


@protocol ConnectManagerDelegate <NSObject>

- (void)onConnectError;
- (void)onConnectSuccess;
- (void)onConnectReadPack:(NCProtoNetMsg * _Nullable)netmsg;

//if reconnect than 3 times, it will be reinit connect
- (void)onShouldReinitConnectToUseNewHostAndPort;

@end
