//
//  ConnectManager.m
//  chat-plugin
//
//  Created by Grand on 2019/10/14.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import "ConnectManager.h"
#import "SocketConnect.h"
#import "MessageObjects.h"
#import "CPInnerState.h"
#import "CPChatLog.h"

@interface ConnectManager () <SocketConnectDelegate>
{
    BOOL _initiativeDisconnect;
    int _reconnectCount;
    
    NSString *_host;
    uint16_t _port;
}

@property (nonatomic, strong) SocketConnect *connect;
@property (nonatomic, weak) id<ConnectManagerDelegate> delegate;
@property (nonatomic, strong) NSTimer *heartTimer;

@end

static ConnectManager *_instance;
@implementation ConnectManager

- (void)dealloc
{
    NSLog(@"dealloc -- %@", self.class);
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized (self) {
            _instance = [[ConnectManager alloc] _init];
        }
    });
    return _instance;
}

- (instancetype)init
{
    NSAssert(NO, @"use shared");
    return nil;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
    }
    return self;
}

//MARK:- Connect

- (void)connectHost:(NSString *)host
               port:(uint16_t)port
           delegate:(id<ConnectManagerDelegate>)delegate {
    
    _host = host;
    _port = port;
    
    _initiativeDisconnect = false;
    _reconnectCount = 0;
    self.isConnected = false;
    self.delegate = delegate;
    
    self.connect = [[SocketConnect alloc] initWithHost:host port:port delegate:self];
    [self.connect connect];
    [self stopHeartTimer];
}

//initiative disconnect
- (void)disconnect {
    LogFormat(@"connect-disconnect");
    [self disconnectDeleteStore:false];
}

- (void)disconnectDeleteStore:(BOOL)del {
    _initiativeDisconnect = true;
    self.isConnected = false;
    
    self.connect.delegate = nil;
    [self.connect disconnect];
    [self stopHeartTimer];
    self.connect = nil;
    
    if (del == true) {
        self->_host = nil;
        self->_port = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(onConnectError)]) {
        [self.delegate onConnectError];
    }
}


- (void)reconnect {
    _initiativeDisconnect = false;
    if ([self checkCanReConnect] == false) {
        NSLog(@"coremsg-cannot reconnect");
        return;
    }
    
    if ([NSString cp_isEmpty:self->_host]) {
        return;
    }
    NSLog(@"coremsg-connect-reinit-force");
    
    [self connectHost:self->_host port:self->_port delegate:self.delegate];
    [self stopHeartTimer];
}

- (void)_reconnect {
    //for timer
    double diff = MIN(pow(2, _reconnectCount) * 0.5, 5);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(diff * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Note: if it is connected, then recieve error triger reconnect
        if ([self checkCanReConnect]) {
            if (self->_reconnectCount >= 3) {
                NSLog(@"coremsg-connect-reinit");
                [self disconnect];
                self.connect = nil;
                if ([self.delegate respondsToSelector:@selector(onShouldReinitConnectToUseNewHostAndPort)]) {
                    [self.delegate onShouldReinitConnectToUseNewHostAndPort];
                }
//                [self connectHost:self->_host port:self->_port delegate:self.delegate];
            } else {
                [self.connect connect];
            }
        }
    });
    _reconnectCount ++;
    [self stopHeartTimer];
}

//MARK:- Public
//Note: not data, because of easy debug
- (void)sendMsg:(NCProtoNetMsg *)message {
    [self.connect sendMsg:message];
}

//MARK:- Tool

- (BOOL)checkCanReConnect {
    if (self.isConnected || self->_initiativeDisconnect || [NSString cp_isEmpty:self->_host]) {
        return NO;
    }
    return YES;
}

//MARK:- Timer
- (void)startHeartTimer {
    [self stopHeartTimer];
    self.heartTimer = [NSTimer timerWithTimeInterval:kSendHeartInterval target:self selector:@selector(sendHeartMsg) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:self.heartTimer forMode:NSRunLoopCommonModes];
}

- (void)stopHeartTimer {
    [self.heartTimer invalidate];
    self.heartTimer = nil;
}

- (void)sendHeartMsg {
    if ([self checkCanReConnect] == false) {
        NCProtoNetMsg *heart = CreateHeartbeat();
        [self.connect sendMsg:heart];
    }
}

//MARK:- SocketConnect Delegate
- (void)onSocketError {
    self.isConnected = false;
    [self stopHeartTimer];
    
    if ([self.delegate respondsToSelector:@selector(onConnectError)]) {
        [self.delegate onConnectError];
    }
    
    if ([self checkCanReConnect]) {
        [self _reconnect];
    } else {
         NSLog(@"coremsg-cannot reconnect onSocketError");
    }
}

- (void)onSocketConnectSuccess {
    self.isConnected = true;
    if ([self.delegate respondsToSelector:@selector(onConnectSuccess)]) {
        [self.delegate onConnectSuccess];
    }
}

- (void)onSocketReadPack:(NCProtoNetMsg *)netmsg {
    //filer
    if ([netmsg.name isEqualToString:kMsg_Heartbeat]) {
        return;
    }
    
    //dispath msgs
    if ([self.delegate respondsToSelector:@selector(onConnectReadPack:)]) {
        [self.delegate onConnectReadPack:netmsg];
    }
    
    //register
    if ([netmsg.name isEqualToString:kMsg_RegisterRsp]) {
        NCProtoRegisterRsp *rsp = [NCProtoRegisterRsp parseFromData:netmsg.data_p error:nil];
        if (!rsp) {
            return;
        }
        if (rsp.result != 0) {
            //error
        } else {
            self->_reconnectCount = 0;
            [self startHeartTimer];
        }
    }
}


@end
