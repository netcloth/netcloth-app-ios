







#import <UIKit/UIKit.h>
#import <swift_cli/swift_cli.h>

@class SRAudioRecordButton;

typedef void (^RecordButtonTouchDown)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchUpOutside)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchUpInside)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchDragEnter)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchDragInside)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchDragOutside)(SRAudioRecordButton *recordButton);
typedef void (^RecordButtonTouchDragExit)(SRAudioRecordButton *recordButton);

@interface SRAudioRecordButton : UIButton

@property (nonatomic, copy) RecordButtonTouchDown        recordButtonTouchDownBlock;
@property (nonatomic, copy) RecordButtonTouchUpInside    recordButtonTouchUpInsideBlock;
@property (nonatomic, copy) RecordButtonTouchUpOutside   recordButtonTouchUpOutsideBlock;
@property (nonatomic, copy) RecordButtonTouchDragEnter   recordButtonTouchDragEnterBlock;
@property (nonatomic, copy) RecordButtonTouchDragInside  recordButtonTouchDragInsideBlock;
@property (nonatomic, copy) RecordButtonTouchDragOutside recordButtonTouchDragOutsideBlock;
@property (nonatomic, copy) RecordButtonTouchDragExit    recordButtonTouchDragExitBlock;

@end
