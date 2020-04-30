//
//  CPAssetHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/11/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

@interface CPAssetHelper : NSObject

+ (void)insertCipalHistroy:(NSString *)txhash
                   moniker:(NSString * _Nullable)moniker
            server_address:(NSString * _Nullable)address //server address
              chain_status:(int)status  //0wait 1succ 2fail
                  callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)updateChain_status:(int)status
               whereTxHash:(NSString *)txhash
                  callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)getObjectWhereTxHash:(NSString *)txhash
                    callback:(void(^)(BOOL succss, CPChainClaim *obj))result;


+ (void)getCipalHistoryLimited:(void (^)(NSArray <CPChainClaim *> * _Nullable))result;


//MARK:- AIPAL
+ (void)insertAIPALHistroyMoniker:(NSString * _Nullable)moniker
                   server_address:(NSString * _Nullable)address
                         endPoint:(NSString *_Nullable)endPoint
                         callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)getAIPALHistoryLimited:(void (^)(NSArray <CPChainClaim *> * _Nullable))result;


@end

