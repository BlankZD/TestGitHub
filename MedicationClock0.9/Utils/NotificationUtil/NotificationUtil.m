//
//  NotificationUtil.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/25.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "NotificationUtil.h"
#import "DateUtil.h"

@implementation NotificationUtil

+(void)testNotification{
    NSDate *now=[NSDate new];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    [self setEveryDayAlarmWithDate:[now dateByAddingTimeInterval:10] userInfo:infoDict];//10秒后通知
}
+(void)setEveryDayAlarmWithDate:(NSDate*)date userInfo:(NSDictionary*)infoDict{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        notification.fireDate=date;//设置第一次通知时间
        notification.repeatInterval=NSCalendarUnitDay;//设置循环次数，kCFCalendarUnitWeekday一周一次，0表示不循环
        //        notification.repeatCalendar
        notification.timeZone=[NSTimeZone defaultTimeZone];     //通知弹出时间是否根据时区改变
        notification.applicationIconBadgeNumber=[[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1; //应用的红色数字
        notification.soundName= @"alarm.mp3";//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody=@"通知内容";//提示信息 弹出提示框
        //        notification.alertAction = @"锁屏时显示的内容";  // 锁屏后提示文字，一般来说，都会设置与alertBody一样
        notification.alertAction=NSLocalizedString(@"锁屏时显示的内容", nil);   //NSLocalizedString用于支持国际化
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        notification.category = @"alert";
        notification.userInfo = infoDict; //添加额外的信息
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}
+(void)setOnceAlarmWithDate:(NSDate*)date userInfo:(NSDictionary*)infoDict{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        notification.fireDate=date;//设置第一次通知时间
        notification.repeatInterval=0;//设置循环次数，kCFCalendarUnitWeekday一周一次，0表示不循环
        //        notification.repeatCalendar
        notification.timeZone=[NSTimeZone defaultTimeZone];     //通知弹出时间是否根据时区改变
        notification.applicationIconBadgeNumber=[[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1; //应用的红色数字
        notification.soundName= @"alarm.mp3";//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody=@"通知内容";//提示信息 弹出提示框
        //        notification.alertAction = @"锁屏时显示的内容";  // 锁屏后提示文字，一般来说，都会设置与alertBody一样
        notification.alertAction=NSLocalizedString(@"锁屏时显示的内容", nil);   //NSLocalizedString用于支持国际化
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        notification.category = @"alert";
        notification.userInfo = infoDict; //添加额外的信息
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}
+(void)setNotificationWithTimeStr:(NSString*)timeStr{
    NSLog(@"setNotificationWithTimeStr=%@",timeStr);
    NSDate *date=[DateUtil getDateFromStr:timeStr formatStr:@"HH:mm"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:timeStr forKey:@"alarm_time"];
    [self setEveryDayAlarmWithDate:date userInfo:infoDict];
}

+(void)setExtraNotificationWithTimeStr:(NSString*)timeStr{
    NSLog(@"setExtraNotification=%@",timeStr);
    Boolean exist = false;
    // 遍历已有通知
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i=0; i<narry.count; i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        NSDictionary *userInfo = myUILocalNotification.userInfo;
        NSString *type = [userInfo objectForKey:@"type"];
        NSString *temp = [userInfo objectForKey:@"alarm_time"];
        if ([type isEqualToString:@"Extra"] && [temp isEqualToString:timeStr]){
            //如果已有这个加时闹钟了
            exist = true;
            NSLog(@"已有这个加时闹钟了");
        }
    }
    if(!exist){
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:timeStr,@"alarm_time",@"Extra",@"type", nil];
        NSDate *now=[NSDate date];
        [self setOnceAlarmWithDate:[now dateByAddingTimeInterval:300] userInfo:infoDict];
    }
}

//移除一个指定的通知
+(void)cancelNotification:(UILocalNotification*)notification{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}
//根据通知Tag移除一个通知，参考资料：http://zhidao.baidu.com/link?url=7AWzpLdPoUjhQJ0HrLhzQRM1HUB8B3P9K0Xu5OBcZw5T0p-n4SKGppcUS94dai8fjSN1hibuFMe6zVlp9aqXM227nFOZwy7B2yK9w8_amza
+(void)cancelNotificationByTag:(int)notificationTag{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    // 遍历找到对应nfkey和notificationtag的通知
    for (int i=0; i<narry.count; i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        NSDictionary *userInfo = myUILocalNotification.userInfo;
        NSNumber *obj = [userInfo objectForKey:@"nfkey"];
        int mytag=[obj intValue];
        if (mytag==notificationTag){
            // 删除本地通知
            [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            break;
        }
    }
}
//根据闹铃时间移除一个通知
+(void)cancelNotificationByAlarmTime:(NSString*)alarm_time{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    // 遍历找到对应nfkey和notificationtag的通知
    for (int i=0; i<narry.count; i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        NSDictionary *userInfo = myUILocalNotification.userInfo;
        NSString *temp = [userInfo objectForKey:@"alarm_time"];
        if ([temp isEqualToString:alarm_time]){
            // 删除本地通知
            [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            break;
        }
    }
}
//移除加时通知
+(void)cancelExtraNotification:(NSString*)alarm_time{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    // 遍历找到对应nfkey和notificationtag的通知
    for (int i=0; i<narry.count; i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        NSDictionary *userInfo = myUILocalNotification.userInfo;
        NSString *type = [userInfo objectForKey:@"type"];
        NSString *temp = [userInfo objectForKey:@"alarm_time"];
        if ([type isEqualToString:@"Extra"] && [temp isEqualToString:alarm_time]){
            // 删除本地通知
            [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
//            break;
        }
    }
}
//移除该应用上的所有通知
+(void)cancelAllNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+(void)showAllNotification{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    if(narry.count==0){
        NSLog(@"localNotification=nil");
        return;
    }
    // 遍历找到对应nfkey和notificationtag的通知
    for (int i=0; i<narry.count; i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        NSDictionary *userInfo = myUILocalNotification.userInfo;
        NSLog(@"userInfo=%@",userInfo);
    }
}

@end
