  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloader : NSObject

+ (BOOL)isInDownloadingMsg:(CPMessage *)msg;

+ (void)addDownloadPool:(CPMessage *)msg;
+ (void)removeDownloadPool:(CPMessage *)msg;

+ (void)addDownloadOperation:(NSOperation *)operation;

@end

NS_ASSUME_NONNULL_END
