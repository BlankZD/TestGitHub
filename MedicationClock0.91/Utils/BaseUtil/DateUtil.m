//
//  DateUtil.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSString*)getStrFromDate:(NSDate*)date{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    //设置自定义的格式
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr=[format stringFromDate:date];
    return dateStr;
}
+ (NSString*)getStrFromDate:(NSDate*)date formatStr:(NSString*)formatStr{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    //设置自定义的格式
    [format setDateFormat:formatStr];
    NSString *dateStr=[format stringFromDate:date];
    return dateStr;
}

+ (NSDate*)getDateFromStr:(NSString*)dateStr{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date =[dateFormat dateFromString:dateStr];
    return date;
}
+ (NSDate*)getDateFromStr:(NSString*)dateStr formatStr:(NSString*)formatStr{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:formatStr];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date =[dateFormat dateFromString:dateStr];
    return date;
}

@end
