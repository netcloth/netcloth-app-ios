//
//  CPMsgRecieveHandleProtocol.h
//  chat-plugin
//
//  Created by Grand on 2019/11/27.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NCProtoNetMsg;

@protocol CPMsgRecieveHandleProtocol <NSObject>

- (void)actionForRegisterRsp:(NCProtoNetMsg *)pack;

@end

NS_ASSUME_NONNULL_END
