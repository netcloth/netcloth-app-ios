







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
