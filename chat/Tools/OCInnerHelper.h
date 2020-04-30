//
//  OCInnerHelper.h
//  chat
//
//  Created by Grand on 2020/3/11.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCInnerHelper : NSObject

@property (nonatomic, weak) UITextField *input;

- (NSRange)rangeForPrefix:(NSString *)prefix
                   suffix:(NSString *)suffix
       currentSelectRange:(NSRange)cRange;

@end


@interface UIImage (ptColor)

- (UIColor * _Nullable)colorAtPoint:(CGPoint)point;
@end


NS_ASSUME_NONNULL_END
