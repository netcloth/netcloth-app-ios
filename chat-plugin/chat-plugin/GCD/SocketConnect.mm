







#import "SocketConnect.h"
#import "GCDAsyncSocket.h"
#import "CPInnerState.h"
#import "MessageObjects.h"
#import "CPChatLog.h"
#import <YYKit/YYKit.h>

#define kTagHeartBeat  1001
#define kTagRegisterReq  1002

const NSInteger OnePackMaxLen = 1024 * 1024 *100; 

@interface SocketConnect () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_socket;
    NSString *_host;
    uint16_t _port;
    int8_t _timeout; 
    
    dispatch_queue_t  _serialWriteQueue;
    dispatch_queue_t  _serialReadQueue;
}

@property (atomic, strong) NSMutableData *pbBuffer;
@property (nonatomic, strong) NSTimer *timeoutTimer;

@end

@implementation SocketConnect

- (void)dealloc
{
    NSLog(@"dealloc -- %@", self.class);
}

- (instancetype)init
{
    NSAssert(false, @"please use initWithHost: port:");
    return nil;
}

- (instancetype)_init
{
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _timeout = kHeartTimeoutInterval / 2.0;
    _serialWriteQueue = dispatch_queue_create("netcloth.SocketConnect.Wq", DISPATCH_QUEUE_SERIAL);
    _serialReadQueue = dispatch_queue_create("netcloth.SocketConnect.Rq", DISPATCH_QUEUE_SERIAL);
    _pbBuffer = NSMutableData.data;
}

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port delegate:(nonnull id<SocketConnectDelegate>)delegate
{
    self = [self _init];
    if (self) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _socket.IPv4PreferredOverIPv6 = false;
        _host = host;
        _port = port;
        self.delegate = delegate;
    }
    return self;
}


-(void)connect
{
    [self stoptimeoutTimer];
    dispatch_barrier_async(_serialReadQueue, ^{
        [self->_socket synchronouslySetDelegate:self];
        [self->_socket synchronouslySetDelegateQueue:dispatch_get_main_queue()];
        self->_pbBuffer = NSMutableData.data;
        
        NSError *err;
        [self->_socket connectToHost:self->_host onPort:self->_port withTimeout:self->_timeout error:&err];
        NSLog(@"coremsg-connect-start");
        LogFormat(@"connect-start");
        dispatch_main_async_safe(^{
            if (err && [self.delegate respondsToSelector:@selector(onSocketError)]) {
                NSLog(@"coremsg-connect-start-error %@",err);
                LogFormat(@"connect-error");
                [self.delegate onSocketError];
            }
        })
        [self starttimeoutTimer];
    });
}

- (void)disconnect
{
    [self stoptimeoutTimer];
    
    dispatch_barrier_async(_serialReadQueue, ^{
        [self->_socket synchronouslySetDelegate:nil];
        [self->_socket synchronouslySetDelegateQueue:nil];
        [self->_socket disconnect]; 
        self->_pbBuffer = NSMutableData.data;
    });
}



- (void)sendMsg:(NCProtoNetMsg *)message {
    dispatch_async(_serialWriteQueue, ^{

        NSAssert(!(message.name == nil || [message.name isEqualToString:@""] || message.name == NULL), @"message name must set");
        NSData *data = [MessageObjects encodeNetMsg:message];
        if ([message.name isEqualToString:kMsg_Heartbeat]) {
            [self sendMsgData:data withTag:kTagHeartBeat];
        }
        else if ([message.name isEqualToString:NCProtoRegisterReq.descriptor.fullName]) {
            [self sendMsgData:data withTag:kTagRegisterReq];
        }
        else {
            [self sendMsgData:data];
        }
        [CPChatLog recordSendMsg:message];
    });
}
- (void)sendMsgData:(NSData *)data {
    [self sendMsgData:data withTag:0];
}

- (void)sendMsgData:(NSData *)data withTag:(long)tag {
    [self->_socket writeData:data withTimeout:-1 tag:tag];
    [self->_socket readDataWithTimeout:-1 tag:0];
}



- (void)starttimeoutTimer {
    [self stoptimeoutTimer];
    self.timeoutTimer = [NSTimer timerWithTimeInterval:kHeartTimeoutInterval target:self selector:@selector(onTimeout) userInfo:nil repeats:NO];
    [NSRunLoop.mainRunLoop addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
}

- (void)stoptimeoutTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)onTimeout {
    [self stoptimeoutTimer];
    [self disconnect];
    dispatch_main_async_safe(^{
        if ([self.delegate respondsToSelector:@selector(onSocketError)]) {
            [self.delegate onSocketError];
        }
    });
    NSLog(@"coremsg-connect-onTimeout");
    LogFormat(@"connect-timeout");
}



- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"coremsg-didConnectToHost %@",host);
    LogFormat(@"connect-didConnectToHost %@  %hu", host, port);
    [self->_socket readDataWithTimeout:-1 tag:0];
    dispatch_main_async_safe(^{
        if ([self.delegate respondsToSelector:@selector(onSocketConnectSuccess)]) {
            [self.delegate onSocketConnectSuccess];
        }
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"coremsg-socketDidDisconnect %@",err.debugDescription);
    LogFormat(@"connect-socketDidDisconnect %@",err.debugDescription);
    dispatch_main_async_safe(^{
        if ([self.delegate respondsToSelector:@selector(onSocketError)]) {
            [self.delegate onSocketError];
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self starttimeoutTimer];
    @weakify(self);
    dispatch_async(_serialReadQueue, ^{
        @strongify(self);
        [self.pbBuffer appendData:data];
        
        int8_t count = 0;
        while (1) {
            if (count > 5) {
                NSLog(@"coremsg-loop-max");
                return; 
            }
            int bufferLen = self.pbBuffer.length;
            if (bufferLen < kHeaderLen) {

                return;
            }
            NSData *header = [self.pbBuffer subdataWithRange:NSMakeRange(0, kHeaderLen)];
            __uint32_t nl_headlen = *((__uint32_t *)header.bytes);
            int32_t host_headlen = ntohl(nl_headlen);
            if (host_headlen < kLeastSize || host_headlen >= OnePackMaxLen) {
                
                NSLog(@"socket len err");
                LogFormat(@"socket len err");
                [self disconnect];
                dispatch_main_async_safe(^{
                    if ([self.delegate respondsToSelector:@selector(onSocketError)]) {
                        [self.delegate onSocketError];
                    }
                });
                return;
            }
            
            int total = host_headlen + kHeaderLen;
            bufferLen = self.pbBuffer.length;
            if (bufferLen < total) {

                return;
            }
            NSRange packRange = NSMakeRange(0, total);
            NSData *packBytes = [self.pbBuffer subdataWithRange:packRange];
            
            bufferLen = self.pbBuffer.length;
            if (bufferLen < total) {

                return;
            }
            [self.pbBuffer replaceBytesInRange:packRange withBytes:NULL length:0];
            
            NCProtoNetMsg *netmsg = [MessageObjects decodePackFrom:packBytes];
            
            if (netmsg) {
                dispatch_main_async_safe(^{
                    if ([self.delegate respondsToSelector:@selector(onSocketReadPack:)]) {
                        [self.delegate onSocketReadPack:netmsg];
                    }
                });

                [CPChatLog recordRecieveMsg:netmsg];
            }
            else {
                NSLog(@"coremsg-pb-parse-fail-name: %@",netmsg.name);
                LogFormat(@"Msg:ParseErr");
            }
            count ++;
        }
    });
    [self->_socket readDataWithTimeout:-1 tag:0];

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    if (tag == kTagHeartBeat) {
        LogFormat(@"send: write heart");
    }
    else if (tag ==  kTagRegisterReq) {
        LogFormat(@"send: write TagRegst");
    }
    
    [self->_socket readDataWithTimeout:-1 tag:0];
}

@end
