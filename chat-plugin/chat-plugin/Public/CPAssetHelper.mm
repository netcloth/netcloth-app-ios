







#import "CPAssetHelper.h"
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import <YYKit/YYKit.h>
#import "key_tool.h"
#import "string_tools.h"
#import "CPBridge.h"
#import "MessageObjects.h"

@implementation CPAssetHelper

+ (void)insertCipalHistroy:(NSString *)txhash
                   moniker:(NSString *)moniker
            server_address:(NSString *)address
              chain_status:(int)status
                  callback:(void(^)(BOOL succss, NSString *msg))result;

{
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        CPChainClaim *cla = CPChainClaim.alloc.init;
        cla.type = 1;
        cla.txhash = txhash;
        cla.moniker = moniker;
        cla.operator_address = address;
        cla.createTime = NSDate.date.timeIntervalSince1970;
        cla.chain_status = status;
        
        BOOL r =
        [CPInnerState.shared.loginUserDataBase insertObject:cla into:kTableName_Claim];
        
        finalBack(r, nil);
    }];
}


+ (void)updateChain_status:(int)status
               whereTxHash:(NSString *)txhash
                  callback:(void(^)(BOOL succss, NSString *msg))result {
    void (^finalBack)(BOOL, NSString *) = ^(BOOL succss, NSString *msg) {
        if (result) {
            dispatch_main_async_safe(^{
                result(succss, msg);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
           BOOL r =
           [CPInnerState.shared.loginUserDataBase updateRowsInTable:kTableName_Claim onProperties:CPChainClaim.chain_status withRow:@[@(status)] where:CPChainClaim.txhash == txhash];
           
           finalBack(r, nil);
       }];
}


+ (void)getObjectWhereTxHash:(NSString *)txhash
                    callback:(void(^)(BOOL succss, CPChainClaim *obj))result {
    
    void (^finalBack)(BOOL, CPChainClaim *) = ^(BOOL succss, CPChainClaim *msg) {
           if (result) {
               dispatch_main_async_safe(^{
                   result(succss, msg);
               });
           }
       };
    
    [CPInnerState.shared asynWriteTask:^{
        CPChainClaim *obj =
        [CPInnerState.shared.loginUserDataBase getOneObjectOfClass:CPChainClaim.class
                                                         fromTable:kTableName_Claim
                                                             where:CPChainClaim.txhash == txhash];
        
        finalBack(obj != nil, obj);
    }];
}


+ (void)getCipalHistoryLimited:(void (^)(NSArray <CPChainClaim *> * _Nullable))result {
    void (^finalBack)(NSArray *) = ^(NSArray *arrays) {
        if (result) {
            dispatch_main_async_safe(^{
                result(arrays);
            });
        }
    };
    
    [CPInnerState.shared asynWriteTask:^{
        
        NSArray *carray =
        [CPInnerState.shared.loginUserDataBase
         getObjectsOfClass:CPChainClaim.class
         fromTable:kTableName_Claim
         orderBy:CPChainClaim.createTime.order(WCTOrderedDescending)
         limit:100];
        
        finalBack(carray);
    }];
    
}

@end
