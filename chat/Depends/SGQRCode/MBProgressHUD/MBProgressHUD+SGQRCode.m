  
  
  
  
  
  
  

#import "MBProgressHUD+SGQRCode.h"

@implementation MBProgressHUD (SGQRCode)

 
+ (MBProgressHUD *)SG_showMBProgressHUDWithModifyStyleMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
      
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15];
    
      
    hud.bezelView.color = [UIColor blackColor];
      
    hud.contentColor = [UIColor whiteColor];
    
    [hud hideAnimated:YES afterDelay:5];
      
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}
 
+ (MBProgressHUD *)SG_showMBProgressHUDWithSystemComesStyleMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
      
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15];
    [hud hideAnimated:YES afterDelay:5];
      
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma mark - - - 显示信息
+ (void)showMessage:(NSString *)message icon:(NSString *)icon toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
      
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15];
    
      
    hud.bezelView.color = [UIColor blackColor];
      
    hud.contentColor = [UIColor whiteColor];
    
      
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    
      
    hud.mode = MBProgressHUDModeCustomView;
    
      
    hud.removeFromSuperViewOnHide = YES;
    
      
    [hud hideAnimated:YES afterDelay:1.0];
}

 
+ (void)SG_showMBProgressHUDOfSuccessMessage:(NSString *)message toView:(UIView *)view {
    [self showMessage:message icon:@"success" toView:view];
}

 
+ (void)SG_showMBProgressHUDOfErrorMessage:(NSString *)message toView:(UIView *)view {
    [self showMessage:message icon:@"error" toView:view];
}

#pragma mark - - - 隐藏MBProgressHUD
 
+ (void)SG_hideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

/** MBProgressHUD 修改后的样式 (10s) */
+ (MBProgressHUD *)SG_showMBProgressHUD10sHideWithModifyStyleMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
      
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15];
    
      
    hud.bezelView.color = [UIColor blackColor];
      
    hud.contentColor = [UIColor whiteColor];
    
    [hud hideAnimated:YES afterDelay:10];
      
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}


/** 只显示文字的 15 号字体（文字最好不要超过 14 个汉字） MBProgressHUD */
+ (void)SG_showMBProgressHUDWithOnlyMessage:(NSString *)message delayTime:(CGFloat)time {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] delegate] window]] ;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15.0];
    hud.removeFromSuperViewOnHide = YES;
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    [hud showAnimated:YES];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:hud];
    
    [hud hideAnimated:YES afterDelay:time];
}


@end

