//
//  CPAssetTokenHelper.h
//  chat-plugin
//
//  Created by Grand on 2020/4/24.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPAssetTokenHelper : NSObject

+ (void)insertOrUpdate:(NSString *)balance
            whereChain:(int)chainId
                symbol:(NSString *)symbol
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)getBalanceWhereChain:(int)chainId
                      symbol:(NSString *)symbol
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSString *balance))result;


/// for Trade Rsp
+ (void)insertTradeRsp:(CPTradeRsp *)trade
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateTradeStatus:(TradeRspStatus)status
                    where:(int)chainId
                   symbol:(NSString *)symbol
                   txhash:(NSString *)txhash
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

/// 倒序从后找
+ (void)getAllTradeRecordWhere:(int)chainId
                     symbol:(NSString *)symbol
                        tid:(int64_t)tid  ///-1
                       size:(NSInteger)size //default 20
                   complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;

+ (void)getTradeOutRecordWhere:(int)chainId
                        symbol:(NSString *)symbol
                           tid:(int64_t)tid  ///-1
                          size:(NSInteger)size //default 20
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


+ (void)getTradeInRecordWhere:(int)chainId
                       symbol:(NSString *)symbol
                          tid:(int64_t)tid  ///-1
                         size:(NSInteger)size //default 20
                     complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


+ (void)getTradeFailRecordWhere:(int)chainId
                         symbol:(NSString *)symbol
                            tid:(int64_t)tid  ///-1
                           size:(NSInteger)size //default 20
                       complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


@end

NS_ASSUME_NONNULL_END
