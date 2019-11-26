







#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^callBack)(BOOL success, NSString *msg);

@interface SRRecordingAudioPlayerManager : NSObject

+ (instancetype)sharedManager;



@property (nonatomic, strong) callBack call;
- (void)playData:(NSData *)pcm  withBlock:(callBack)back;





- (AVAudioPlayer *)playerWithFilePath:(NSString *)filePath;
- (AVAudioPlayer *)playerWithURL:(NSURL *)URL;
- (AVAudioPlayer *)playerWithData:(NSData *)data;

- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;

@end
