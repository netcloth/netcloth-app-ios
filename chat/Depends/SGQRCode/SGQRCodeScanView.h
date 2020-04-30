







#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    CornerLoactionDefault,
    
    CornerLoactionInside,
    
    CornerLoactionOutside
} CornerLoaction;

typedef enum : NSUInteger {
    
    ScanAnimationStyleDefault,
    
    ScanAnimationStyleGrid
} ScanAnimationStyle;

@interface SGQRCodeScanView : UIView
/** 扫描样式，默认 ScanAnimationStyleDefault */
@property (nonatomic, assign) ScanAnimationStyle scanAnimationStyle;

@property (nonatomic, copy) NSString *scanImageName;
/** 边框颜色，默认白色 */
@property (nonatomic, strong) UIColor *borderColor;
/** 边角位置，默认 CornerLoactionDefault */
@property (nonatomic, assign) CornerLoaction cornerLocation;
/** 边角颜色，默认微信颜色 */
@property (nonatomic, strong) UIColor *cornerColor;
/** 边角宽度，默认 2.f */
@property (nonatomic, assign) CGFloat cornerWidth;
/** 扫描区周边颜色的 alpha 值，默认 0.2f */
@property (nonatomic, assign) CGFloat backgroundAlpha;
/** 扫描线动画时间，默认 0.02s */
@property (nonatomic, assign) NSTimeInterval animationTimeInterval;


- (void)addTimer;

- (void)removeTimer;

@end
