  
  
  
  
  
  
  

#import "FileDownloader.h"

NSOperationQueue *_ImageServiceQueue;
NSMutableArray<CPMessage *> *_RquestImageMsgs;

@implementation FileDownloader

+ (void)load {
    _ImageServiceQueue = NSOperationQueue.alloc.init;
    _ImageServiceQueue.maxConcurrentOperationCount = 1;
    _RquestImageMsgs = NSMutableArray.array;
}

+ (BOOL)isInDownloadingMsg:(CPMessage *)msg {
    for (CPMessage *tmp in _RquestImageMsgs) {
        if (tmp.msgId == msg.msgId) return YES;
    }
    return NO;
}


+ (void)addDownloadPool:(CPMessage *)msg {
    if ([self isInDownloadingMsg:msg]) {
        return;
    }
    [_RquestImageMsgs addObject:msg];
}

+ (void)removeDownloadPool:(CPMessage *)msg {
    NSMutableArray *toDel = @[].mutableCopy;
    for (CPMessage *tmp in _RquestImageMsgs) {
        if (tmp.msgId == msg.msgId) {
            [toDel addObject:tmp];
            break;
        }
    }
    [_RquestImageMsgs removeObjectsInArray:toDel];
}

+ (void)addDownloadOperation:(NSOperation *)operation {
    [_ImageServiceQueue addOperation:operation];
}

@end
