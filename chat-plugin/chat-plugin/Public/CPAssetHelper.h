







#import <Foundation/Foundation.h>
#import "CPDataModel.h"

@interface CPAssetHelper : NSObject

+ (void)insertCipalHistroy:(NSString *)txhash
                   moniker:(NSString * _Nullable)moniker
            server_address:(NSString * _Nullable)address
              chain_status:(int)status 
                  callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)updateChain_status:(int)status
               whereTxHash:(NSString *)txhash
                  callback:(void(^)(BOOL succss, NSString *msg))result;

+ (void)getObjectWhereTxHash:(NSString *)txhash
                    callback:(void(^)(BOOL succss, CPChainClaim *obj))result;


+ (void)getCipalHistoryLimited:(void (^)(NSArray <CPChainClaim *> * _Nullable))result;

@end

