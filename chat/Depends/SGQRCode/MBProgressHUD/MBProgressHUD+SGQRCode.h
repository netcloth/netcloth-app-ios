  
  
  
  
  
  
  

#import "MBProgressHUD.h"

@interface MBProgressHUD (SGQRCode)

/** MBProgressHUD修改后的样式 添加到self.navigationController.view上，导航栏不能被点击 */
+ (MBProgressHUD *)SG_showMBProgressHUDWithModifyStyleMessage:(NSString *)message toView:(UIView *)view;
/** MBProgressHUD系统自带样式 添加到self.navigationController.view上，导航栏不能被点击 */
+ (MBProgressHUD *)SG_showMBProgressHUDWithSystemComesStyleMessage:(NSString *)message toView:(UIView *)view;
 
+ (MBProgressHUD *)SG_showMBProgressHUD10sHideWithModifyStyleMessage:(NSString *)message toView:(UIView *)view;

 
+ (void)SG_showMBProgressHUDOfSuccessMessage:(NSString *)message toView:(UIView *)view;

 
+ (void)SG_showMBProgressHUDOfErrorMessage:(NSString *)message toView:(UIView *)view;

 
+ (void)SG_hideHUDForView:(UIView *)view;

/** 只显示文字的 15 号字体（文字最好不要超过 14 个汉字） MBProgressHUD */
+ (void)SG_showMBProgressHUDWithOnlyMessage:(NSString *)message delayTime:(CGFloat)time;

@end
