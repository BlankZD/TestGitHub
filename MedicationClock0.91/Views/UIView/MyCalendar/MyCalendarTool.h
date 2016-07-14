//
//  MyCalendarTool.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/23.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCalendarTool : NSObject

+ (long)getFirstWeekDayInMonth:(NSDate *)date;
+ (long)getNumDaysInMonth:(NSDate *)date;

@end
