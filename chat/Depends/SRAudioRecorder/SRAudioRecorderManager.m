







#import "SRAudioRecorderManager.h"
#import "SRAudioRecordToastManager.h"

NSString * const SRAudioRecorderManagerDidFinishRecordingNotification = @"SRAudioRecorderManagerDidFinishRecordingNotification";

@interface SRAudioRecorderManager() <AVAudioRecorderDelegate>

@property (nonatomic, copy) NSString *audioFilePath;
@property (nonatomic, strong, readwrite) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, assign, readwrite) NSTimeInterval recordingDuration;

@end

@implementation SRAudioRecorderManager

+ (instancetype)sharedManager {
    static SRAudioRecorderManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _maxDuration = 60;
        _minDuration = 3;
        _showCountdownPoint = 10;
    }
    return self;
}

- (NSString *)audioFilePath {
    if (!_audioFilePath) {
        NSString *cachesDirectoryth = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _audioFilePath = [cachesDirectoryth stringByAppendingPathComponent:@"sr_audio_recording"];
    }
    return _audioFilePath;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
        setting[AVSampleRateKey] = @(11025);
        setting[AVNumberOfChannelsKey] = @(1);
        setting[AVLinearPCMBitDepthKey] = @(16);
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];
       
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.audioFilePath] settings:setting error:&error];
        if (error) {
            NSLog(@"AVAudioRecorder init error: %@", error);
        }
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
    }
    return _audioRecorder;
}

- (void)startRecording {
    
    [self getAudioAuthorized:^(BOOL grand) {
        if (grand == NO) {
            if ([self.delegate respondsToSelector:@selector(audioRecorderManagerAVAuthorizationStatusDenied)]) {
                [self.delegate audioRecorderManagerAVAuthorizationStatusDenied];
            }
            return;
        }
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.audioRecorder record];
        [self startRecordingTimer];
    }];
}

- (void)stopRecording {
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
        if (self.recordingDuration < self.minDuration ||
            self.audioRecorderState == SRAudioRecorderStateCancel) {
            
            if ([self.audioRecorder deleteRecording]) {
                NSLog(@"deleteRecording");
            }
        }
        [self stopRecordingTimer];
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)startRecordingTimer {
    if (_recordingTimer) {
        [_recordingTimer invalidate];
        _recordingTimer = nil;
    }
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(recordingTimerAction:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopRecordingTimer {
    if (_recordingTimer) {
        [_recordingTimer invalidate];
        _recordingTimer = nil;
    }
}

- (void)recordingTimerAction:(NSTimer *)timer {
    self.recordingDuration += timer.timeInterval;
    NSLog(@"duration %f", self.recordingDuration);
    if (self.maxDuration - self.recordingDuration == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SRAudioRecorderManagerDidFinishRecordingNotification object:nil];
        [self stopRecording];
        [self stopRecordingTimer];
        self.audioRecorderState = SRAudioRecorderStateNormal;
    }
    else if ([self shouldShowCountdown]) {
        self.audioRecorderState = SRAudioRecorderStateCountdown;
    }
    else {
        [self.audioRecorder updateMeters];
        float averagePower = [self.audioRecorder averagePowerForChannel:0];
        float level = (1.0 / 60.0) * (averagePower + 60.0);
        [[SRAudioRecordToastManager sharedManager] updateAudioPower:level];
    }
}

- (BOOL)shouldShowCountdown {
    if (self.audioRecorderState == SRAudioRecorderStateReleaseToCancel) {
        return NO;
    }
    if (self.recordingDuration >= (self.maxDuration - self.showCountdownPoint)) {
        return YES;
    }
    return NO;
}


- (void)getAudioAuthorized:(void(^)(BOOL grand))back {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (back) {
                        back(YES);
                    }
                } else {
                    if (back) {
                        back(NO);
                    }
                }
            });
        }];
    }
    else if (status == AVAuthorizationStatusAuthorized) {
        if (back) {
            back(YES);
        }
    }
    else {
        if (back) {
            back(NO);
        }
    }
}

- (void)setAudioRecorderState:(SRAudioRecorderState)audioRecorderState {
    _audioRecorderState = audioRecorderState;
    
    [[SRAudioRecordToastManager sharedManager] updateUIWithRecorderState:audioRecorderState];
    
    if (audioRecorderState == SRAudioRecorderStateCountdown) {
        [[SRAudioRecordToastManager sharedManager] showCountdown:self.maxDuration - self.recordingDuration];
    } else if (audioRecorderState == SRAudioRecorderStateDurationTooShort) {
        [[SRAudioRecordToastManager sharedManager] showToastTips:NSLocalizedString(@"Message too short", nil)];
    }
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioFilePath]) {
            if ([self.delegate respondsToSelector:@selector(audioRecorderManagerDidFinishRecordingSuccess:)]) {
                [self.delegate audioRecorderManagerDidFinishRecordingSuccess:self.audioFilePath];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(audioRecorderManagerDidFinishRecordingFailed)]) {
            [self.delegate audioRecorderManagerDidFinishRecordingFailed];
        }
    }
    self.recordingDuration = 0;
}

@end
