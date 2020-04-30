//
//  LRStreamPlayer.h
//  AudioQueueCheck
//
//  Created by CIA on 2017/3/8.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRRecordingAudioPlayerManager.h"

//单次生成，每次播放 重新实例化
@interface LRSPlayer : NSObject

- (instancetype)initWithFrequency:(int)frequency
             bitsForSingleChannel:(int)bitsForSingleChannel
                     channelCount:(int)channnelCount;

@property (nonatomic, readonly) BOOL isPlaying;

//单次添加 录音数据
@property (nonatomic, strong) callBack call;
- (void)inputPCMData:(NSData *)pcmDta;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;

- (void)dataFinished;

//self.queuePlayer = [LRStreamPlayer.alloc initWithFrequency:11025 bitsForSingleChannel:16 channelCount:1 singleBufferDuration:10];
//[self.queuePlayer inputPCMData:data];
//[self.queuePlayer play];

//No more data,Call this function will cause the player auto pause when all PCM Data is played

@end
