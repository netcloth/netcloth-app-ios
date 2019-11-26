







#import "CPOfflineMsgManager.h"
#import "CPDataModel+secpri.h"
#import "key_tool.h"
#import "string_tools.h"
#import "CPInnerState.h"

#import "NSDate+YYAdd.h"
#import "NSString+YYAdd.h"
#import "CPBridge.h"
#import "UserSettings.h"
#import "ConnectManager.h"
#import "MessageObjects.h"

static int page_size = 30;

NSString *kStart_sys_time = @"s_sys_time";
NSString *kStart_sys_hash = @"s_sys_hash";


@interface CPOfflineMsgManager () {
    BOOL _sysOk;
}
@end

@implementation CPOfflineMsgManager

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)onResignActive {
    BOOL logined = CPInnerState.shared.loginUser != nil;
    if (!logined) {
        return;
    }
    _sysOk = false;
    [ConnectManager.shared disconnect];
}

- (void)onActive {
    BOOL logined = CPInnerState.shared.loginUser != nil;
    if (!logined) {
        return;
    }

    [ConnectManager.shared reconnect];
}

- (void)_bridgeOnLogin {
    [self startFetchCacheMsg];
}

- (void)_startFetchCacheMsg {
    [self startFetchCacheMsg];
}


- (void)startFetchCacheMsg
{



    
    [CPInnerState.shared asynWriteTask:^{
        self.fetchId++;
        

        double startTime = [[UserSettings objectForKey:kStart_sys_time] doubleValue];
        long long startHash = [[UserSettings objectForKey:kStart_sys_hash] longLongValue];
        
        uint64_t time = startTime > UINT32_MAX ? startTime : startTime * 1000;
        unsigned long long hash  = startHash;
        
        User *loginUser = CPInnerState.shared.loginUser;
        std::string prikey = getDecodePrivateKeyForUser(loginUser, loginUser.password);

        
        NCProtoNetMsg *send_msg = CreateRequestCacheMsg(prikey, self.fetchId, time, hash, page_size);
        
        [CPInnerState.shared _pbmsgSend:send_msg];
    }];
}

- (void)handleOnlineMsg:(CPMessage *)msg
{
    double time = msg.createTime;
    long long hash = (long long)msg.signHash;
    if (_sysOk) {

        [UserSettings setObject:@(time) forKey:kStart_sys_time];
        [UserSettings setObject:@(hash) forKey:kStart_sys_hash];
    }
}
- (void)handleCacheMsg:(CPMessage *)msg
{
    double time = msg.createTime;
    long long hash = (long long)msg.signHash;
    [UserSettings setObject:@(time) forKey:kStart_sys_time];
    [UserSettings setObject:@(hash) forKey:kStart_sys_hash];
}

- (void)setSysMark:(BOOL)sysOk
{
    _sysOk = sysOk;
}

+ (void)deleteOffKeyOfUser:(NSInteger)uid
{
    [UserSettings deleteKey:kStart_sys_time ofUser:uid];
    [UserSettings deleteKey:kStart_sys_hash ofUser:uid];
}

@end
