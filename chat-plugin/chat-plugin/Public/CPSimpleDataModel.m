//
//  CPSimpleDataModel.m
//  chat-plugin
//
//  Created by Grand on 2020/4/29.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import "CPSimpleDataModel.h"


@implementation CPAssistant
@end

@implementation CPRecommendedGroup
@end



//MARK:- 没有数据库
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
