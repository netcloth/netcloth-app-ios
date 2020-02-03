  
  
  
  
  
  
  

#import <UIKit/UIKit.h>

@interface LXWaveProgressView : UIView
/**
 *  进度 0-1
 */
@property (nonatomic,assign)CGFloat progress;

/**
 *  波动速度，默认 1
 */
@property (nonatomic,assign)CGFloat speed;

 
@property (nonatomic,strong)UIColor * firstWaveColor;
@property (nonatomic,strong)UIColor * secondWaveColor;

/**
 *  波动幅度，默认 5
 */
@property (nonatomic,assign)CGFloat waveHeight;

 
@property (nonatomic,strong)UILabel * progressLabel;

/**
 *  是否显示单层波浪，默认NO
 */
@property (nonatomic,assign)BOOL isShowSingleWave;
@end
