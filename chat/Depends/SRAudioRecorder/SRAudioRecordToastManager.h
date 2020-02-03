  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "SRAudioRecorderManager.h"

@interface SRAudioRecordToastManager : NSObject

+ (instancetype)sharedManager;

- (void)updateUIWithRecorderState:(SRAudioRecorderState)state;

- (void)updateAudioPower:(CGFloat)power;

- (void)showCountdown:(CGFloat)countdown;

- (void)showToastTips:(NSString *)msg;

@end
