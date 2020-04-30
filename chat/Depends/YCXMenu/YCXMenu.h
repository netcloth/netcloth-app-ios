







#import <Foundation/Foundation.h>
#import "YCXMenuItem.h"



extern NSString * const YCXMenuWillAppearNotification;

extern NSString * const YCXMenuDidAppearNotification;

extern NSString * const YCXMenuWillDisappearNotification;

extern NSString * const YCXMenuDidDisappearNotification;


typedef void(^YCXMenuSelectedItem)(NSInteger index, YCXMenuItem *item);

typedef enum {
    YCXMenuBackgrounColorEffectSolid      = 0, 
    YCXMenuBackgrounColorEffectGradient   = 1, 
} YCXMenuBackgrounColorEffect;

@interface YCXMenu : NSObject

+ (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems selected:(YCXMenuSelectedItem)selectedItem;

+ (void)dismissMenu;
+ (BOOL)isShow;


+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;


+ (CGFloat)cornerRadius;
+ (void)setCornerRadius:(CGFloat)cornerRadius;


+ (CGFloat)arrowSize;
+ (void)setArrowSize:(CGFloat)arrowSize;


+ (UIFont *)titleFont;
+ (void)setTitleFont:(UIFont *)titleFont;


+ (YCXMenuBackgrounColorEffect)backgrounColorEffect;
+ (void)setBackgrounColorEffect:(YCXMenuBackgrounColorEffect)effect;


+ (BOOL)hasShadow;
+ (void)setHasShadow:(BOOL)flag;


+ (UIColor*)selectedColor;
+ (void)setSelectedColor:(UIColor*)selectedColor;


+ (UIColor*)separatorColor;
+ (void)setSeparatorColor:(UIColor*)separatorColor;


+ (CGFloat)menuItemMarginY;
+ (void)setMenuItemMarginY:(CGFloat)menuItemMarginY;

@end
