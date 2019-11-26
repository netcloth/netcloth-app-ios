







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPChainClaim (secpri) <WCTTableCoding>

WCDB_PROPERTY(txhash)
WCDB_PROPERTY(type)
WCDB_PROPERTY(moniker)
WCDB_PROPERTY(operator_address)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(chain_status)

@end


@interface User (secpri) <WCTTableCoding>

WCDB_PROPERTY(userId)
WCDB_PROPERTY(accountName)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)
WCDB_PROPERTY(pubkeySignHash)

@end


@interface CPContact (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(sessionType)

WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)

WCDB_PROPERTY(publicKey)
WCDB_PROPERTY(remark)
WCDB_PROPERTY(isBlack)


@end


@interface CPMessage (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(msgId)
WCDB_PROPERTY(msgType)
WCDB_PROPERTY(senderPubKey)
WCDB_PROPERTY(toPubkey)
WCDB_PROPERTY(msgData)
WCDB_PROPERTY(read)
WCDB_PROPERTY(audioRead)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)
WCDB_PROPERTY(version)
WCDB_PROPERTY(toServerState)
WCDB_PROPERTY(signHash)
WCDB_PROPERTY(fileHash)

@end

@interface CPSession (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(sessionType)
WCDB_PROPERTY(lastMsgId)

WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)

WCDB_PROPERTY(topMark)

@end

@interface CPSessionUsers (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(sessionType)
WCDB_PROPERTY(userKey)
WCDB_PROPERTY(joinTime)

WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)

@end

NS_ASSUME_NONNULL_END
