//
//  UIColor+DIY.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/26.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(DIY)

+ (UIColor *)navigationBarColor;
+ (UIColor *)bgColor;
+ (UIColor *)myBgColor;
+ (UIColor *)btnBlueColor;
+ (UIColor *)btnBlueColorPressed;
+ (UIColor*)segmentedBlueColor;
+ (UIColor *)r:(int)r g:(int)g b:(int)b;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
