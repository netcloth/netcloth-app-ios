







#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CPChainClaim : NSObject


@property (nonatomic, copy) NSString *txhash;
@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString *moniker;
@property (nonatomic, copy) NSString *operator_address;
@property (nonatomic, assign) int chain_status;

@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;

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
    SessionTypeP2P,
    SessionTypeGroup,
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

@end


typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeUnknown = -1,
    MessageTypeText = 1,
    MessageTypeAudio,
    MessageTypeImage,
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
@property (nonatomic, strong) NSDictionary *localExt  __attribute__((deprecated));
@property (nonatomic, strong) NSString *fileHash;

@end


@interface CPMessage ()

@property (nonatomic, assign) BOOL showCreateTime;
@property (nonatomic, copy) NSString *senderRemark;

- (id)msgDecodeContent;
- (id)msgDecodeContent_onlyTextType;


@property (nonatomic, assign) NSInteger audioTimes;


@property (nonatomic, assign) NSInteger pixelWidth;
@property (nonatomic, assign) NSInteger pixelHeight;
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

@end

@interface CPSession ()
@property (nullable, nonatomic, strong)  CPMessage  *lastMsg;
@property (nonatomic, assign)  NSInteger unreadCount;
@property (nonatomic, strong) CPContact *relateContact;
@end



@interface CPSessionUsers : NSObject

@property (nonatomic, assign) int sessionId;
@property (nonatomic, assign) SessionType sessionType;
@property (nonatomic, copy) NSString *userKey;
@property (nonatomic, strong) NSDate *joinTime;
@property (nonatomic, assign) double createTime;
@property (nonatomic, assign) double updateTime;

@property (nonatomic, strong) NSDictionary *localExt;

@end

NS_ASSUME_NONNULL_END
