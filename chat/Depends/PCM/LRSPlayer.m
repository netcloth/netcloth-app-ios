//
//  LRStreamPlayer.m
//  AudioQueueCheck
//
//  Created by CIA on 2017/3/8.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "LRSPlayer.h"
@import AudioToolbox;

static const int kNumberBuffers = 3;                             // 3
//static const int kBuffterSize = 8*1024;                          //8K //60s 一个音频3M

struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[kNumberBuffers];       //
    UInt32                        bufferByteSize;                 // 6
    SInt64                        mCurrentPacket;                 // 7
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
};

@interface LRSPlayer()

@property (nonatomic, strong) NSData *pcmData;

@property (nonatomic, assign) NSInteger pcmLength; //data length
@property (nonatomic, assign) NSInteger readIndex; //read data length

@property (nonatomic, assign) NSInteger buffSize; //buff

@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isDataFinished;

- (void)needPCMDataForQueue:(AudioQueueRef)queueRef
                     buffer:(AudioQueueBufferRef)buffer;

- (int)checkUsedQueueBuffer:(AudioQueueBufferRef) qbuf;

@end


//播放完成 重用buffer
static void HandleOutputBuffer (
                                void                *aqData,
                                AudioQueueRef       inAQ,
                                AudioQueueBufferRef inBuffer
                                ) {
    
    LRSPlayer *player = (__bridge LRSPlayer *)aqData;
    [player checkUsedQueueBuffer:inBuffer];
    [player needPCMDataForQueue:inAQ buffer:inBuffer];
}

@implementation LRSPlayer
{
    struct AQPlayerState playerState;
    NSData *emptyData;
    NSInteger _emptyUseCount;
}

- (void)dealloc {
    [self stop];
}

- (instancetype)initWithFrequency:(int)frequency
             bitsForSingleChannel:(int)bitsForSingleChannel
                     channelCount:(int)channnelCount
{
    self = [super init];
    if (self) {
        
        playerState.mDataFormat.mSampleRate = frequency;
        playerState.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        playerState.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        playerState.mDataFormat.mChannelsPerFrame = channnelCount;
        playerState.mDataFormat.mBitsPerChannel = bitsForSingleChannel;
        
        playerState.mDataFormat.mFramesPerPacket = 1;
        playerState.mDataFormat.mBytesPerFrame =  (playerState.mDataFormat.mBitsPerChannel/8) * playerState.mDataFormat.mChannelsPerFrame;
        playerState.mDataFormat.mBytesPerPacket =  playerState.mDataFormat.mBytesPerFrame;
        
        int status = AudioQueueNewOutput(&playerState.mDataFormat,
                                         HandleOutputBuffer,
                                         (__bridge void *)self,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopCommonModes,
                                         0,
                                         &playerState.mQueue);
        if (status != 0) {
            NSLog(@"Create Audio Queue failed");
            return self;
        }
        self.readIndex = 0;
        int bufferSize = 2 * playerState.mDataFormat.mBytesPerFrame * frequency; //2s buff 时长
        self.buffSize = bufferSize;
        for (int i = 0; i < kNumberBuffers; i += 1) {
            AudioQueueAllocateBuffer(playerState.mQueue, bufferSize,&playerState.mBuffers[i]);
        }
        
        //构造空数据，给buff 播放
        int emlen = bufferSize/10;
        void *emptyDatas = malloc(emlen); //0.2
        memset(emptyDatas, 0, emlen);
        emptyData = [NSData dataWithBytes:emptyDatas length:emlen];
        free(emptyDatas);
    }
    return self;
}


- (void)inputPCMData:(NSData *)bufferData{
    if (bufferData.length == 0) {
        return;
    }
    self.pcmData = bufferData;
    self.pcmLength = bufferData.length;
}


- (BOOL)play{
    
    if (self.buffSize == 0) {
        //error
        [self stop];
        return NO;
    }
    
    self.isDataFinished = NO;
    self.readIndex = 0;
    _emptyUseCount = 0;
    
    if (self.isPaused == NO) {
        //need input data
        for (int i = 0; i < kNumberBuffers; i += 1) {
            HandleOutputBuffer((__bridge void *)self,playerState.mQueue,playerState.mBuffers[i]);
        }
    }
    
    OSStatus status = AudioQueueStart(playerState.mQueue, NULL);
    if (status != 0) {
        NSLog(@"Begin play failed");
        return NO;
    } else {
        self.isPlaying = YES;
        self.isPaused = NO;
        return YES;
    }
}

- (BOOL)stop {
    AudioQueueStop(playerState.mQueue, YES);
    for (int i = 0; i < kNumberBuffers; i += 1) {
        AudioQueueFreeBuffer(playerState.mQueue, playerState.mBuffers[i]);
    }
    AudioQueueDispose(playerState.mQueue, YES);
    self.pcmData = nil;
    self.isDataFinished = YES;
    
    if (self.call) {
        self.call(YES, @"play over");
    }
    
    return YES;
}

- (BOOL)pause{
    if (self.isPlaying == NO) {
        return NO;
    } else {
        OSStatus status = AudioQueuePause(playerState.mQueue);
        if (status != 0) {
            NSLog(@"Pause failed");
            return NO;
        } else {
            self.isPlaying = NO;
            self.isPaused = YES;
            return YES;
        }
    }
}

- (void)dataFinished {
    self.isDataFinished = YES;
}


//MARK:- Helper
- (void)needPCMDataForQueue:(AudioQueueRef)queueRef
                     buffer:(AudioQueueBufferRef)buffer
{
    if (self.pcmData.length <= 0) {
        [self stop];
    }
    else {
        NSInteger read_len = 0;
        if (self.pcmLength  - self.readIndex  >= self.buffSize ) {
            read_len = self.buffSize;
        }
        else if (self.pcmLength - 1 - self.readIndex >= 0) {
            read_len = self.pcmLength - self.readIndex + 1;
        }
        else {
            //read over
            [self enQueueBufferData:emptyData inBuffer:buffer];
            _emptyUseCount++;
            if (_emptyUseCount > kNumberBuffers) {
                NSLog(@"stop over play");
                [self stop];
            }
            return;
        }
        char *p = self.pcmData.bytes;
        NSData *pcmData = [NSData dataWithBytes: p + self.readIndex  length:read_len];
        self.readIndex += read_len;
        [self enQueueBufferData:pcmData inBuffer:buffer];
    }
}


-(void)enQueueBufferData:(NSData *)pcmData
                inBuffer:(AudioQueueBufferRef)buffer
{
    memcpy(buffer->mAudioData, pcmData.bytes, pcmData.length);
    buffer->mAudioDataByteSize = (int)pcmData.length;
    AudioQueueEnqueueBuffer(playerState.mQueue, buffer, 0, NULL);
}

- (int)checkUsedQueueBuffer:(AudioQueueBufferRef) qbuf {
    int index = 0;
    for (int i = 0; i < kNumberBuffers; i ++) {
        if (qbuf == playerState.mBuffers[i]) {
            index = i;
            NSLog(@"正在使用Buff %zi",index);
            break;
        }
    }
    return index;
}


@end
