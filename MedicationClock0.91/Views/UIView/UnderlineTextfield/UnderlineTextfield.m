//
//  UnderlineTextfield.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/2.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "UnderlineTextfield.h"

@implementation UnderlineTextfield

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5));
}

@end
