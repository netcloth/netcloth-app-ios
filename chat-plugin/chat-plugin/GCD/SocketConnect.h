//
//  SocketConnect.h
//  chat-plugin
//
//  Created by Grand on 2019/10/14.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketConnectDelegate;

@class NCProtoNetMsg;

NS_ASSUME_NONNULL_BEGIN


/// It can resend by one socket
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
