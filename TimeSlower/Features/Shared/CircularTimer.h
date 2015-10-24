
#import <UIKit/UIKit.h>

@interface CircularTimer : UIView

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius
     circleStrokeColor:(UIColor *)circleStrokeColor
activeCircleStrokeColor:(UIColor *)activeCircleStrokeColor
           initialDate:(NSDate *)initialDate
             finalDate:(NSDate *)finalDate
         startCallback:(void (^)(void))startBlock
           endCallback:(void (^)(void))endBlock;

- (BOOL)isRunning;
- (BOOL)willRun;
- (void)stop;
- (NSTimeInterval)intervalLength;
- (NSTimeInterval)runningElapsedTime;

@end
