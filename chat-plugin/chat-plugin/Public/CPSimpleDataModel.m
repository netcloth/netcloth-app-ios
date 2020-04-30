







#import "CPSimpleDataModel.h"


@implementation CPAssistant
@end

@implementation CPRecommendedGroup
@end




@implementation CPGroupNotifySession
@end

@implementation CPGroupNotifyPreview

- (NSInteger)needApproveCount {
    return _readCount + _unreadCount;
}

@end




@implementation CPGroupInfoResp

@end


@implementation CPUnreadResponse
@end
