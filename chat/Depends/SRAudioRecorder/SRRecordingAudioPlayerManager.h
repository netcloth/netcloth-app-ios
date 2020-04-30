//
//  SRRecordingAudioPlayer.h
//  SRAudioRecorderDemo
//
//  Created by SRRecorderTool on 2018/8/2.
//  Copyright © 2018年 SR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^callBack)(BOOL success, NSString *msg);

@interface SRRecordingAudioPlayerManager : NSObject

+ (instancetype)sharedManager;

//MARK:- PCM

@property (nonatomic, strong) callBack call;
- (void)playData:(NSData *)pcm  withBlock:(callBack)back;



//MARK:- Discard

- (AVAudioPlayer *)playerWithFilePath:(NSString *)filePath;
- (AVAudioPlayer *)playerWithURL:(NSURL *)URL;
- (AVAudioPlayer *)playerWithData:(NSData *)data;

- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;

@end
