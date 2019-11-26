







#import "CPDataModel.h"
#import <WCDB/WCDB.h>
#import "CPDataModel+secpri.h"

#include "key_tool.h"
#include "string_tools.h"
#import "CPInnerState.h"
#import "CPBridge.h"
#import <UIKit/UIKit.h>
#import <chat_plugin/CPContactHelper.h>

@implementation CPChainClaim
WCDB_IMPLEMENTATION(CPChainClaim)

WCDB_SYNTHESIZE(CPChainClaim, txhash)
WCDB_SYNTHESIZE(CPChainClaim, type)
WCDB_SYNTHESIZE(CPChainClaim, moniker)
WCDB_SYNTHESIZE(CPChainClaim, operator_address)
WCDB_SYNTHESIZE(CPChainClaim, createTime)
WCDB_SYNTHESIZE(CPChainClaim, updateTime)
WCDB_SYNTHESIZE_DEFAULT(CPChainClaim, chain_status, 0)

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

WCDB_PRIMARY_AUTO_INCREMENT(CPContact, sessionId)
WCDB_UNIQUE(CPContact, publicKey)

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

WCDB_PRIMARY_AUTO_INCREMENT(CPMessage, msgId)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", senderPubKey)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", toPubkey)
WCDB_MULTI_UNIQUE(CPMessage, "MultiUniqueConstraint", signHash)


- (id)msgDecodeContent {
    if (self.msgType == MessageTypeImage) {
        return [self p_decodeImage];
    }
    else if (self.msgType == MessageTypeText) {
        return [self p_decodeText];
    }
    else if (self.msgType == MessageTypeAudio) {
        return [self p_decodeAudio];
    }
    return nil;
}

- (id)msgDecodeContent_onlyTextType {
    if (self.msgType == MessageTypeText) {
        return [self p_decodeText];
    }
    return nil;
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
        if ([NSData cp_isEmpty:for_send]) {
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

WCDB_PRIMARY(CPSession, sessionId)

@end




@implementation CPSessionUsers

WCDB_IMPLEMENTATION(CPSessionUsers)
WCDB_SYNTHESIZE(CPSessionUsers, sessionId)
WCDB_SYNTHESIZE_DEFAULT(CPSessionUsers, sessionType,0)
WCDB_SYNTHESIZE(CPSessionUsers, userKey)
WCDB_SYNTHESIZE(CPSessionUsers, joinTime)

WCDB_SYNTHESIZE(CPSessionUsers, createTime)
WCDB_SYNTHESIZE(CPSessionUsers, updateTime)
WCDB_SYNTHESIZE(CPSessionUsers, localExt)

@end

