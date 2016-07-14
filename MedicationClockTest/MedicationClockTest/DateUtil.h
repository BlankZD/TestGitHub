//
//  DateUtil.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSString*)getStrFromDate:(NSDate*)date;
+ (NSString*)getStrFromDate:(NSDate*)date formatStr:(NSString*)formatStr;
+ (NSDate*)getDateFromStr:(NSString*)dateStr;
+ (NSDate*)getDateFromStr:(NSString*)dateStr formatStr:(NSString*)formatStr;

@end
