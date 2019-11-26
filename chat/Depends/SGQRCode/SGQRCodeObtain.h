







#import <UIKit/UIKit.h>
@class SGQRCodeObtainConfigure, SGQRCodeObtain;

typedef void(^SGQRCodeObtainScanResultBlock)(SGQRCodeObtain *obtain, NSString *result);
typedef void(^SGQRCodeObtainScanBrightnessBlock)(SGQRCodeObtain *obtain, CGFloat brightness);
typedef void(^SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock)(SGQRCodeObtain *obtain);
typedef void(^SGQRCodeObtainAlbumResultBlock)(SGQRCodeObtain *obtain, NSString *result);

@interface SGQRCodeObtain : NSObject

+ (instancetype)QRCodeObtain;

+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size;
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio;
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor;


- (void)establishQRCodeObtainScanWithController:(UIViewController *)controller configure:(SGQRCodeObtainConfigure *)configure;

- (void)setBlockWithQRCodeObtainScanResult:(SGQRCodeObtainScanResultBlock)block;

- (void)setBlockWithQRCodeObtainScanBrightness:(SGQRCodeObtainScanBrightnessBlock)block;

- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion;

- (void)stopRunning;


- (void)playSoundName:(NSString *)name;


- (void)establishAuthorizationQRCodeObtainAlbumWithController:(UIViewController *)controller;

@property (nonatomic, assign) BOOL isPHAuthorization;

- (void)setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:(SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock)block;

- (void)setBlockWithQRCodeObtainAlbumResult:(SGQRCodeObtainAlbumResultBlock)block;


- (void)openFlashlight;

- (void)closeFlashlight;

@end
