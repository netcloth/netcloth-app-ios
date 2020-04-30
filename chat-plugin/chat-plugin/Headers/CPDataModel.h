//
//  CPDataModel.h
//  chat-plugin
//
//  Created by Grand on 2019/7/23.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chat.pbobjc.h"
#import "NetMsg.pbobjc.h"
#import "Contacts.pbobjc.h"
#import "GroupMsg.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TradeRspType) {
    TradeRspTypeTransfer = 1, //转出
};

typedef NS_ENUM(NSInteger, TradeRspStatus) {
    TradeRspStatusWait = 1, //等待打包
    TradeRspStatusQuery = 2, //确认中（查询）default
    TradeRspStatusFail = 9,
    TradeRspStatusSuccess = 10,
};

/// CPTradeRsp
@interface CPTradeRsp : NSObject

@property (nonatomic, copy) NSString *txhash;
@property (nonatomic, assign) int64_t tid;

@property (nonatomic, assign) TradeRspType type;

@property (nonatomic, assign) TradeRspStatus status;

@property (nonatomic, assign) double createTime;

///eg: pnch
@property (nonatomic, copy) NSString *amount;

@property (nonatomic, assign) int chainId;
@property (nonatomic, copy) NSString *symbol;

///eg: nch
@property (nonatomic, copy) NSString *txfee;

@property (nonatomic, copy) NSString *fromAddr;
@property (nonatomic, copy) NSString *toAddr;

/// 备注
@property (nonatomic, copy) NSString *memo;

@end


@interface CPAssetToken : NSObject

@property (nonatomic, assign) int chainID;
@property (nonatomic, copy) NSString *symbol;

/// 原生币种 最小单位, 余额
@property (nonatomic, copy) NSString *balance;

@end

//MARK:- 群
typedef NS_ENUM(int, GroupRole) {
    GroupRoleOwner = 0,
    GroupRoleManager = 1,
    GroupRoleMember = 2
};



//MARK:- 群通知
typedef NS_ENUM(NSInteger, DMNotifyStatus) {
    DMNotifyStatusExpired = -1, //过期 过期时间设定72小时
    DMNotifyStatusUnread = 0,
    DMNotifyStatusRead = 1,
    DMNotifyStatusReject = 2, //拒绝
    DMNotifyStatusFulfilled = 3, //接受
};

typedef NS_ENUM(NSInteger, DMNotifyType) {
    DMNotifyTypeApprove = 0, //群申请入群通知
};

@interface CPGroupMember : NSObject

@property (nonatomic, assign) int sessionId; // group -> public key

@property (nonatomic, copy) NSString *hexPubkey;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) GroupRole role;

@property (nonatomic, assign) int64_t join_time; //join_time

@end

/// claim history
@interface CPChainClaim : NSObject

@property (nonatomic, copy) NSString *txhash; //id result
/// 1 chat  3 application
@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString *moniker; //node name
@property (nonatomic, copy) NSString *operator_address; //node address
@property (nonatomic, assign) int chain_status; //0 wait 1succ  2fail

@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;
@property (nonatomic, copy) NSString *endpoint; //https://

@end


/**
 login user
 */
@interface User : NSObject

/// auto add to account folder
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) unsigned long long pubkeySignHash;
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;

@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, strong) NSDictionary *localExt; //

@end

@interface User()
//save in mem
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *password;
@end

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypeP2P = 0, //person to person
    SessionTypeGroup, //group
};

typedef NS_ENUM(NSInteger, ContactStatus) {
    ContactStatusNormal = 0, // normal, or have read new friend
    ContactStatusStrange = 1, //stranger
    ContactStatusNewFriend = 2, //new friend
    ContactStatusAssistHelper = 3, //assister，like stranger
};

typedef NS_ENUM(NSInteger, GroupCreateProgress) {
    GroupCreateProgressUnknown = -100, //default, have no idea
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
    CPGroupInviteTypeAllowAll = 0, //允许所有人自由邀请
    CPGroupInviteTypeNeedApprove = 1, //进群需要群主审核
    CPGroupInviteTypeOnlyOwner = 2, // 禁用二维码，客户端邀请方式禁止。 群主端只有加号，禁止二维码
};

//MARK:- Contact
@interface CPContact : NSObject

@property (nonatomic, copy) NSString *publicKey; //hexstring
@property (nonatomic, copy) NSString *remark; //remark，group name
@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) SessionType sessionType;

@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime; //秒s
@property (nonatomic, strong) NSDictionary *localExt;

@property (nonatomic, assign) BOOL isBlack; //for p2p sessionType
@property (nonatomic, assign) BOOL isDoNotDisturb;

@property (nonatomic, assign) ContactStatus status; //for p2p sessionType

//for group
//use user private key sha256 , aes encode, to store
@property (nonatomic, strong) NSData *encodePrivateKey; //group private key

@property (nonatomic, assign) GroupCreateProgress groupProgress;
@property (nonatomic, copy) NSString *groupNodeAddress; //IPAL register operation_adrr : server address: 0402
@property (nonatomic, copy) NSString *txhash; //ipal hash
@property (nonatomic, assign) int64_t modifiedTime; //millisecond for group， local is not equal server，need update

//for notice
//use group private key sha256 , hexstring, aes encode, to store
@property (nonatomic, copy) NSString *notice_encrypt_content;
@property (nonatomic, assign) NSTimeInterval notice_modified_time; //S
@property (nonatomic, copy) NSString *notice_publisher;

//for group manage
@property (nonatomic, assign) int inviteType; //CPGroupInviteType

//for assist
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
    MessageTypeImage = 3, //upload pic hash
    
    //orgin data
    /// >>> invite cell
    MessageTypeInviteeUser = 2019777,
    
    ///>>>system cell
    MessageTypeGroupJoin = 2019778,
    MessageTypeGroupKick = 2019780,
    MessageTypeGroupQuit = 2019781,
    
    MessageTypeGroupUpdateName = 2019880,
    MessageTypeGroupUpdateNickName = 2019882, //delete
    
    /// local system cell
    MessageTypeWelcomNewFriends = 2020666,
    MessageTypeCreateGroupSuccess = 2020667,
    MessageTypeJoinGroupSuccess = 2020669,
    
    ///>>>> MessageTypeText Cell
    MessageTypeGroupUpdateNotice = 2019881, //公告
    MessageTypeAssistTip = 2019888, //Assist tip
};


typedef NS_ENUM(NSInteger, MessageUseWay) {
    MessageUseWayDefault = 0,
    MessageUseWayAtMe = 11,  //@me
    MessageUseWayAtAll = 12 //@all
};

//MARK:- Message
@interface CPMessage : NSObject {
@public
    NSString *_msgDecode; //for text
    NSData *_audioDecode; //pcm for play
    NSData *_imageDecode; //for img
}

@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) long long msgId;

@property (nonatomic, assign) MessageType msgType;
@property (nonatomic, assign) int version;

//maybe local create, or servers recived, local
//从服务器接受的时间
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;


@property (nonatomic, copy) NSString *senderPubKey;
@property (nonatomic, copy) NSString *toPubkey;

//is msg send to server, when sender pubkey is self, meaning
//0 unknown
//1 success
//2 error
//3: upload to http ok
@property (nonatomic, assign) int toServerState;

//hash of the msg sign
@property (nonatomic, assign) unsigned long long signHash;

//encrypt
@property (nonatomic, strong, nullable) NSData *msgData;

//for self , is msg read
//group 内被弃用
@property (nonatomic, assign) BOOL read;
//for self, is audio play
@property (nonatomic, assign) BOOL audioRead;
@property (nonatomic, strong) NSString *fileHash; //transfer big 32bytes int to hex string (64bytes)

//audio length times
@property (nonatomic, assign) NSInteger audioTimes;
//MARK:- for Image size
@property (nonatomic, assign) NSInteger pixelWidth;
@property (nonatomic, assign) NSInteger pixelHeight;

//MARK:- For Group Invite
@property (nonatomic, strong) NSData *encodePrivateKey; //group private key
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) int64_t server_msg_id;

/// 0 ok 1 delete  2 非delete 但是是未读，不算未读量   mock：10 上拉取不算
@property (nonatomic, assign) int isDelete;
@property (nonatomic, strong) NSData *group_pub_key; //origin pubkey, 根据邀请类型

@property (nonatomic, assign) MessageUseWay useway; //用途

@end

@interface CPMessage (ext)
@property (nonatomic, assign, readonly) BOOL isGroupChat;
@end

@interface CPMessage ()

- (NSData * _Nullable)decodeGroupPrivateKey;

@property (nonatomic, assign) BOOL doNotDisturb;
@property (nonatomic, assign) BOOL showCreateTime;
@property (nonatomic, copy) NSString *senderRemark; //if group member

//Note: decode need long time
- (id)msgDecodeContent;
- (id)msgDecodeContent_onlyTextType;

- (void)resetImage;

//Note: if you send image, this progress handle will call back, if you set
@property (nonatomic, copy, nullable) void (^uploadProgressHandle)(double progress);

//Note: if you recieve image, this progress handle will call back, if you set
@property (nonatomic, copy, nullable) void (^downloadProgressHandle)(double progress);

//Note: when data exit, direct call this, success ok, fail no
@property (nonatomic, copy, nullable) void (^normalCompleteHandle)(BOOL);

//MARK:- for recieve user
@property (nonatomic, assign) BOOL toUserNotFound;

@end



//MARK:-  Session

@interface CPSession : NSObject

@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) SessionType sessionType;
@property (nonatomic, assign) long long lastMsgId;
@property (nonatomic, strong) NSDictionary *localExt;
@property (nonatomic, assign) int topMark; //1 mark as top
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;

//for group
@property (nonatomic, assign) NSInteger groupUnreadCount;

@end

@interface CPSession ()

@property (nullable, nonatomic, strong)  CPMessage  *lastMsg;
@property (nonatomic, assign)  NSInteger unreadCount;
@property (nonatomic, strong) CPContact *relateContact;
@property (nonatomic, strong) NSArray<CPGroupMember *> *groupRelateMember;

@property (nullable, nonatomic, strong)  CPMessage  *atRelateMsg;

@end




//离线消息中获取: record  同一个人可能一样
@interface CPGroupNotify : NSObject
@property (nonatomic, assign) int64_t noticeId;
@property (nonatomic, assign) int sessionId; // group -> public key, 需要判断 contact 是否存在，是否是group
@property (nonatomic, assign) DMNotifyType type;
@property (nonatomic, assign) DMNotifyStatus status;


@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) uint64_t signHash;

@property (nonatomic, copy) NSString *senderPublicKey; //申请者Hex public key
@property (nonatomic, strong) NSData *approveNotify; //GroupJoinApproveNotify

@end

//decode all things as like this
@interface CPGroupNotify ()

@property (nonatomic, assign) BOOL manualDecode;

@property (nonatomic, strong, nullable) NCProtoNetMsg *join_msg;
@property (nonatomic, strong, nullable) NCProtoGroupJoin *decodeJoinRequest; //Note: to be public
@property (nonatomic, copy, nullable) NSString *inviterNickName;  //邀请者 在群内昵称
- (NSString * _Nullable)decodeRequestReason;

 
@end


NS_ASSUME_NONNULL_END


#import "CPSimpleDataModel.h"
