







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

- (void)startRecording:(void(^)(BOOL grand))recordBack;
- (void)stopRecording;

@property (nonatomic, weak) id<SRAudioRecorderManagerDelegate> delegate;

@property (nonatomic, assign) SRAudioRecorderState audioRecorderState;

@property (nonatomic, assign, readonly) NSTimeInterval recordingDuration;

@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

/**
 The maximum duration of recoding audio, default is 60s.
 */
@property (nonatomic, assign) NSTimeInterval maxDuration;

/**
 The minimum duration of recoding audio, default is 3s.
 */
@property (nonatomic, assign) NSTimeInterval minDuration;

/**
 The point to show countdown, default is 10s.
 */
@property (nonatomic, assign) NSTimeInterval showCountdownPoint;

@end
