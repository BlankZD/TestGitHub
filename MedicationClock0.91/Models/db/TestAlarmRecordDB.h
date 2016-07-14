//
//  TestAlarmRecordDB.h
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 表名以及表子段常量
 */
#define  DB_test_alarm_record @"test_alarm_record"

#define DB_TAR_clock_id @"clock_id"          //闹钟id
#define DB_TAR_date @"date"                  //闹铃日期
#define DB_TAR_time @"time"                  //闹铃时间
#define DB_TAR_text @"text"                  //备注


#define SQL_CREATE_test_alarm_record [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@);",DB_test_alarm_record,DB_TAR_clock_id,DB_TAR_date,DB_TAR_time,DB_TAR_text]


@interface TestAlarmRecordDB : NSObject

//增
/**
 * @param param		参数列表：CLOCK_ID闹钟id,DATE闹铃日期,TIME闹铃时间
 */
-(void)insert:(NSMutableDictionary *) param;
//删
-(void)deleteAll;
//查
-(NSMutableArray *)queryAll;
-(NSMutableArray *)queryByClockId:(NSString*) clock_id;
-(BOOL)exists_byID:(int) _id;
-(BOOL)exists:(NSString*) date;


@end
