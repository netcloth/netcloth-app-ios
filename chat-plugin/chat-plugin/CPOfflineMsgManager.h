







#import <Foundation/Foundation.h>
#import "CPDataModel.h"
NS_ASSUME_NONNULL_BEGIN

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
