







#import "SGQRCodeObtain.h"
#import "SGQRCodeObtainConfigure.h"
#import <Photos/Photos.h>

@interface SGQRCodeObtain () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    
@property (nonatomic, weak) UIViewController *controller;
    
@property (nonatomic, strong) SGQRCodeObtainConfigure *configure;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, copy) SGQRCodeObtainScanResultBlock scanResultBlock;
@property (nonatomic, copy) SGQRCodeObtainScanBrightnessBlock scanBrightnessBlock;
@property (nonatomic, copy) SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock albumDidCancelImagePickerControllerBlock;
@property (nonatomic, copy) SGQRCodeObtainAlbumResultBlock albumResultBlock;
@property (nonatomic, copy) NSString *detectorString;

@end

@implementation SGQRCodeObtain

+ (instancetype)QRCodeObtain {
    return [[self alloc] init];
}

- (void)dealloc {
    if (_configure.openLog == YES) {
        NSLog(@"SGQRCodeObtain - - dealloc");
    }
}

+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size {
    return [self generateQRCodeWithData:data size:size color:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
}
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    NSData *string_data = [data dataUsingEncoding:NSUTF8StringEncoding];

    CIFilter *fileter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [fileter setValue:string_data forKey:@"inputMessage"];
    [fileter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *ciImage = fileter.outputImage;

    CIFilter *color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    [color_filter setValue:ciImage forKey:@"inputImage"];
    [color_filter setValue:[CIColor colorWithCGColor:color.CGColor] forKey:@"inputColor0"];
    [color_filter setValue:[CIColor colorWithCGColor:backgroundColor.CGColor] forKey:@"inputColor1"];

    CIImage *outImage = color_filter.outputImage;
    CGFloat scale = size / outImage.extent.size.width;
    outImage = [outImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
    return [UIImage imageWithCIImage:outImage];
}
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio {
    return [self generateQRCodeWithData:data size:size logoImage:logoImage ratio:ratio logoImageCornerRadius:5 logoImageBorderWidth:5 logoImageBorderColor:[UIColor whiteColor]];
}
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor {
    UIImage *image = [self generateQRCodeWithData:data size:size color:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    if (logoImage == nil) return image;
    if (ratio < 0.0 || ratio > 0.5) {
        ratio = 0.25;
    }
    CGFloat logoImageW = ratio * size;
    CGFloat logoImageH = logoImageW;
    CGFloat logoImageX = 0.5 * (image.size.width - logoImageW);
    CGFloat logoImageY = 0.5 * (image.size.height - logoImageH);
    CGRect logoImageRect = CGRectMake(logoImageX, logoImageY, logoImageW, logoImageH);

    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (logoImageCornerRadius < 0.0 || logoImageCornerRadius > 10) {
        logoImageCornerRadius = 5;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:logoImageRect cornerRadius:logoImageCornerRadius];
    if (logoImageBorderWidth < 0.0 || logoImageBorderWidth > 10) {
        logoImageBorderWidth = 5;
    }
    path.lineWidth = logoImageBorderWidth;
    [logoImageBorderColor setStroke];
    [path stroke];
    [path addClip];
    [logoImage drawInRect:logoImageRect];
    UIImage *QRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return QRCodeImage;
}

- (void)establishQRCodeObtainScanWithController:(UIViewController *)controller configure:(SGQRCodeObtainConfigure *)configure {
    if (controller == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"SGQRCodeObtain 中 establishQRCodeObtainScanWithController:configuration:方法的 controller 参数不能为空" userInfo:nil];
    }
    if (configure == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"SGQRCodeObtain 中 establishQRCodeObtainScanWithController:configure:方法的 configure 参数不能为空" userInfo:nil];
    }
    
    _controller = controller;
    _configure = configure;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    


    if (configure.rectOfInterest.origin.x == 0 && configure.rectOfInterest.origin.y == 0 && configure.rectOfInterest.size.width == 0 && configure.rectOfInterest.size.height == 0) {
    } else {
        metadataOutput.rectOfInterest = configure.rectOfInterest;
    }


    self.captureSession.sessionPreset = configure.sessionPreset;
    

    [_captureSession addOutput:metadataOutput];

    if (configure.sampleBufferDelegate == YES) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [_captureSession addOutput:videoDataOutput];
    }

    [_captureSession addInput:deviceInput];
    

    metadataOutput.metadataObjectTypes = configure.metadataObjectTypes;
    

    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];

    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = controller.view.frame;
    [controller.view.layer insertSublayer:videoPreviewLayer atIndex:0];
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion {
    if (before) {
        before();
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}
- (void)stopRunning {
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *resultString = nil;
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        resultString = [obj stringValue];
        if (resultString && [resultString isKindOfClass:NSString.class] && resultString.length > 0) {
            [self stopRunning];
        }
        dispatch_async(dispatch_get_main_queue(), ^{  
            if (_scanResultBlock) {
                _scanResultBlock(self, resultString);
            }
        });
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_scanBrightnessBlock) {
            _scanBrightnessBlock(self, brightnessValue);
        }
    });
    
    
}

- (void)setBlockWithQRCodeObtainScanResult:(SGQRCodeObtainScanResultBlock)block {
    _scanResultBlock = block;
}
- (void)setBlockWithQRCodeObtainScanBrightness:(SGQRCodeObtainScanBrightnessBlock)block {
    _scanBrightnessBlock = block;
}

- (void)playSoundName:(NSString *)name {

    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (!path) {

        path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil];
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID);
}
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    
}

- (void)establishAuthorizationQRCodeObtainAlbumWithController:(UIViewController *)controller {
    if (controller == nil && _controller == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"SGQRCodeObtain 中 establishAuthorizationQRCodeObtainAlbumWithController: 方法的 controller 参数不能为空" userInfo:nil];
    }
    if (_controller == nil) {
        _controller = controller;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {

        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {

            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    self.isPHAuthorization = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self P_enterImagePickerController];
                    });
                    if (self.configure.openLog == YES) {
                        NSLog(@"用户第一次同意了访问相册权限");
                    }
                } else {
                    if (self.configure.openLog == YES) {
                        NSLog(@"用户第一次拒绝了访问相册权限");
                    }
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            self.isPHAuthorization = YES;
            if (self.configure.openLog == YES) {
                NSLog(@"用户允许访问相册权限");
            }
            [self P_enterImagePickerController];
        } else if (status == PHAuthorizationStatusDenied) {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
            if (app_Name == nil) {
                app_Name = [infoDict objectForKey:@"CFBundleName"];
            }
            
            NSString *messageString = NSLocalizedString(@"Device_photos", nil);
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [_controller presentViewController:alertC animated:YES completion:nil];
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [_controller presentViewController:alertC animated:YES completion:nil];
        }
    }
}

- (void)P_enterImagePickerController {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [_controller presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_controller dismissViewControllerAnimated:YES completion:nil];
    if (_albumDidCancelImagePickerControllerBlock) {
        _albumDidCancelImagePickerControllerBlock(self);
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];

    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count == 0) {
        [_controller dismissViewControllerAnimated:YES completion:^{
            if (self.albumResultBlock) {
                self.albumResultBlock(self, nil);
            }
        }];
        return;
    } else {
        for (int index = 0; index < [features count]; index ++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            if (_configure.openLog == YES) {
                NSLog(@"相册中读取二维码数据信息 - - %@", resultStr);
            }
            self.detectorString = resultStr;
        }
        [_controller dismissViewControllerAnimated:YES completion:^{
            if (self.albumResultBlock) {
                self.albumResultBlock(self, self.detectorString);
            }
        }];
    }
}

- (void)setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:(SGQRCodeObtainAlbumDidCancelImagePickerControllerBlock)block {
    _albumDidCancelImagePickerControllerBlock = block;
}
- (void)setBlockWithQRCodeObtainAlbumResult:(SGQRCodeObtainAlbumResultBlock)block {
    _albumResultBlock = block;
}

- (void)openFlashlight {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [captureDevice unlockForConfiguration];
        }
    }
}
- (void)closeFlashlight {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:nil];
        [captureDevice setTorchMode:AVCaptureTorchModeOff];
        [captureDevice unlockForConfiguration];
    }
}

@end
