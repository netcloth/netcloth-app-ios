







#import "MBProgressHUD.h"

@interface MBProgressHUD (SGQRCode)


+ (MBProgressHUD *)SG_showMBProgressHUDWithModifyStyleMessage:(NSString *)message toView:(UIView *)view;

+ (MBProgressHUD *)SG_showMBProgressHUDWithSystemComesStyleMessage:(NSString *)message toView:(UIView *)view;

+ (MBProgressHUD *)SG_showMBProgressHUD10sHideWithModifyStyleMessage:(NSString *)message toView:(UIView *)view;


+ (void)SG_showMBProgressHUDOfSuccessMessage:(NSString *)message toView:(UIView *)view;


+ (void)SG_showMBProgressHUDOfErrorMessage:(NSString *)message toView:(UIView *)view;


+ (void)SG_hideHUDForView:(UIView *)view;


+ (void)SG_showMBProgressHUDWithOnlyMessage:(NSString *)message delayTime:(CGFloat)time;

@end
