//
//  CPOfflineMsgManager.h
//  chat-plugin
//
//  Created by Grand on 2019/9/18.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString *kStart_sys_time;
extern NSString *kStart_sys_hash;
extern NSString *kStart_query_time;

@interface CPOfflineMsgManager : NSObject

@property(nonatomic, assign) NSUInteger fetchId;

- (void)_bridgeOnLogin;
- (void)_startFetchCacheMsg;

- (void)handleOnlineMsg:(CPMessage *)msg;
- (void)handleCacheMsg:(CPMessage *)cacheLastMsg;
- (void)setSysMark:(BOOL)sysOk;

+ (void)deleteOffKeyOfUser:(NSInteger)uid;

@end



NS_ASSUME_NONNULL_END
