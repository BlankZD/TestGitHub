//
//  AlarmClockDB.h
//  SQLiteDemo
//
//  Created by jam on 16/3/28.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBOpenHelper.h"

/*
 表名以及表子段常量
 */
#define  DB_ALARM_CLOCK @"alarm_clock"

#define DB_AC_TITLE @"title"                //标题
#define DB_AC_CONTENT @"content"            //内容
#define DB_AC_START_DATE @"start_date"      //闹钟开始的日期
#define DB_AC_EXPIREDOSE @"expireDose"      //服药闹钟的药品总计量
#define DB_AC_STATE @"state"                //闹钟状态：1为可用，2为过期 0为删除
#define DB_AC_UPLOAD_STATE @"upload_state"  //与服务器同步状态

#define SQL_CREATE_ALARM_CLOCK [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ ,%@);",DB_ALARM_CLOCK,DB_AC_TITLE,DB_AC_CONTENT,DB_AC_START_DATE,DB_AC_EXPIREDOSE,DB_AC_STATE,DB_AC_UPLOAD_STATE]


#define  DB_ALARM_TIME @"alarm_time"

#define DB_AT_CLOCK_ID @"clock_id"              //闹钟id
#define DB_AT_TIME_STR @"time_str"              //闹钟时间
#define DB_AT_HOUR @"hour"                      //
#define DB_AT_MINUTE @"minute"                  //
#define DB_AT_STATE @"state"                    //闹钟状态：1为可用，2为过期 0为


#define SQL_CREATE_ALARM_TIME [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ );",DB_ALARM_TIME,DB_AT_CLOCK_ID,DB_AT_TIME_STR,DB_AT_HOUR,DB_AT_MINUTE,DB_AT_STATE]



@interface AlarmClockDB : NSObject

+(AlarmClockDB *)getInstance;

- (BOOL) insertClock:(NSMutableDictionary *)clock_param time_list:(NSMutableArray *)time_list;

- (void) insertClock:(NSMutableArray *)clock_list;
-(void)insertOnlineClock:(NSMutableArray *)clock_list;

-(void)deleteAll;
-(void)deleteByClockId:(NSString * )clock_id;

-(void)setClockState:(NSNumber *)_id state:(NSString *)state;

// 设置闹钟过期
-(void)setClockExpire:(NSString *)clock_id;


//下面的未实现
-(BOOL) reduceClockExpireDose:(NSString *)clock_id;

-(BOOL) increaseClockExpireDose:(NSString*) clock_id :(int) quatity;

-(void) setUploaded:(NSMutableArray *) list;

-(NSMutableArray *) queryRecordUpload;

/**
* 根据闹铃时间查询闹钟列表
* @param alarm_time		闹铃时间字符串
* @return
*/
-(NSMutableArray *) queryClockByAlarmTime:(NSString*) alarm_time;

 /**
* 查询闹铃时间下有无药品
* @param alarm_time
* @return	true表示有，false表示没有
*/
-(BOOL) queryExistsByAlarmTime:(NSString *)alarm_time;

//查询单个闹钟
-(NSMutableDictionary *) queryClock:(NSString*) _id;

//查询闹钟表
-(NSMutableArray *)  queryClockList;

 /**
 * @param state		闹钟状态：1为可用，2为过期，0为删除
* @return
*/
-(NSMutableArray *) queryClockListByState:(NSString*) state;

//查询闹铃时间表
-(NSMutableArray *)queryTimeList:(NSString*) clock_id;

//查询闹铃下闹铃时间列表的id
-(NSMutableArray *) queryTimeStrList:(NSString*)  clock_id;
    
-(NSMutableArray *)queryClockTimeList;
    
-(NSMutableArray *)queryTimeListDistinct;
    
-(NSMutableArray *)queryClockTimeIdList;
    
-(long)queryClockTimeCountByClockId:(NSString*) clock_id;



@end
