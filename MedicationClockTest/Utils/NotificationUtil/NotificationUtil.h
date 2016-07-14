//
//  NotificationUtil.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/25.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationUtil : NSObject

+(void)testNotification;
+(void)setNotificationWithTimeStr:(NSString*)timeStr;
+(void)setEveryDayAlarmWithDate:(NSDate*)date userInfo:(NSDictionary*)infoDict;
+(void)setExtraNotificationWithTimeStr:(NSString*)timeStr;

+(void)cancelNotification:(UILocalNotification*)notification;
+(void)cancelNotificationByAlarmTime:(NSString*)alarm_time;
+(void)cancelExtraNotification;
+(void)cancelAllNotification;

@end
