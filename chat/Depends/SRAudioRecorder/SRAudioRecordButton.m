  
  
  
  
  
  
  

#import "SRAudioRecordButton.h"
#import "SRAudioRecorderManager.h"
#import <YYKit/YYKit.h>

@interface SRAudioRecordButton ()
@end

@implementation SRAudioRecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(touchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(touchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(touchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRecorderManagerDidFinishRecording) name:SRAudioRecorderManagerDidFinishRecordingNotification object:nil];
}

- (void)setButtonStateNormal {
    if (self.currentTitle) {
        [self setTitle:NSLocalizedString(@"Hold to Talk", nil) forState:UIControlStateNormal];
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setButtonStateRecording {
    if (self.currentTitle) {
        [self setTitle:NSLocalizedString(@"Release to Send", nil) forState:UIControlStateNormal];
        self.backgroundColor = [UIColor colorWithHexString:@"#EDEFF2"];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = CGRectInset(self.bounds, 0, 10);
    return CGRectContainsPoint(rect, point);
}

#pragma mark -- Actions

- (void)dealloc
{
    NSLog(@"dealloc %@",self.className);
}

  
- (void)touchDown {
    if (self.recordButtonTouchDownBlock) {
        self.recordButtonTouchDownBlock(self);
    }
    
      
    [[SRAudioRecorderManager sharedManager] startRecording:^(BOOL grand) {
        if (grand && self.isTracking) {
            [self setButtonStateRecording];
            [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateRecording;
        }
        else {
            [self _onTouchLeaveStop];
        }
    }];
}

- (void)_onTouchLeaveStop{
    [self setButtonStateNormal];
    [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateNormal;
    [[SRAudioRecorderManager sharedManager] stopRecording];
}

  
- (void)touchUpInside {
    if ([SRAudioRecorderManager sharedManager].audioRecorderState == SRAudioRecorderStateNormal) {
        return;
    }
    if (self.recordButtonTouchUpInsideBlock) {
        self.recordButtonTouchUpInsideBlock(self);
    }
    [self setButtonStateNormal];
    if ([SRAudioRecorderManager sharedManager].recordingDuration < [SRAudioRecorderManager sharedManager].minDuration) {
        [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateDurationTooShort;
    } else {
        [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateNormal;
    }
    [[SRAudioRecorderManager sharedManager] stopRecording];
}

  
- (void)touchUpOutside {
    if ([SRAudioRecorderManager sharedManager].audioRecorderState == SRAudioRecorderStateNormal) {
        return;
    }
    if (self.recordButtonTouchUpOutsideBlock) {
        self.recordButtonTouchUpOutsideBlock(self);
    }
    [self setButtonStateNormal];
    [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateCancel;
    [[SRAudioRecorderManager sharedManager] stopRecording];
}

- (void)touchDragInside {
    if (self.recordButtonTouchDragInsideBlock) {
        self.recordButtonTouchDragInsideBlock(self);
    }
}

- (void)touchDragOutside {
    if (self.recordButtonTouchDragOutsideBlock) {
        self.recordButtonTouchDragOutsideBlock(self);
    }
}

  
- (void)touchDragEnter {
    if ([SRAudioRecorderManager sharedManager].audioRecorderState == SRAudioRecorderStateNormal) {
        return;
    }
    if (self.recordButtonTouchDragEnterBlock) {
        self.recordButtonTouchDragEnterBlock(self);
    }
    
    if ([SRAudioRecorderManager sharedManager].recordingDuration >= ([SRAudioRecorderManager sharedManager].maxDuration - [SRAudioRecorderManager sharedManager].showCountdownPoint)) {
        [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateCountdown;
    } else {
        [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateRecording;
    }
}

  
- (void)touchDragExit {
    if ([SRAudioRecorderManager sharedManager].audioRecorderState == SRAudioRecorderStateNormal) {
        return;
    }
    if (self.recordButtonTouchDragExitBlock) {
        self.recordButtonTouchDragExitBlock(self);
    }
    [SRAudioRecorderManager sharedManager].audioRecorderState = SRAudioRecorderStateReleaseToCancel;
}

- (void)audioRecorderManagerDidFinishRecording {
    [self setButtonStateNormal];
}

@end
