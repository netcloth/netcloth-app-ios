







#import <UIKit/UIKit.h>


@class SDButton, SDPhotoBrowser;

@protocol SDPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;


- (void)onScanQrCodeInfo:(NSString * _Nullable)result;

@end


@interface SDPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, weak) UIView *sourceImgView; 

@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, weak) id<SDPhotoBrowserDelegate> delegate;

- (void)show;

@end
