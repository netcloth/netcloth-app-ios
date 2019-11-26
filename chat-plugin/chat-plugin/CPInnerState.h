







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import "CPDataModel+secpri.h"
#import <WCDB/WCDB.h>
#import "CPChatHelper.h"
#import "LittleSetStorage.h"
#import "CPImageCaches.h"
#import "CPTools.h"

NS_ASSUME_NONNULL_BEGIN

@class CPOfflineMsgManager, NCProtoNetMsg;

#define kPrivateKeySize 32
#define kPublicKeySize 65



@interface CPInnerState : NSObject

+ (instancetype)shared;
@property (atomic, strong) NSHashTable<ChatInterface> *chatDelegates;


@property (nonatomic, strong) User *loginUser;
@property (nonatomic, strong) WCTDatabase *allUsersDB;
@property (nonatomic, strong) WCTDatabase *loginUserDataBase;


@property (nonatomic, strong) NSString *chatToPubkey;



- (BOOL)connectServiceHost:(NSString *)host
                      port:(uint16_t)port;
- (void)disconnect;
- (BOOL)isConnected;
- (BOOL)isNetworkOk;


- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg;
- (void)_pbmsgSend:(NCProtoNetMsg *)netmsg autoCallNetStatus:(CPMessage *)message;
- (BOOL)storeMessge:(CPMessage *)message isCacheMsg:(BOOL)isCache;

- (void)asynCallBackMsg:(CPMessage *)msg;
- (void)asynCallStatusChange:(CPMessage *)msg;



- (void)asynDoTask:(dispatch_block_t)task;   
- (void)asynReadTask:(dispatch_block_t)task; 
- (void)asynWriteTask:(dispatch_block_t)task;


@property (nonatomic, strong) CPImageCaches *imageCaches;




- (NSString *)curEnv;


- (NSString *)switchEnv;

@end


NS_ASSUME_NONNULL_END

#import "CPOfflineMsgManager.h"

