  
  
  
  
  
  
  

#import <UIKit/UIKit.h>
@class SGQRCodeObtainConfigure, SGQRCodeObtain;

typedef void(^SGQRCodeObtainScanResultBlock)(SGQRCodeObtain *obtain, NSString *result);
typedef void(^SGQRCodeObtainScanBrightnessBlock)(SGQRCodeObtain *obtain, CGFloat brightness);
typedef void(^SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock)(SGQRCodeObtain *obtain);
typedef void(^SGQRCodeObtainAlbumResultBlock)(SGQRCodeObtain *obtain, NSString *result);

@interface SGQRCodeObtain : NSObject
 
+ (instancetype)QRCodeObtain;

#pragma mark - - 生成二维码相关方法
 
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size;
/**
 *  生成二维码（自定义颜色）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param color    二维码颜色
 *  @param backgroundColor    二维码背景颜色
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;
/**
 *  生成带 logo 的二维码（推荐使用）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param logoImage    logo
 *  @param ratio        logo 相对二维码的比例（取值范围 0.0 ～ 0.5f）
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio;
/**
 *  生成带 logo 的二维码（拓展）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param logoImage    logo
 *  @param ratio        logo 相对二维码的比例（取值范围 0.0 ～ 0.5f）
 *  @param logoImageCornerRadius    logo 外边框圆角（取值范围 0.0 ～ 10.0f）
 *  @param logoImageBorderWidth     logo 外边框宽度（取值范围 0.0 ～ 10.0f）
 *  @param logoImageBorderColor     logo 外边框颜色
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor;

#pragma mark - - 扫描二维码相关方法
 
- (void)establishQRCodeObtainScanWithController:(UIViewController *)controller configure:(SGQRCodeObtainConfigure *)configure;
 
- (void)setBlockWithQRCodeObtainScanResult:(SGQRCodeObtainScanResultBlock)block;
/** 扫描二维码光线强弱回调方法；调用之前配置属性 sampleBufferDelegate 必须为 YES */
- (void)setBlockWithQRCodeObtainScanBrightness:(SGQRCodeObtainScanBrightnessBlock)block;
 
- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion;
 
- (void)stopRunning;

 
- (void)playSoundName:(NSString *)name;

#pragma mark - - 相册中读取二维码相关方法
 
- (void)establishAuthorizationQRCodeObtainAlbumWithController:(UIViewController *)controller;
 
@property (nonatomic, assign) BOOL isPHAuthorization;
 
- (void)setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:(SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock)block;
 
- (void)setBlockWithQRCodeObtainAlbumResult:(SGQRCodeObtainAlbumResultBlock)block;

#pragma mark - - 手电筒相关方法
 
- (void)openFlashlight;
 
- (void)closeFlashlight;

@end
