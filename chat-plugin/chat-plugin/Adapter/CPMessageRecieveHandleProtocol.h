//
//  CPMessageRecieveHandleProtocol.h
//  chat-plugin
//
//  Created by Grand on 2019/11/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPMessageRecieveHandleProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@class NCProtoNetMsg;

@protocol CPMessageRecieveHandleProtocol <NSObject>

@optional
- (void)actionForRegisterRsp:(NCProtoNetMsg *)pack;

@optional
- (void)actionForText:(NCProtoNetMsg *)pack;
- (void)actionForAudio:(NCProtoNetMsg *)pack;
- (void)actionForImage:(NCProtoNetMsg *)pack;
- (void)actionForServerReceipt:(NCProtoNetMsg *)pack;
- (void)actionForCacheMsgRsp:(NCProtoNetMsg *)pack;

@optional
- (void)actionForGroupReceipt:(NCProtoNetMsg *)pack;

- (void)actionForGroupGetMemberRsp:(NCProtoNetMsg *)pack;

- (void)actionForGroupInvite:(NCProtoNetMsg *)pack;
- (void)actionForGroupJoin:(NCProtoNetMsg *)pack;

- (void)actionForGroupUpdateName:(NCProtoNetMsg *)pack;
- (void)actionForGroupUpdateNotice:(NCProtoNetMsg *)pack;
- (void)actionForGroupUpdateNickName:(NCProtoNetMsg *)pack;

- (void)actionForGroupText:(NCProtoNetMsg *)pack;
- (void)actionForGroupAudio:(NCProtoNetMsg *)pack;
- (void)actionForGroupImage:(NCProtoNetMsg *)pack;

- (void)actionForGroupGetMsgRsp:(NCProtoNetMsg *)pack;

- (void)actionForGroupGetUnreadRsp:(NCProtoNetMsg *)pack;

- (void)actionForGroupDismiss:(NCProtoNetMsg *)pack;

@end

NS_ASSUME_NONNULL_END
