







#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * const SRAudioRecorderManagerDidFinishRecordingNotification;

typedef NS_ENUM(NSInteger, SRAudioRecorderState) {
    SRAudioRecorderStateNormal,
    SRAudioRecorderStateRecording,
    SRAudioRecorderStateCountdown,
    SRAudioRecorderStateDurationTooShort,
    SRAudioRecorderStateReleaseToCancel,
    SRAudioRecorderStateCancel
};

@protocol SRAudioRecorderManagerDelegate <NSObject>

@optional
- (void)audioRecorderManagerAVAuthorizationStatusDenied;
- (void)audioRecorderManagerDidFinishRecordingSuccess:(NSString *)audioFilePath;
- (void)audioRecorderManagerDidFinishRecordingFailed;

@end

@interface SRAudioRecorderManager : NSObject

+ (instancetype)sharedManager;

- (void)startRecording;
- (void)stopRecording;

@property (nonatomic, weak) id<SRAudioRecorderManagerDelegate> delegate;

@property (nonatomic, assign) SRAudioRecorderState audioRecorderState;

@property (nonatomic, assign, readonly) NSTimeInterval recordingDuration;

@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

@property (nonatomic, assign) NSTimeInterval maxDuration;

@property (nonatomic, assign) NSTimeInterval minDuration;

@property (nonatomic, assign) NSTimeInterval showCountdownPoint;

@end
