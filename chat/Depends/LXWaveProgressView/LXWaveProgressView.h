







#import <UIKit/UIKit.h>

@interface LXWaveProgressView : UIView
@property (nonatomic,assign)CGFloat progress;

@property (nonatomic,assign)CGFloat speed;

@property (nonatomic,strong)UIColor * firstWaveColor;
@property (nonatomic,strong)UIColor * secondWaveColor;

@property (nonatomic,assign)CGFloat waveHeight;

@property (nonatomic,strong)UILabel * progressLabel;

@property (nonatomic,assign)BOOL isShowSingleWave;
@end
