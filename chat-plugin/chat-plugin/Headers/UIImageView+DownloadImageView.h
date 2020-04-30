//
//  UIImageView+DownloadImageView.h
//  chat-plugin
//
//  Created by Grand on 2019/10/10.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (DownloadImageView)

- (void)nc_setImageHash:(CPMessage *)message;

@end

NS_ASSUME_NONNULL_END
