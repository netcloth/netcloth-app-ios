







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



+ (void)insertTradeRsp:(CPTradeRsp *)trade
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;

+ (void)updateTradeStatus:(TradeRspStatus)status
                    where:(int)chainId
                   symbol:(NSString *)symbol
                   txhash:(NSString *)txhash
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result;


+ (void)getAllTradeRecordWhere:(int)chainId
                     symbol:(NSString *)symbol
                        tid:(int64_t)tid  
                       size:(NSInteger)size 
                   complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;

+ (void)getTradeOutRecordWhere:(int)chainId
                        symbol:(NSString *)symbol
                           tid:(int64_t)tid  
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


+ (void)getTradeInRecordWhere:(int)chainId
                       symbol:(NSString *)symbol
                          tid:(int64_t)tid  
                         size:(NSInteger)size 
                     complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


+ (void)getTradeFailRecordWhere:(int)chainId
                         symbol:(NSString *)symbol
                            tid:(int64_t)tid  
                           size:(NSInteger)size 
                       complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete;


@end

NS_ASSUME_NONNULL_END
