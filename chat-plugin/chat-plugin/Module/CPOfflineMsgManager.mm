







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
#import "CPHttpReqHelper.h"

static int page_size = 30;

NSString *kStart_sys_time = @"s_sys_time";
NSString *kStart_sys_hash = @"s_sys_hash";
NSString *kStart_query_time = @"qury_sys_s";

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
    [self getUnreadGroupCount]; 
    [self getRecallHistory];  
}

- (void)_startFetchCacheMsg {
    [self startFetchCacheMsg];
}

- (void)getUnreadGroupCount {
    [CPGroupChatHelper sendGroupGetUnreadReq];
}

- (void)getRecallHistory {
    
    int64_t start = [[UserSettings objectForKey:kStart_query_time] longLongValue];
    int64_t end = [NSDate.date timeIntervalSince1970] * 1000;
    
    NSArray<CPContact *> *array = [CPInnerState.shared.loginUserDataBase
                                   getObjectsOfClass:CPContact.class
                                   fromTable:kTableName_Contact
                                   where:CPContact.sessionType == SessionTypeGroup && CPContact.groupProgress >= GroupCreateProgressDissolve];
    
    NSMutableArray *rav = NSMutableArray.array;
    for (CPContact *contact in array) {
        if ([NSString cp_isEmpty:contact.publicKey] == false) {
            [rav addObject:contact.publicKey];
        }
    }
    
    [CPHttpReqHelper requestQueryRecallMsg:start
                                   endtime:end
                           hexgrouppubkeys:rav
                                  callback:^(BOOL success, NSString * _Nonnull msg, NCProtoQueryRecallMsgRsp * _Nullable httpRsp) {
        NSLog(@"qurey recall rsp %@", httpRsp.recallMsgsArray);
        if (success) {
            
            [CPInnerState.shared.msgRecieve deleteQueryRecallMsgArray:httpRsp.recallMsgsArray
                                                                endTime:end];
        }
    }];
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
    if (time < 1000) {
        return;
    }
    long long hash = (long long)msg.signHash;
    if (_sysOk) {
        
        [UserSettings setObject:@(time) forKey:kStart_sys_time];
        [UserSettings setObject:@(hash) forKey:kStart_sys_hash];
    }
}
- (void)handleCacheMsg:(CPMessage *)msg
{
    double time = msg.createTime;
    if (time < 1000) {
        return;
    }
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
    [UserSettings deleteKey:kStart_query_time ofUser:uid];
}

@end
