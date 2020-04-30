







#import <Foundation/Foundation.h>
#import "Chat.pbobjc.h"
#import "NetMsg.pbobjc.h"
#import "Contacts.pbobjc.h"
#import "GroupMsg.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TradeRspType) {
    TradeRspTypeTransfer = 1, 
};

typedef NS_ENUM(NSInteger, TradeRspStatus) {
    TradeRspStatusWait = 1, 
    TradeRspStatusQuery = 2, 
    TradeRspStatusFail = 9,
    TradeRspStatusSuccess = 10,
};


@interface CPTradeRsp : NSObject

@property (nonatomic, copy) NSString *txhash;
@property (nonatomic, assign) int64_t tid;

@property (nonatomic, assign) TradeRspType type;

@property (nonatomic, assign) TradeRspStatus status;

@property (nonatomic, assign) double createTime;


@property (nonatomic, copy) NSString *amount;

@property (nonatomic, assign) int chainId;
@property (nonatomic, copy) NSString *symbol;


@property (nonatomic, copy) NSString *txfee;

@property (nonatomic, copy) NSString *fromAddr;
@property (nonatomic, copy) NSString *toAddr;


@property (nonatomic, copy) NSString *memo;

@end


@interface CPAssetToken : NSObject

@property (nonatomic, assign) int chainID;
@property (nonatomic, copy) NSString *symbol;


@property (nonatomic, copy) NSString *balance;

@end


typedef NS_ENUM(int, GroupRole) {
    GroupRoleOwner = 0,
    GroupRoleManager = 1,
    GroupRoleMember = 2
};




typedef NS_ENUM(NSInteger, DMNotifyStatus) {
    DMNotifyStatusExpired = -1, 
    DMNotifyStatusUnread = 0,
    DMNotifyStatusRead = 1,
    DMNotifyStatusReject = 2, 
    DMNotifyStatusFulfilled = 3, 
};

typedef NS_ENUM(NSInteger, DMNotifyType) {
    DMNotifyTypeApprove = 0, 
};

@interface CPGroupMember : NSObject

@property (nonatomic, assign) int sessionId; 

@property (nonatomic, copy) NSString *hexPubkey;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) GroupRole role;

@property (nonatomic, assign) int64_t join_time; 

@end


@interface CPChainClaim : NSObject

@property (nonatomic, copy) NSString *txhash; 

@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString *moniker; 
@property (nonatomic, copy) NSString *operator_address; 
@property (nonatomic, assign) int chain_status; 

@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;
@property (nonatomic, copy) NSString *endpoint; 

@end



@interface User : NSObject


@property (nonatomic, assign) int userId;
@property (nonatomic, assign) unsigned long long pubkeySignHash;
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;

@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, strong) NSDictionary *localExt; 

@end

@interface User()

@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *password;
@end

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypeP2P = 0, 
    SessionTypeGroup, 
};

typedef NS_ENUM(NSInteger, ContactStatus) {
    ContactStatusNormal = 0, 
    ContactStatusStrange = 1, 
    ContactStatusNewFriend = 2, 
    ContactStatusAssistHelper = 3, 
};

typedef NS_ENUM(NSInteger, GroupCreateProgress) {
    GroupCreateProgressUnknown = -100, 
    GroupCreateProgressSendIPAL = 1,
    GroupCreateProgressIPALOK = 2,
    GroupCreateProgressIPALFail = 3,
    GroupCreateProgressSendCreateMsg = 4,
    GroupCreateProgressCreateFail = 5,
    
    GroupCreateProgressDissolve = 20,
    GroupCreateProgressKicked = 21,
    
    GroupCreateProgressCreateOK = 66,
    GroupCreateProgressJoinedOk = 68,
    GroupCreateProgressRestoreOk = 69,
};

typedef NS_ENUM(int, CPGroupInviteType) {
    CPGroupInviteTypeAllowAll = 0, 
    CPGroupInviteTypeNeedApprove = 1, 
    CPGroupInviteTypeOnlyOwner = 2, 
};


@interface CPContact : NSObject

@property (nonatomic, copy) NSString *publicKey; 
@property (nonatomic, copy) NSString *remark; 
@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) SessionType sessionType;

@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime; 
@property (nonatomic, strong) NSDictionary *localExt;

@property (nonatomic, assign) BOOL isBlack; 
@property (nonatomic, assign) BOOL isDoNotDisturb;

@property (nonatomic, assign) ContactStatus status; 



@property (nonatomic, strong) NSData *encodePrivateKey; 

@property (nonatomic, assign) GroupCreateProgress groupProgress;
@property (nonatomic, copy) NSString *groupNodeAddress; 
@property (nonatomic, copy) NSString *txhash; 
@property (nonatomic, assign) int64_t modifiedTime; 



@property (nonatomic, copy) NSString *notice_encrypt_content;
@property (nonatomic, assign) NSTimeInterval notice_modified_time; 
@property (nonatomic, copy) NSString *notice_publisher;


@property (nonatomic, assign) int inviteType; 


@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *server_addr;



@end

@interface CPContact ()

@property (nonatomic, strong) NSArray<CPGroupMember *> *groupRelateMember;

- (NSString * _Nullable)decodeNotice;
- (void)setSourceNotice:(NSString *)notice;

- (NSData *)decodePrivateKey;
- (void)setSourcePrivateKey:(NSData *)source;

@end


typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeUnknown = -1,
    
    MessageTypeText = 1,
    MessageTypeAudio = 2,
    MessageTypeImage = 3, 
    
    
    
    MessageTypeInviteeUser = 2019777,
    
    
    MessageTypeGroupJoin = 2019778,
    MessageTypeGroupKick = 2019780,
    MessageTypeGroupQuit = 2019781,
    
    MessageTypeGroupUpdateName = 2019880,
    MessageTypeGroupUpdateNickName = 2019882, 
    
    
    MessageTypeWelcomNewFriends = 2020666,
    MessageTypeCreateGroupSuccess = 2020667,
    MessageTypeJoinGroupSuccess = 2020669,
    
    
    MessageTypeGroupUpdateNotice = 2019881, 
    MessageTypeAssistTip = 2019888, 
};


typedef NS_ENUM(NSInteger, MessageUseWay) {
    MessageUseWayDefault = 0,
    MessageUseWayAtMe = 11,  
    MessageUseWayAtAll = 12 
};


@interface CPMessage : NSObject {
@public
    NSString *_msgDecode; 
    NSData *_audioDecode; 
    NSData *_imageDecode; 
}

@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) long long msgId;

@property (nonatomic, assign) MessageType msgType;
@property (nonatomic, assign) int version;



@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;


@property (nonatomic, copy) NSString *senderPubKey;
@property (nonatomic, copy) NSString *toPubkey;






@property (nonatomic, assign) int toServerState;


@property (nonatomic, assign) unsigned long long signHash;


@property (nonatomic, strong, nullable) NSData *msgData;



@property (nonatomic, assign) BOOL read;

@property (nonatomic, assign) BOOL audioRead;
@property (nonatomic, strong) NSString *fileHash; 


@property (nonatomic, assign) NSInteger audioTimes;

@property (nonatomic, assign) NSInteger pixelWidth;
@property (nonatomic, assign) NSInteger pixelHeight;


@property (nonatomic, strong) NSData *encodePrivateKey; 
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) int64_t server_msg_id;


@property (nonatomic, assign) int isDelete;
@property (nonatomic, strong) NSData *group_pub_key; 

@property (nonatomic, assign) MessageUseWay useway; 

@end

@interface CPMessage (ext)
@property (nonatomic, assign, readonly) BOOL isGroupChat;
@end

@interface CPMessage ()

- (NSData * _Nullable)decodeGroupPrivateKey;

@property (nonatomic, assign) BOOL doNotDisturb;
@property (nonatomic, assign) BOOL showCreateTime;
@property (nonatomic, copy) NSString *senderRemark; 


- (id)msgDecodeContent;
- (id)msgDecodeContent_onlyTextType;

- (void)resetImage;


@property (nonatomic, copy, nullable) void (^uploadProgressHandle)(double progress);


@property (nonatomic, copy, nullable) void (^downloadProgressHandle)(double progress);


@property (nonatomic, copy, nullable) void (^normalCompleteHandle)(BOOL);


@property (nonatomic, assign) BOOL toUserNotFound;

@end





@interface CPSession : NSObject

@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) SessionType sessionType;
@property (nonatomic, assign) long long lastMsgId;
@property (nonatomic, strong) NSDictionary *localExt;
@property (nonatomic, assign) int topMark; 
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;


@property (nonatomic, assign) NSInteger groupUnreadCount;

@end

@interface CPSession ()

@property (nullable, nonatomic, strong)  CPMessage  *lastMsg;
@property (nonatomic, assign)  NSInteger unreadCount;
@property (nonatomic, strong) CPContact *relateContact;
@property (nonatomic, strong) NSArray<CPGroupMember *> *groupRelateMember;

@property (nullable, nonatomic, strong)  CPMessage  *atRelateMsg;

@end





@interface CPGroupNotify : NSObject
@property (nonatomic, assign) int64_t noticeId;
@property (nonatomic, assign) int sessionId; 
@property (nonatomic, assign) DMNotifyType type;
@property (nonatomic, assign) DMNotifyStatus status;


@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) uint64_t signHash;

@property (nonatomic, copy) NSString *senderPublicKey; 
@property (nonatomic, strong) NSData *approveNotify; 

@end


@interface CPGroupNotify ()

@property (nonatomic, assign) BOOL manualDecode;

@property (nonatomic, strong, nullable) NCProtoNetMsg *join_msg;
@property (nonatomic, strong, nullable) NCProtoGroupJoin *decodeJoinRequest; 
@property (nonatomic, copy, nullable) NSString *inviterNickName;  
- (NSString * _Nullable)decodeRequestReason;

 
@end


NS_ASSUME_NONNULL_END


#import "CPSimpleDataModel.h"
