







#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SGQRCodeObtainConfigure : NSObject

+ (instancetype)QRCodeObtainConfigure;


@property (nonatomic, copy) NSString *sessionPreset;

@property (nonatomic, strong) NSArray *metadataObjectTypes;

@property (nonatomic, assign) CGRect rectOfInterest;

@property (nonatomic, assign) BOOL sampleBufferDelegate;

@property (nonatomic, assign) BOOL openLog;

@end
