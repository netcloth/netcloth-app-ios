//
//  SRRecordingAudioPlayer.m
//  SRAudioRecorderDemo
//
//  Created by SRRecorderTool on 2018/8/2.
//  Copyright © 2018年 SR. All rights reserved.
//

#import "SRRecordingAudioPlayerManager.h"
#import "LRSPlayer.h"

@interface SRRecordingAudioPlayerManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong, readwrite) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, readwrite) LRSPlayer *queuePlayer;

@end

@implementation SRRecordingAudioPlayerManager

+ (instancetype)sharedManager {
    static SRRecordingAudioPlayerManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(self) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // init setting
    }
    return self;
}

//MARK:- PCM

- (void)playData:(NSData *)pcm  withBlock:(callBack)back
{
    if (self.queuePlayer) {
        [self.queuePlayer stop];
        self.queuePlayer = nil;
    }
    
    [self setupAudio];
    self.call = back;
    if (!self.queuePlayer) {
        self.queuePlayer = [[LRSPlayer alloc] initWithFrequency:11025 bitsForSingleChannel:16 channelCount:1];
    }
    __weak typeof(self) weakSelf = self;
    self.queuePlayer.call = ^(BOOL success, NSString *msg) {
        if (weakSelf.call) {
            weakSelf.call(success, msg);
            weakSelf.call = nil;
        }
    };
    
    [self.queuePlayer inputPCMData:pcm];
    [self.queuePlayer play];
}





//MARK:- == Discard


- (AVAudioPlayer *)playerWithFilePath:(NSString *)filePath {
    [self stop];
    [self setupAudio];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    _audioPlayer.delegate = self;
    return _audioPlayer;
}

- (AVAudioPlayer *)playerWithURL:(NSURL *)URL {
    [self stop];
    [self setupAudio];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
    _audioPlayer.delegate = self;
    return _audioPlayer;
}

- (AVAudioPlayer *)playerWithData:(NSData *)data {
    [self stop];
    [self setupAudio];
    
    NSError *err;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&err];
    _audioPlayer.delegate = self;
    return _audioPlayer;
}

- (void)setupAudio {
//    [NSNotificationCenter.defaultCenter removeObserver:self];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioInterrupte:) name:AVAudioSessionInterruptionNotification object:nil];
    NSError *err_1;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&err_1];
    [AVAudioSession.sharedInstance setActive:true error:nil];
}

- (void)play {
    [self _play];
}

- (void)playWithBlock:(callBack)back {
    self.call = back;
    [self _play];
}

- (void)_play {
    if (_audioPlayer == nil) {
        self.call(NO, @"player init error");
        return;
    }
    
    [AVAudioSession.sharedInstance setActive:YES error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)pause {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
    }
}

- (void)stop {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    if (self.queuePlayer) {
        [self.queuePlayer stop];
        self.queuePlayer = nil;
    }
    
    if (self.call != nil){
        self.call(NO,@"stop");
        self.call = nil;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

//MARK:- Observer
- (void)audioInterrupte:(NSNotification *)notice {
    if (_audioPlayer == nil) {
        return;
    }
    NSDictionary *userInfo = notice.userInfo;
    if (userInfo == nil) {
        return;
    }
    NSInteger interruptionType = [userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"中断开始 userInfo: %@",userInfo);
    }
    else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        if (_audioPlayer.isPlaying == NO) {
            [self _play];
        }
    }
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying");
    if (self.call) {
        self.call(YES, @"play finish");
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"audioPlayerDecodeErrorDidOccur error: %@", error);
    if (self.call) {
        self.call(NO, @"decode error");
    }
}

@end
