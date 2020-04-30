//
//  GTableDelegateContainer.h
//  Demo
//
//  Created by Grand on 2018/9/25.
//  Copyright © 2018年 G.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTableDelegateContainer : NSObject <UITableViewDelegate, UITableViewDataSource>

- (void)addDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
