







#import "UIImageView+DownloadImageView.h"
#import <YYKit/YYKit.h>
#import "CPDataModel+secpri.h"
#import "CPInnerState.h"
#import "FileDownloader.h"
#import "CPBridge.h"
#import <chat_plugin/chat_plugin-Swift.h>
#import "CPSendMsgHelper.h"

char *operationKey;
char *keyMsg;

@implementation UIImageView (DownloadImageView)

- (void)nc_setImageHash:(CPMessage *)message
{
    [self cancel];
    [self _handleMsg:message autoSendRequest:true];
}

- (void)cancel {
    self.image = nil; 
    NSOperation *op1 = [self getAssociatedValueForKey:&operationKey];
    [op1 cancel];
}

- (void)_handleMsg:(CPMessage *)message  autoSendRequest:(BOOL)send
{
    
    if (message.msgType != MessageTypeImage) {
        return;
    }
    
    
    if ([message->_imageDecode isKindOfClass:[NSData class]]) {
        self.image = [YYImage imageWithData:message->_imageDecode];
        if (message.normalCompleteHandle) {
            message.normalCompleteHandle(true);
        }
        return;
    }
    
    NSString *hash =  message.fileHash;
    if ([NSString cp_isEmpty:hash]) {
        return;
    }
    
    
    [self setAssociateValue:message withKey:&keyMsg];
    
    @weakify(self);
    @weakify(message);
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    @weakify(op);
    [op addExecutionBlock:^(void) {
        @strongify(self);
        @strongify(message);
        @strongify(op);
        NSData *imageData = message.msgDecodeContent;
        if (imageData && [imageData isKindOfClass:[NSData class]]) {
            [self restoreMsg:message hash:hash withData:imageData inOperation:op];
            return;
        }
        
        if (send == false) {
            return;
        }
        if ([FileDownloader isInDownloadingMsg:message]) {
            return;
        }
        
        [FileDownloader addDownloadPool:message];
        NSString *url = [CPNetURL.RequestImage stringByReplacingOccurrencesOfString:@"{hash}" withString:hash];
        [CPNetWork getDataUrlWithPath:url method:@"GET" para:nil complete:^(BOOL r, id _Nullable data) {
            [FileDownloader removeDownloadPool:message];
            if (r && data) {
                
                [CPSendMsgHelper onDownloadImageData:data withMessage:message];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imageData = message.msgDecodeContent;
                    [self restoreMsg:message hash:hash withData:imageData inOperation:op];
                });
            } else {
                
                if (message.normalCompleteHandle) {
                    message.normalCompleteHandle(false);
                }
            }
        }];
    }];
    
    [FileDownloader addDownloadOperation:op]; 
    [self setAssociateValue:op withKey:&operationKey];
}

- (void)restoreMsg:(CPMessage *)message
              hash:(NSString *)hash
          withData:(NSData *)decodeData
       inOperation:(NSOperation *)operation
{
    [CPInnerState.shared asynDoTask:^{
        BOOL canceled = operation.isCancelled;
        BOOL equal = [hash isEqualToString:((CPMessage *)[self getAssociatedValueForKey:&keyMsg]).fileHash];
        if (canceled || !equal) {
            return;
        }
        self.image = [YYImage imageWithData:decodeData];
        if (message.normalCompleteHandle) {
            message.normalCompleteHandle(true);
        }
    }];
}

@end
