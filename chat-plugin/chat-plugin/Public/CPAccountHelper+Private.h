//
//  CPAccountHelper+Private.h
//  chat-plugin
//
//  Created by Grand on 2019/11/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <chat_plugin/chat_plugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPAccountHelper (Private)

//host : port
+ (void)onShouldReinitConnectToUseNewHostAndPort;

@end

NS_ASSUME_NONNULL_END
