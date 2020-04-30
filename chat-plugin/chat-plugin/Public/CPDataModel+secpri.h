







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
#import <WCDB/WCDB.h>


NS_ASSUME_NONNULL_BEGIN


@interface CPTradeRsp (secpri) <WCTTableCoding>


WCDB_PROPERTY(txhash)
WCDB_PROPERTY(tid)

WCDB_PROPERTY(type)

WCDB_PROPERTY(status);

WCDB_PROPERTY(createTime);


WCDB_PROPERTY(amount);

WCDB_PROPERTY(chainId);
WCDB_PROPERTY(symbol);


WCDB_PROPERTY(txfee);

WCDB_PROPERTY(fromAddr);
WCDB_PROPERTY(toAddr);

WCDB_PROPERTY(memo); 

@end


@interface CPAssetToken (secpri) <WCTTableCoding>

WCDB_PROPERTY(chainID)
WCDB_PROPERTY(symbol)
WCDB_PROPERTY(balance)

@end


@interface CPChainClaim (secpri) <WCTTableCoding>

WCDB_PROPERTY(txhash)
WCDB_PROPERTY(type)
WCDB_PROPERTY(moniker)
WCDB_PROPERTY(operator_address)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(chain_status)
WCDB_PROPERTY(endpoint)

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
WCDB_PROPERTY(isDoNotDisturb)
WCDB_PROPERTY(status)

WCDB_PROPERTY(encodePrivateKey)

WCDB_PROPERTY(groupNodeAddress)
WCDB_PROPERTY(groupProgress)
WCDB_PROPERTY(txhash)
WCDB_PROPERTY(modifiedTime)

WCDB_PROPERTY(notice_encrypt_content)
WCDB_PROPERTY(notice_modified_time)
WCDB_PROPERTY(notice_publisher)
WCDB_PROPERTY(inviteType)

WCDB_PROPERTY(avatar)
WCDB_PROPERTY(server_addr)

@end

@interface CPContact () {
    std::string  _decodeOriPrivateKey;
    NSData * _decodePrikey;
}

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

WCDB_PROPERTY(audioTimes)
WCDB_PROPERTY(pixelWidth)
WCDB_PROPERTY(pixelHeight)
WCDB_PROPERTY(encodePrivateKey)
WCDB_PROPERTY(groupName)
WCDB_PROPERTY(server_msg_id)
WCDB_PROPERTY(isDelete)
WCDB_PROPERTY(group_pub_key)
WCDB_PROPERTY(useway)

@end

@interface CPMessage ()
@property (nonatomic, assign) BOOL isGroupChat;
@end

@interface CPSession (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(sessionType)
WCDB_PROPERTY(lastMsgId)

WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(localExt)

WCDB_PROPERTY(topMark)
WCDB_PROPERTY(groupUnreadCount)

@end



@interface CPGroupMember (secpri) <WCTTableCoding>

WCDB_PROPERTY(sessionId)

WCDB_PROPERTY(hexPubkey)
WCDB_PROPERTY(nickName)
WCDB_PROPERTY(role)

WCDB_PROPERTY(join_time)

@end


@interface CPGroupNotify (secpri) <WCTTableCoding>

WCDB_PROPERTY(noticeId)
WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(type)
WCDB_PROPERTY(status)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(signHash)
WCDB_PROPERTY(approveNotify)
WCDB_PROPERTY(senderPublicKey)

@end


NS_ASSUME_NONNULL_END
