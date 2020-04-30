







#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTableDelegateContainer : NSObject <UITableViewDelegate, UITableViewDataSource>

- (void)addDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
