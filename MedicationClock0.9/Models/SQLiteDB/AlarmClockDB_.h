//
//  AlarmClockDB_.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/25.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"

#define CLOCK_TITLE @"title"                //标题
#define CLOCK_CONTENT @"content"            //内容
#define START_DATE @"start_date"      //闹钟开始的日期
#define EXPIRE_DOSE @"expire_dose"      //服药闹钟的药品总计量
#define STATE @"state"                //闹钟状态：1为可用，2为过期 0为删除
#define UPLOAD_STATE @"upload_state"  //与服务器同步状态

#define CLOCK_ID @"clock_id"              //闹钟id
#define TIME_STR @"time_str"              //闹钟时间
#define STATE @"state"                    //闹钟状态：1为可用，2为过期 0为

@interface AlarmClockDB_ : NSObject

+(void)createTable:(BaseDB*)dbDriver;
+(NSString*)insert:(BaseDB*)dbDriver clockDic:(NSDictionary*)dic timeArr:(NSArray*)arr;
+(void)insert:(BaseDB*)dbDriver clockArr:(NSArray*)arr;

+(NSString*)reduceClockExpireDose:(BaseDB*)dbDriver clockId:(NSString *)clock_id;
+(void)setClockExpire:(BaseDB*)dbDriver clockId:(NSString *)clock_id;
+(void)setUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr;

+(NSMutableArray*)query:(BaseDB*)dbDriver byState:(int)state;
+(NSMutableArray*)query:(BaseDB*)dbDriver byAlarmTime:(NSString*)alarmTime;
+(NSMutableArray*)queryTimeList:(BaseDB*)dbDriver clockId:(NSString*)clockId;
+(BOOL)queryExistsByAlarmTime:(BaseDB*)dbDriver alarmTime:(NSString *)alarm_time;
+(NSString*)queryClockTimeCount:(BaseDB*)dbDriver byClockId:(NSString *)clock_id;
+(NSMutableArray*)queryTimeListDistinct:(BaseDB*)dbDriver;
+(NSMutableArray*)getNotificationTime:(BaseDB*)dbDriver;
+(NSArray*)queryUpload:(BaseDB*)dbDriver;

@end
