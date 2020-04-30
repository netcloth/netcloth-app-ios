//
//  GroupChatMessageHandleRecieve.h
//  chat-plugin
//
//  Created by Grand on 2019/11/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPMessageRecieveHandleProtocol.h>

@class CPContact, CPMessage;

NS_ASSUME_NONNULL_BEGIN

@interface GroupChatMessageHandleRecieve : NSObject <CPMessageRecieveHandleProtocol>

- (void)actionForGroupReceipt:(NCProtoNetMsg *)pack;

- (BOOL)storeMessge:(id)message isCacheMsg:(BOOL)isCache;

- (CPContact * _Nullable)findCacheContactByGroupPubkey:(NSString *)groupPubkey;


- (CPMessage * )_v2DealRecieveNetMsg:(NCProtoNetMsg *)msg
                             isCache:(BOOL)isCache
                     storeEncodeData:(id)data
                        orOriginData:(id)originData;
- (void)addStack:(CPMessage *)msg;

@end

NS_ASSUME_NONNULL_END
