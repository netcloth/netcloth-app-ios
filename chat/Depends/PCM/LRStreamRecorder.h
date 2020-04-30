







#import <Foundation/Foundation.h>

typedef void (^PCMDataCallBackBlock)(NSData *pcmData, int numberOfPacket);

@interface LRStreamRecorder : NSObject

-(instancetype) initWithFrequency:(int) frequency
             bitsForSingleChannel:(int)bitsForSingleChannel
                     channelCount:(int) channnelCount
                 callBackDuration:(float)callBackDuration;

@property (nonatomic, readonly) BOOL isRecording;

@property (nonatomic, strong) PCMDataCallBackBlock pcmDataCallBack;

- (BOOL)startRecord;
- (BOOL)pause;

@end
