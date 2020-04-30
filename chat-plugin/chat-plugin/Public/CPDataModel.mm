







#import "CPDataModel.h"
#import <WCDB/WCDB.h>
#import "CPDataModel+secpri.h"

#include "key_tool.h"
#include "string_tools.h"
#import "CPInnerState.h"
#import "CPBridge.h"
#import <UIKit/UIKit.h>
#import <chat_plugin/CPContactHelper.h>
#include "audio_format_tool.h"

@implementation CPTradeRsp
WCDB_IMPLEMENTATION(CPTradeRsp)

WCDB_SYNTHESIZE(CPTradeRsp, txhash)
WCDB_SYNTHESIZE(CPTradeRsp, tid)

WCDB_SYNTHESIZE(CPTradeRsp, type)

WCDB_SYNTHESIZE(CPTradeRsp, status);

WCDB_SYNTHESIZE(CPTradeRsp, createTime);


WCDB_SYNTHESIZE(CPTradeRsp, amount);

WCDB_SYNTHESIZE(CPTradeRsp, chainId);
WCDB_SYNTHESIZE(CPTradeRsp, symbol);


WCDB_SYNTHESIZE(CPTradeRsp, txfee);

WCDB_SYNTHESIZE(CPTradeRsp, fromAddr);
WCDB_SYNTHESIZE(CPTradeRsp, toAddr);

WCDB_SYNTHESIZE(CPTradeRsp, memo); 

WCDB_PRIMARY_AUTO_INCREMENT(CPTradeRsp, tid)
WCDB_MULTI_UNIQUE(CPTradeRsp, "MultiUniqueConstraint", chainId)
WCDB_MULTI_UNIQUE(CPTradeRsp, "MultiUniqueConstraint", symbol)
WCDB_MULTI_UNIQUE(CPTradeRsp, "MultiUniqueConstraint", txhash)

@end

@implementation CPAssetToken
WCDB_IMPLEMENTATION(CPAssetToken)

WCDB_SYNTHESIZE(CPAssetToken, chainID)
WCDB_SYNTHESIZE(CPAssetToken, symbol)
WCDB_SYNTHESIZE(CPAssetToken, balance)

WCDB_MULTI_UNIQUE(CPAssetToken, "MultiUniqueConstraint", chainID)
WCDB_MULTI_UNIQUE(CPAssetToken, "MultiUniqueConstraint", symbol)

@end


@implementation CPChainClaim
WCDB_IMPLEMENTATION(CPChainClaim)

WCDB_SYNTHESIZE(CPChainClaim, txhash)
WCDB_SYNTHESIZE(CPChainClaim, type)
WCDB_SYNTHESIZE(CPChainClaim, moniker)
WCDB_SYNTHESIZE(CPChainClaim, operator_address)
WCDB_SYNTHESIZE(CPChainClaim, createTime)
WCDB_SYNTHESIZE(CPChainClaim, updateTime)
WCDB_SYNTHESIZE_DEFAULT(CPChainClaim, chain_status, 0)
WCDB_SYNTHESIZE(CPChainClaim, endpoint)


WCDB_PRIMARY(CPChainClaim, txhash)

@end

@implementation User
WCDB_IMPLEMENTATION(User)

WCDB_SYNTHESIZE(User, userId)
WCDB_SYNTHESIZE(User, accountName)
WCDB_SYNTHESIZE(User, createTime)
WCDB_SYNTHESIZE(User, updateTime)
WCDB_SYNTHESIZE(User, localExt)
WCDB_SYNTHESIZE(User, pubkeySignHash)

WCDB_UNIQUE(User, accountName)
WCDB_UNIQUE(User, pubkeySignHash)

WCDB_PRIMARY_AUTO_INCREMENT(User, userId)

@end


@implementation CPContact

WCDB_IMPLEMENTATION(CPContact)
WCDB_SYNTHESIZE(CPContact, publicKey)
WCDB_SYNTHESIZE(CPContact, remark)
WCDB_SYNTHESIZE(CPContact, sessionId)  
WCDB_SYNTHESIZE_DEFAULT(CPContact, sessionType,0)

WCDB_SYNTHESIZE(CPContact, createTime)
WCDB_SYNTHESIZE(CPContact, updateTime)
WCDB_SYNTHESIZE(CPContact, localExt)
WCDB_SYNTHESIZE_DEFAULT(CPContact, isBlack, NO)
WCDB_SYNTHESIZE_DEFAULT(CPContact, isDoNotDisturb, NO)
WCDB_SYNTHESIZE_DEFAULT(CPContact, status, ContactStatusNormal)

WCDB_SYNTHESIZE(CPContact, encodePrivateKey)
WCDB_SYNTHESIZE(CPContact, groupNodeAddress)
WCDB_SYNTHESIZE(CPContact, groupProgress)
WCDB_SYNTHESIZE(CPContact, txhash)
WCDB_SYNTHESIZE(CPContact, modifiedTime)

WCDB_SYNTHESIZE_COLUMN(CPContact, notice_encrypt_content, "gtEncCon")
WCDB_SYNTHESIZE_COLUMN(CPContact, notice_modified_time, "gtModTim")
WCDB_SYNTHESIZE_COLUMN(CPContact, notice_publisher, "gtPubler")
WCDB_SYNTHESIZE_DEFAULT(CPContact, inviteType, 0)

WCDB_SYNTHESIZE(CPContact, avatar)
WCDB_SYNTHESIZE(CPContact, server_addr)

WCDB_PRIMARY_AUTO_INCREMENT(CPContact, sessionId)
WCDB_UNIQUE(CPContact, publicKey)

- (NSString *)decodeNotice {
    if ([NSString cp_isEmpty:self.notice_encrypt_content]) {
        return nil;
    }
    std::string encode = bytesFromHexString(self.notice_encrypt_content);
    NSData *groupPrivateKey = [self decodePrivateKey];
    
    NSData *decode = [CPBridge aesDecodeData:encode byPrivateKey:nsdata2bytes(groupPrivateKey)];
    NSString *ret = [[NSString alloc] initWithData:decode encoding:NSUTF8StringEncoding];
    return ret;
}

- (void)setSourceNotice:(NSString *)notice {
    
    std::string source = nsstring2bytes(notice);
    NSData *groupPrivateKey = [self decodePrivateKey];
    std::string encode = [CPBridge aesEncodeData:source byPrivateKey:nsdata2bytes(groupPrivateKey)];
    
    NSString *hex = hexStringFromBytes(encode);
    self.notice_encrypt_content = hex;
}

- (NSData *)decodePrivateKey {
    if (_decodePrikey) {
        return _decodePrikey;
    }
    std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    std::string source = nsdata2bytes(self.encodePrivateKey);
    
    NSData *decode = [CPBridge aesDecodeData:source byPrivateKey:str_pri_key];
    if (decode.length > 0) {
        _decodePrikey = decode;
    }
    return decode;
}

- (void)setSourcePrivateKey:(NSData *)source {
    std::string str_pri_key = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    std::string encode = [CPBridge aesEncodeData:nsdata2bytes(source) byPrivateKey:str_pri_key];
    self.encodePrivateKey = bytes2nsdata(encode);
    self->_decodePrikey = source;
}


@end


@implementation CPSession

WCDB_IMPLEMENTATION(CPSession)
WCDB_SYNTHESIZE(CPSession, sessionId)
WCDB_SYNTHESIZE_DEFAULT(CPSession, sessionType,0)
WCDB_SYNTHESIZE(CPSession, lastMsgId)

WCDB_SYNTHESIZE(CPSession, createTime)
WCDB_SYNTHESIZE(CPSession, updateTime)
WCDB_SYNTHESIZE(CPSession, localExt)

WCDB_SYNTHESIZE_DEFAULT(CPSession, topMark, 0)
WCDB_SYNTHESIZE_COLUMN_DEFAULT(CPSession, groupUnreadCount, "gUnread", 0)


WCDB_PRIMARY(CPSession, sessionId)

- (NSInteger)unreadCount {
    if (_sessionType == SessionTypeGroup) {
        return _groupUnreadCount;
    }
    return _unreadCount;
}

@end


@implementation CPMessage

WCDB_IMPLEMENTATION(CPMessage)

WCDB_SYNTHESIZE(CPMessage, sessionId)
WCDB_SYNTHESIZE(CPMessage, msgId)
WCDB_SYNTHESIZE(CPMessage, msgType)

WCDB_SYNTHESIZE(CPMessage, senderPubKey)
WCDB_SYNTHESIZE(CPMessage, toPubkey)

WCDB_SYNTHESIZE(CPMessage, msgData)
WCDB_SYNTHESIZE(CPMessage, read)
WCDB_SYNTHESIZE(CPMessage, audioRead)

WCDB_SYNTHESIZE(CPMessage, createTime)
WCDB_SYNTHESIZE(CPMessage, updateTime)
WCDB_SYNTHESIZE(CPMessage, version)

WCDB_SYNTHESIZE_DEFAULT(CPMessage, toServerState, 1) 
WCDB_SYNTHESIZE(CPMessage, signHash)  
WCDB_SYNTHESIZE(CPMessage, fileHash) 


WCDB_SYNTHESIZE(CPMessage, audioTimes)
WCDB_SYNTHESIZE(CPMessage, pixelWidth)
WCDB_SYNTHESIZE(CPMessage, pixelHeight)

WCDB_SYNTHESIZE(CPMessage, encodePrivateKey)
WCDB_SYNTHESIZE(CPMessage, groupName)
WCDB_SYNTHESIZE_DEFAULT(CPMessage, server_msg_id ,0)
WCDB_SYNTHESIZE_DEFAULT(CPMessage, isDelete ,0)
WCDB_SYNTHESIZE_COLUMN(CPMessage, group_pub_key, "gPubK")

WCDB_SYNTHESIZE_DEFAULT(CPMessage, useway, MessageUseWayDefault)


WCDB_PRIMARY_AUTO_INCREMENT(CPMessage, msgId)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", senderPubKey)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", toPubkey)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", signHash)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", server_msg_id)

- (id)msgDecodeContent {
    
    if (self.isGroupChat) {
        if (self.msgType == MessageTypeImage) {
            return [self p_decodeGroupImage];
        }
        else if (self.msgType == MessageTypeText) {
            return [self p_decodeGroupText];
        }
        else if (self.msgType == MessageTypeAudio) {
            return [self p_decodeGroupAudio];
        }
    } else {
        if (self.msgType == MessageTypeImage) {
            return [self p_decodeImage];
        }
        else if (self.msgType == MessageTypeText) {
            return [self p_decodeText];
        }
        else if (self.msgType == MessageTypeAudio) {
            return [self p_decodeAudio];
        }
    }
    
    id decode = [self abstractDecodeLocal];
    return decode;
}

- (id)msgDecodeContent_onlyTextType {
    if (self.isGroupChat) {
        if (self.msgType == MessageTypeText) {
            return [self p_decodeGroupText];
        }
    } else {
        if (self.msgType == MessageTypeText) {
            return [self p_decodeText];
        }
    }
    id decode = [self abstractDecodeLocal];
    return decode;
}

- (id)abstractDecodeLocal {
    
    if (self.msgType == MessageTypeGroupUpdateNotice) {
        return  [self p_decodeNotice];
    }
    if (self.msgType >= MessageTypeInviteeUser) {
        return [self p_decodeOriginData];
    }
    return nil;
}


- (NSString *)p_decodeNotice {
    if ([NSString cp_isEmpty:_msgDecode] == false ||
        [_msgDecode isEqualToString: @""]) {
        return _msgDecode;
    }
    CPContact *groupContact = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:self.toPubkey];
    if (groupContact == nil) {
        return nil;
    }
    
    NSString *notice_encrypt_content = [[NSString alloc] initWithData:_msgData encoding:NSUTF8StringEncoding];
    if ([NSString cp_isEmpty:notice_encrypt_content]) {
        return nil;
    }
    std::string encode = bytesFromHexString(notice_encrypt_content);
    NSData *groupPrivateKey = groupContact.decodePrivateKey;
    NSData *decode = [CPBridge aesDecodeData:encode byPrivateKey:nsdata2bytes(groupPrivateKey)];
    NSString *ret = [[NSString alloc] initWithData:decode encoding:NSUTF8StringEncoding];
    _msgDecode = ret;
    return ret;
}


- (id)p_decodeOriginData {
    if (_msgData) {
        return  [[NSString alloc] initWithData:_msgData encoding:NSUTF8StringEncoding];
    }
    return @"";
}



- (id)p_decodeGroupText {
    if (![NSString cp_isEmpty:_msgDecode] || [_msgDecode  isEqual: @""]) {
        return _msgDecode;
    }
    if (_msgData.length >= 16) {
        std::string source = bytesHexFromData(_msgData);
        std::string fromPubkey = bytesFromHexString(self.senderPubKey);
        
        CPContact *groupContact = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:self.toPubkey];
        if (groupContact == nil) {
            return nil;
        }
        std::string groupPrikey = nsdata2bytes(groupContact.decodePrivateKey);
        std::string msg_decoded = [CPBridge ecdhDecodeMsg:source prikey:groupPrikey toPubkey:fromPubkey];
        
        NSString* msgContent = bytes2nsstring(msg_decoded);
        _msgDecode = msgContent;
        return _msgDecode;
    }
    
    if ([_senderPubKey isEqualToString:support_account_pubkey]) {
        return @"Support_Content".localized;
    }
    return nil;
}

- (id)p_decodeGroupAudio {
    if ([NSData cp_isEmpty:_audioDecode] == false) {
        return _audioDecode;
    }
    if (_msgData.length >= 16) {
        std::string source = bytesHexFromData(_msgData);
        std::string fromPubkey = bytesFromHexString(self.senderPubKey);
        
        CPContact *groupContact = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:self.toPubkey];
        if (groupContact == nil) {
            return nil;
        }
        std::string groupPrikey = nsdata2bytes(groupContact.decodePrivateKey);
        std::string msg_decoded = [CPBridge ecdhDecodeMsg:source prikey:groupPrikey toPubkey:fromPubkey];
        
        AudioFormatTool audio_tool = AudioFormatTool(0, msg_decoded, true);
        std::string for_play = audio_tool.GetPCMString();
        
        NSData *data = bytes2nsdata(for_play);
        
        _audioDecode = data;
        return _audioDecode;
    }
    return nil;
}
- (id)p_decodeGroupImage {
    if ([NSData cp_isEmpty:_imageDecode] == false) {
    }
    else if (_msgData.length >= 16) {
        
        std::string source = nsdata2bytes(_msgData);
        std::string fromPubkey = bytesFromHexString(self.senderPubKey);
        
        CPContact *groupContact = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:self.toPubkey];
        if (groupContact == nil) {
            return nil;
        }
        std::string groupPrikey = nsdata2bytes(groupContact.decodePrivateKey);
        std::string msg_decoded = [CPBridge ecdhDecodeMsg:source prikey:groupPrikey toPubkey:fromPubkey];
        
        NSData *data = bytes2nsdata(msg_decoded);
        
        _imageDecode = data;
    }
    else {
        NSString *fileHash = self.fileHash;
        id for_send = [CPInnerState.shared.imageCaches objectForKey:fileHash];
        if ([NSData cp_isEmpty:for_send]) {
            long long firstsign = (long long)self.signHash;
            fileHash = @(firstsign).stringValue;
            for_send = [CPInnerState.shared.imageCaches objectForKey:fileHash];
        }
        if ([NSData cp_isEmpty:for_send] ||
            [for_send length] < 16) {
            return nil;
        }
        _msgData = (NSData *)for_send;
        _imageDecode = [self p_decodeGroupImage];
    }
    
    if (self.pixelWidth == 0) {
        self.pixelWidth = 140;
        self.pixelHeight = 140;
    }
    return _imageDecode;
}



- (id)p_decodeText {
    if (![NSString cp_isEmpty:_msgDecode] || [_msgDecode  isEqual: @""]) {
        return _msgDecode;
    }
    if (_msgData.length) {
        _msgDecode = decodeMsgByte(self);
        return _msgDecode;
    }
    
    if ([_senderPubKey isEqualToString:support_account_pubkey]) {
        return @"Support_Content".localized;
    }
    return nil;
}

- (id)p_decodeAudio {
    if ([NSData cp_isEmpty:_audioDecode] == false) {
        return _audioDecode;
    }
    if (_msgData.length) {
        _audioDecode = decodeMsgByte(self);
        return _audioDecode;
    }
    return nil;
}
- (id)p_decodeImage {
    if ([NSData cp_isEmpty:_imageDecode] == false) {
    }
    else if (_msgData.length) {
        _imageDecode = decodeMsgByte(self);
    }
    else {
        NSString *fileHash = self.fileHash;
        id for_send = [CPInnerState.shared.imageCaches objectForKey:fileHash];
        if ([NSData cp_isEmpty:for_send]) {
            long long firstsign = (long long)self.signHash;
            fileHash = @(firstsign).stringValue;
            for_send = [CPInnerState.shared.imageCaches objectForKey:fileHash];
        }
        if ([NSData cp_isEmpty:for_send] ||
            [for_send length] < 16) {
            return nil;
        }
        _msgData = (NSData *)for_send;
        _imageDecode = decodeMsgByte(self);
    }
    
    if (self.pixelWidth == 0) {
        UIImage *image = [UIImage imageWithData:self->_imageDecode];
        if (!image) {
            self.pixelWidth = 140;
            self.pixelHeight = 140;
        } else {
            CGImageRef cg = image.CGImage;
            NSInteger w = CGImageGetWidth(cg);
            NSInteger h = CGImageGetHeight(cg);
            self.pixelWidth = w;
            self.pixelHeight = h;
        }
    }
     return _imageDecode;
}

- (void)resetImage {
    _imageDecode = nil;
}

- (NSData * _Nullable)decodeGroupPrivateKey {
    std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
    std::string source = nsdata2bytes(_encodePrivateKey);
    return [CPBridge aesDecodeData:source byPrivateKey:mySignPrikey];
}


@end



@implementation CPGroupMember

WCDB_IMPLEMENTATION(CPGroupMember)
WCDB_SYNTHESIZE(CPGroupMember, sessionId)

WCDB_SYNTHESIZE(CPGroupMember, hexPubkey)
WCDB_SYNTHESIZE(CPGroupMember, nickName)
WCDB_SYNTHESIZE(CPGroupMember, role)

WCDB_SYNTHESIZE(CPGroupMember, join_time)

WCDB_MULTI_UNIQUE(CPGroupMember, "MultiUniqueConstraint", hexPubkey)
WCDB_MULTI_UNIQUE(CPGroupMember, "MultiUniqueConstraint", sessionId)

@end



@implementation CPGroupNotify {
    NSString *_decodeReson;
}

WCDB_IMPLEMENTATION(CPGroupNotify)

WCDB_SYNTHESIZE(CPGroupNotify, noticeId)
WCDB_SYNTHESIZE(CPGroupNotify, sessionId)
WCDB_SYNTHESIZE(CPGroupNotify, type)
WCDB_SYNTHESIZE(CPGroupNotify, status)
WCDB_SYNTHESIZE(CPGroupNotify, createTime)
WCDB_SYNTHESIZE(CPGroupNotify, signHash)
WCDB_SYNTHESIZE(CPGroupNotify, approveNotify)
WCDB_SYNTHESIZE(CPGroupNotify, senderPublicKey)


WCDB_MULTI_UNIQUE(CPGroupNotify, "MultiUniqueConstraint", sessionId)
WCDB_MULTI_UNIQUE(CPGroupNotify, "MultiUniqueConstraint", signHash)
WCDB_MULTI_UNIQUE(CPGroupNotify, "MultiUniqueConstraint", createTime)
WCDB_PRIMARY_AUTO_INCREMENT(CPGroupNotify, noticeId)

- (NSString * _Nullable)decodeRequestReason {
    if (_decodeReson) {
        return _decodeReson;
    }
    
    if (self.decodeJoinRequest == nil) {
        return nil;
    }
    
    std::string source = bytesFromHexString(self.decodeJoinRequest.description_p);
    NSString *groupPubkey = [self.join_msg.head.toPubKey hexString_lower];
    CPContact *groupContact = [CPInnerState.shared.groupMsgRecieve findCacheContactByGroupPubkey:groupPubkey];
    if (groupContact == nil) {
        return nil;
    }
    
    std::string groupPrikey = nsdata2bytes(groupContact.decodePrivateKey);
    std::string senderPubkey = nsdata2bytes(self.join_msg.head.fromPubKey);
    std::string decode = [CPBridge ecdhDecodeMsg:source prikey:groupPrikey toPubkey:senderPubkey];
    _decodeReson = bytes2nsstring(decode);
    return _decodeReson;
}

@end
