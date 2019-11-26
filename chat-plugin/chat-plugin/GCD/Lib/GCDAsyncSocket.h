









#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <Security/SecureTransport.h>
#import <dispatch/dispatch.h>
#import <Availability.h>

#include <sys/socket.h>

@class GCDAsyncReadPacket;
@class GCDAsyncWritePacket;
@class GCDAsyncSocketPreBuffer;
@protocol GCDAsyncSocketDelegate;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GCDAsyncSocketException;
extern NSString *const GCDAsyncSocketErrorDomain;

extern NSString *const GCDAsyncSocketQueueName;
extern NSString *const GCDAsyncSocketThreadName;

extern NSString *const GCDAsyncSocketManuallyEvaluateTrust;
#if TARGET_OS_IPHONE
extern NSString *const GCDAsyncSocketUseCFStreamForTLS;
#endif
#define GCDAsyncSocketSSLPeerName     (NSString *)kCFStreamSSLPeerName
#define GCDAsyncSocketSSLCertificates (NSString *)kCFStreamSSLCertificates
#define GCDAsyncSocketSSLIsServer     (NSString *)kCFStreamSSLIsServer
extern NSString *const GCDAsyncSocketSSLPeerID;
extern NSString *const GCDAsyncSocketSSLProtocolVersionMin;
extern NSString *const GCDAsyncSocketSSLProtocolVersionMax;
extern NSString *const GCDAsyncSocketSSLSessionOptionFalseStart;
extern NSString *const GCDAsyncSocketSSLSessionOptionSendOneByteRecord;
extern NSString *const GCDAsyncSocketSSLCipherSuites;
#if !TARGET_OS_IPHONE
extern NSString *const GCDAsyncSocketSSLDiffieHellmanParameters;
#endif

#define GCDAsyncSocketLoggingContext 65535


typedef NS_ERROR_ENUM(GCDAsyncSocketErrorDomain, GCDAsyncSocketError) {
	GCDAsyncSocketNoError = 0,          
	GCDAsyncSocketBadConfigError,       
	GCDAsyncSocketBadParamError,        
	GCDAsyncSocketConnectTimeoutError,  
	GCDAsyncSocketReadTimeoutError,     
	GCDAsyncSocketWriteTimeoutError,    
	GCDAsyncSocketReadMaxedOutError,    
	GCDAsyncSocketClosedError,          
	GCDAsyncSocketOtherError,           
};





@interface GCDAsyncSocket : NSObject

- (instancetype)init;
- (instancetype)initWithSocketQueue:(nullable dispatch_queue_t)sq;
- (instancetype)initWithDelegate:(nullable id<GCDAsyncSocketDelegate>)aDelegate delegateQueue:(nullable dispatch_queue_t)dq;
- (instancetype)initWithDelegate:(nullable id<GCDAsyncSocketDelegate>)aDelegate delegateQueue:(nullable dispatch_queue_t)dq socketQueue:(nullable dispatch_queue_t)sq;

+ (nullable instancetype)socketFromConnectedSocketFD:(int)socketFD socketQueue:(nullable dispatch_queue_t)sq error:(NSError**)error;

+ (nullable instancetype)socketFromConnectedSocketFD:(int)socketFD delegate:(nullable id<GCDAsyncSocketDelegate>)aDelegate delegateQueue:(nullable dispatch_queue_t)dq error:(NSError**)error;

+ (nullable instancetype)socketFromConnectedSocketFD:(int)socketFD delegate:(nullable id<GCDAsyncSocketDelegate>)aDelegate delegateQueue:(nullable dispatch_queue_t)dq socketQueue:(nullable dispatch_queue_t)sq error:(NSError **)error;


@property (atomic, weak, readwrite, nullable) id<GCDAsyncSocketDelegate> delegate;
#if OS_OBJECT_USE_OBJC
@property (atomic, strong, readwrite, nullable) dispatch_queue_t delegateQueue;
#else
@property (atomic, assign, readwrite, nullable) dispatch_queue_t delegateQueue;
#endif

- (void)getDelegate:(id<GCDAsyncSocketDelegate> __nullable * __nullable)delegatePtr delegateQueue:(dispatch_queue_t __nullable * __nullable)delegateQueuePtr;
- (void)setDelegate:(nullable id<GCDAsyncSocketDelegate>)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;

- (void)synchronouslySetDelegate:(nullable id<GCDAsyncSocketDelegate>)delegate;
- (void)synchronouslySetDelegateQueue:(nullable dispatch_queue_t)delegateQueue;
- (void)synchronouslySetDelegate:(nullable id<GCDAsyncSocketDelegate>)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;


@property (atomic, assign, readwrite, getter=isIPv4Enabled) BOOL IPv4Enabled;
@property (atomic, assign, readwrite, getter=isIPv6Enabled) BOOL IPv6Enabled;

@property (atomic, assign, readwrite, getter=isIPv4PreferredOverIPv6) BOOL IPv4PreferredOverIPv6;

@property (atomic, assign, readwrite) NSTimeInterval alternateAddressDelay;

@property (atomic, strong, readwrite, nullable) id userData;


- (BOOL)acceptOnPort:(uint16_t)port error:(NSError **)errPtr;

- (BOOL)acceptOnInterface:(nullable NSString *)interface port:(uint16_t)port error:(NSError **)errPtr;

- (BOOL)acceptOnUrl:(NSURL *)url error:(NSError **)errPtr;


- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr;

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr;

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
         viaInterface:(nullable NSString *)interface
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr;

- (BOOL)connectToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;

- (BOOL)connectToAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

- (BOOL)connectToAddress:(NSData *)remoteAddr
            viaInterface:(nullable NSString *)interface
             withTimeout:(NSTimeInterval)timeout
                   error:(NSError **)errPtr;
- (BOOL)connectToUrl:(NSURL *)url withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

- (BOOL)connectToNetService:(NSNetService *)netService error:(NSError **)errPtr;


- (void)disconnect;

- (void)disconnectAfterReading;

- (void)disconnectAfterWriting;

- (void)disconnectAfterReadingAndWriting;


@property (atomic, readonly) BOOL isDisconnected;
@property (atomic, readonly) BOOL isConnected;

@property (atomic, readonly, nullable) NSString *connectedHost;
@property (atomic, readonly) uint16_t  connectedPort;
@property (atomic, readonly, nullable) NSURL    *connectedUrl;

@property (atomic, readonly, nullable) NSString *localHost;
@property (atomic, readonly) uint16_t  localPort;

@property (atomic, readonly, nullable) NSData *connectedAddress;
@property (atomic, readonly, nullable) NSData *localAddress;

@property (atomic, readonly) BOOL isIPv4;
@property (atomic, readonly) BOOL isIPv6;

@property (atomic, readonly) BOOL isSecure;















- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataWithTimeout:(NSTimeInterval)timeout
					 buffer:(nullable NSMutableData *)buffer
			   bufferOffset:(NSUInteger)offset
						tag:(long)tag;

- (void)readDataWithTimeout:(NSTimeInterval)timeout
                     buffer:(nullable NSMutableData *)buffer
               bufferOffset:(NSUInteger)offset
                  maxLength:(NSUInteger)length
                        tag:(long)tag;

- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToLength:(NSUInteger)length
             withTimeout:(NSTimeInterval)timeout
                  buffer:(nullable NSMutableData *)buffer
            bufferOffset:(NSUInteger)offset
                     tag:(long)tag;

- (void)readDataToData:(nullable NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(nullable NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
                   tag:(long)tag;

- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout maxLength:(NSUInteger)length tag:(long)tag;

- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(nullable NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
             maxLength:(NSUInteger)length
                   tag:(long)tag;

- (float)progressOfReadReturningTag:(nullable long *)tagPtr bytesDone:(nullable NSUInteger *)donePtr total:(nullable NSUInteger *)totalPtr;


- (void)writeData:(nullable NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (float)progressOfWriteReturningTag:(nullable long *)tagPtr bytesDone:(nullable NSUInteger *)donePtr total:(nullable NSUInteger *)totalPtr;


- (void)startTLS:(nullable NSDictionary <NSString*,NSObject*>*)tlsSettings;


@property (atomic, assign, readwrite) BOOL autoDisconnectOnClosedReadStream;

- (void)markSocketQueueTargetQueue:(dispatch_queue_t)socketQueuesPreConfiguredTargetQueue;
- (void)unmarkSocketQueueTargetQueue:(dispatch_queue_t)socketQueuesPreviouslyConfiguredTargetQueue;

- (void)performBlock:(dispatch_block_t)block;

- (int)socketFD;
- (int)socket4FD;
- (int)socket6FD;

#if TARGET_OS_IPHONE

- (nullable CFReadStreamRef)readStream;
- (nullable CFWriteStreamRef)writeStream;

- (BOOL)enableBackgroundingOnSocket;

#endif

- (nullable SSLContextRef)sslContext;


+ (nullable NSMutableArray *)lookupHost:(NSString *)host port:(uint16_t)port error:(NSError **)errPtr;


+ (nullable NSString *)hostFromAddress:(NSData *)address;
+ (uint16_t)portFromAddress:(NSData *)address;

+ (BOOL)isIPv4Address:(NSData *)address;
+ (BOOL)isIPv6Address:(NSData *)address;

+ (BOOL)getHost:( NSString * __nullable * __nullable)hostPtr port:(nullable uint16_t *)portPtr fromAddress:(NSData *)address;

+ (BOOL)getHost:(NSString * __nullable * __nullable)hostPtr port:(nullable uint16_t *)portPtr family:(nullable sa_family_t *)afPtr fromAddress:(NSData *)address;

+ (NSData *)CRLFData;  
+ (NSData *)CRData;    
+ (NSData *)LFData;    
+ (NSData *)ZeroData;  

@end




@protocol GCDAsyncSocketDelegate <NSObject>
@optional

- (nullable dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock;

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url;

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                                                                 elapsed:(NSTimeInterval)elapsed
                                                               bytesDone:(NSUInteger)length;

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                                                                  elapsed:(NSTimeInterval)elapsed
                                                                bytesDone:(NSUInteger)length;

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock;

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err;

- (void)socketDidSecure:(GCDAsyncSocket *)sock;

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
                                    completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;

@end
NS_ASSUME_NONNULL_END
