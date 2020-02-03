  
  
  
  
  
  
  

#import <UIKit/UIKit.h>

@interface WCQRCodeVC : UIViewController

@property (nonatomic, copy) void (^callBack)(NSString *publicKey);

@end
