  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "SRRecordingAudioPlayerManager.h"

  
@interface LRSPlayer : NSObject

- (instancetype)initWithFrequency:(int)frequency
             bitsForSingleChannel:(int)bitsForSingleChannel
                     channelCount:(int)channnelCount;

@property (nonatomic, readonly) BOOL isPlaying;

  
@property (nonatomic, strong) callBack call;
- (void)inputPCMData:(NSData *)pcmDta;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;

- (void)dataFinished;

  
  
  

  

@end
