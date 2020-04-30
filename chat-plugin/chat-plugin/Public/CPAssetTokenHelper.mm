







#import "CPAssetTokenHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <YYKit/YYKit.h>
#import "key_tool.h"
#import "string_tools.h"
#import "CPBridge.h"
#import "MessageObjects.h"

@implementation CPAssetTokenHelper

+ (void)insertOrUpdate:(NSString *)balance
            whereChain:(int)chainId
                symbol:(NSString *)symbol
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPAssetToken *token = CPAssetToken.alloc.init;
        token.chainID = chainId;
        token.symbol = symbol;
        token.balance = balance;
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase insertOrReplaceObject:token into:kTableName_AssetToken];
        
        finalBack(r, nil);
    }];
}


+ (void)getBalanceWhereChain:(int)chainId
                      symbol:(NSString *)symbol
                    callback:(void(^ __nullable)(BOOL succss, NSString *msg, NSString * balance))result {
    
    void (^finalBack)(BOOL, NSString *, NSString * balance) = ^(BOOL succss, NSString *msg, NSString * balance) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg, balance);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPAssetToken *find =
        [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPAssetToken.class
                                                         fromTable:kTableName_AssetToken
                                                             where:CPAssetToken.chainID == chainId && CPAssetToken.symbol == symbol];
        
        finalBack(find != nil, nil, find.balance);
    }];
    
}


+ (void)insertTradeRsp:(CPTradeRsp *)trade
              callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        trade.isAutoIncrement = YES;
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase insertObject:trade into:kTableName_TradeRecord];
        
        if (r) {
            trade.tid == trade.lastInsertedRowID;
        }
        
        finalBack(r, nil);
    }];
}

+ (void)updateTradeStatus:(TradeRspStatus)status
                    where:(int)chainId
                   symbol:(NSString *)symbol
                   txhash:(NSString *)txhash
                 callback:(void(^ __nullable)(BOOL succss, NSString *msg))result {
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase
         updateRowsInTable:kTableName_TradeRecord
         onProperties:{CPTradeRsp.status}
         withRow:@[@(status)]
         where:CPTradeRsp.chainId == chainId
         && CPTradeRsp.symbol == symbol
         && CPTradeRsp.txhash == txhash
         ];
        
        finalBack(r, nil);
    }];
}




+ (void)getAllTradeRecordWhere:(int)chainId
                        symbol:(NSString *)symbol
                           tid:(int64_t)tid  
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete {
    
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPTradeRsp *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase
                             prepareSelectObjectsOnResults:CPTradeRsp.AllProperties
                             fromTable:kTableName_TradeRecord];
        
        if (tid == -1) {
            array = [[[select
                       where:CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol]
                      
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select
                       where: CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.tid < tid]
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
}


+ (void)getTradeOutRecordWhere:(int)chainId
                        symbol:(NSString *)symbol
                           tid:(int64_t)tid  
                          size:(NSInteger)size 
                      complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete {
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPTradeRsp *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase
                             prepareSelectObjectsOnResults:CPTradeRsp.AllProperties
                             fromTable:kTableName_TradeRecord];
        
        if (tid == -1) {
            array = [[[select
                       where:CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.type == TradeRspTypeTransfer]
                      
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select
                       where: CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.tid < tid
                       && CPTradeRsp.type == TradeRspTypeTransfer]
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
}


+ (void)getTradeInRecordWhere:(int)chainId
                       symbol:(NSString *)symbol
                          tid:(int64_t)tid  
                         size:(NSInteger)size 
                     complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete {
    
    [CPInnerState.shared asynDoTask:^{
        if (complete) {
            complete(YES,nil, nil);
        }
    }];
    return;
    
    
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPTradeRsp *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase
                             prepareSelectObjectsOnResults:CPTradeRsp.AllProperties
                             fromTable:kTableName_TradeRecord];
        
        if (tid == -1) {
            array = [[[select
                       where:CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol]
                      
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select
                       where: CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.tid < tid]
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
    
}


+ (void)getTradeFailRecordWhere:(int)chainId
                         symbol:(NSString *)symbol
                            tid:(int64_t)tid  
                           size:(NSInteger)size 
                       complete:(void (^)(BOOL success, NSString *msg, NSArray<CPTradeRsp *> * _Nullable trades))complete {
    
    NSInteger fsize = MAX(size, 0) ?: 20;
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray<CPTradeRsp *> *array;
        
        
        WCTSelect *select = [CPInnerState.shared.loginUserDataBase
                             prepareSelectObjectsOnResults:CPTradeRsp.AllProperties
                             fromTable:kTableName_TradeRecord];
        
        if (tid == -1) {
            array = [[[select
                       where:CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.status == TradeRspStatusFail ]
                      
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     
                     limit:fsize].allObjects;
        }
        else {
            
            array = [[[select
                       where: CPTradeRsp.chainId == chainId
                       && CPTradeRsp.symbol == symbol
                       && CPTradeRsp.tid < tid
                       && CPTradeRsp.status == TradeRspStatusFail]
                      orderBy:{CPTradeRsp.createTime.order(WCTOrderedDescending),
                CPTradeRsp.tid.order(WCTOrderedDescending)}]
                     limit:fsize].allObjects;
        }
        
        [CPInnerState.shared asynDoTask:^{
            if (complete) {
                complete(YES,nil,array);
            }
        }];
    }];
    
}

@end
