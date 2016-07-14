//
//  ArcMenuBtn.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ArcMenuBtn.h"

@implementation ArcMenuBtn

/** 重写UIView点击事件的函数 **/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [self.delegate mTouchesBegan:touches withEvent:event];
    }
}
/** 重写UIView滑动事件的函数 **/
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [self.delegate mTouchesMoved:touches withEvent:event];
        NSLog(@"MyButton touchesMoveds");
    }
}

@end
