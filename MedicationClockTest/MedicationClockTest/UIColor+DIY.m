//
//  UIColor+DIY.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/26.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "UIColor+DIY.h"

@implementation UIColor(DIY)

+ (UIColor *)navigationBarColor{
    UIColor * color = [UIColor colorWithRed:0x85/255.0f green:0xBA/255.0f blue:0xFF/255.0f alpha:1.0f];
    return color;
}
+ (UIColor *)bgColor{
    UIColor * color = [UIColor colorWithRed:0x85/255.0f green:0xBA/255.0f blue:0xFF/255.0f alpha:1.0f];
    //    UIColor * color = [self colorWithHexString:@"85BAFF" alpha:1.0];
    return color;
}
+ (UIColor *)myBgColor{
//    UIColor * color = [self colorWithHexString:@"4DB0FF" alpha:1.0];
    UIColor * color = [UIColor colorWithRed:0x4D/255.0f green:0xB0/255.0f blue:0xFF/255.0f alpha:1.0f];
    return color;
}
+ (UIColor *)btnBlueColor{
    UIColor * color = [UIColor colorWithRed:0x47/255.0f green:0x85/255.0f blue:0xFF/255.0f alpha:1.0f];
    return color;
}
+ (UIColor *)btnBlueColorPressed{
    UIColor * color = [UIColor colorWithRed:0x58/255.0f green:0x9A/255.0f blue:0xFF/255.0f alpha:1.0f];
    return color;
}
+ (UIColor*)segmentedBlueColor{
    UIColor * color = [UIColor colorWithRed:49.0/256.0 green:148.0/256.0 blue:208.0/256.0 alpha:1];
    return color;
}

+ (UIColor *)r:(int)r g:(int)g b:(int)b{
    UIColor * color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
    return color;
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6){
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]){
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]){
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6){
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color{
    return [self colorWithHexString:color alpha:1.0f];
}

@end
