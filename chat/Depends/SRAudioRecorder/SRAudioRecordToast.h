  
  
  
  
  
  
  

#import <UIKit/UIKit.h>

@interface SRAudioRecordToast : UIView

@end


@interface SRRecordToastRecording : SRAudioRecordToast

- (void)updateAudioPower:(CGFloat)power;

@end


@interface SRRecordToastAudioPower : SRAudioRecordToast

- (void)updatePower:(CGFloat)power;

@end


@interface SRRecordToastReleaseToCancel : SRAudioRecordToast

@end


@interface SRRecordToastCountdown : SRAudioRecordToast

- (void)updateCountdown:(CGFloat)countdown;

@end


@interface SRRecordToastTips : SRAudioRecordToast

- (void)showMessage:(NSString *)msg;

@end
