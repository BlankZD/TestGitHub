//
//  MedicationRecordDB.h
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBOpenHelper.h"

/*
 表名以及表子段常量
 */
#define  DB_chat_list @"chat_list"

#define DB_CL_user_id @"user_id"                    //
#define DB_CL_username @"username"                  //
#define DB_CL_nickname @"nickname"                  //
#define DB_CL_head_img_mark @"head_img_mark"        //
#define DB_CL_chatContent @"chatContent"            //
#define DB_CL_chatTime @"chatTime"                  //
#define DB_CL_state @"state"                        //
#define DB_CL_unread_count @"unread_count"          //

#define SQL_CREATE_chat_list [NSString stringWithFormat:@"create table CREATE TABLE IF NOT EXISTS %@(ID INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ , %@, %@, %@ );",DB_chat_list,DB_CL_user_id,DB_CL_username,DB_CL_nickname,DB_CL_head_img_mark,DB_CL_chatContent,DB_CL_chatTime,DB_CL_state,DB_CL_unread_count]




/*
 表名以及表子段常量 概要表
 */
#define  DB_medication_record @"medication_record"

#define DB_MR_clock_id @"clock_id"                                  //闹钟id
#define DB_MR_date @"date"                                          //服药日期
#define DB_MR_alarm_times @"alarm_times"                            //闹铃次数
#define DB_MR_medication_state @"medication_state"                  //服药次数
#define DB_MR_record_upload_state @"record_upload_state"            //与服务器同步的状态


#define SQL_CREATE_medication_record [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ );",DB_medication_record,DB_MR_clock_id,DB_MR_date,DB_MR_alarm_times,DB_MR_medication_state,DB_MR_record_upload_state]



/*
 表名以及表子段常量
 */
#define  DB_medication_list @"medication_list"

#define DB_ML_record_id @"record_id"                            //总记录id
#define DB_ML_time @"time"                                      //服药时间
#define DB_ML_details_upload_state @"details_upload_state"      //与服务器同步的状态


#define SQL_CREATE_medication_list [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@);",DB_medication_list,DB_ML_record_id,DB_ML_time,DB_ML_details_upload_state]




@interface MedicationRecordDB : NSObject
+(MedicationRecordDB *)getInstance;
//增
-(void) insertRecordList:(NSMutableArray *) paramList;
/**
 * 根据闹钟id和当天日期
 * 如果该闹钟已存在当天日期的服药概要表，则概要表中服药次数加1，否则插入一条数据到服药概要表
 * 然后插入一条包含具体服药时间的记录到服药详情表
 * @param param
 * 概要表：CLOCK_ID闹钟id，DATE概要表以日期为单位，MEDICATION_STATE服药的次数，ALARM_TIMES总闹铃次数（即应该服药的次数），
 * 详情表：TIME服药的具体时间
 */
-(NSString *) insertByDate:(NSMutableDictionary *) param;
/**
 * 插入一条概要表
 * @param param
 * @return
 */
-(void) insertRecordByDate:(NSMutableDictionary *) param;
/**
 * 直接插入一条服药详情表根据概要表id关联服药概要表
 * @param record_id	服药记录概要表（以日为单位）的id
 * @param time		TIME服药的具体时间
 * @return		如果已服药次数等于应服药次数，返回false；如果已服药次数小于应服药次数，插入一条服药记录详情（以时为单位）并返回true
 */
-(BOOL) insertDetailsByRecordId:(NSString *) record_id :(NSString *) time;

//删
-(void) deleteAll;
-(void) deleteMedicationRecord:(NSString *) clock_id;
//改
-(void) setStateById:(NSString *) _id :(int) state;
-(void) setRecordUploaded:(NSMutableArray *) list;
-(void) setDetailUploaded:(NSMutableArray *)list;
//查

-(NSMutableArray *) queryAllDetail;
-(NSMutableArray *) queryRecordUpload;
-(NSMutableArray *)queryDetailUpload;
-(NSMutableArray *) queryByClockId:(NSString *) clock_id;

/**
    * 根据日期读取服药情况
    * @param date		日期
    * @return		返回值：当天没有服药记录为-1，有服药记录但没有服药为0，有服药记录但不完全服药为1，有服药记录且完全服药为2
    */
-(int) queryByDate:(NSString *) date;
-(NSMutableArray *) queryClockByDate:(NSString *) dateStr;
-(NSMutableDictionary *)queryByClockDate:(NSString *) clock_id date:(NSString *) date;
-(NSMutableArray *) queryRecently:(NSString *) clock_id dates:(NSMutableArray *) dates;
-(NSMutableArray *) queryByPage:(int) codeIndex;
                                                                                                
-(NSMutableArray *)queryByDetailsByRecordId:(NSString *) record_id;
-(NSMutableArray *)queryByDetailsByDateStr:(NSString *) clock_id date_str:(NSString*) date_str;
-(NSMutableDictionary *) queryWeekReport:(NSString *) clock_id date_str:(NSString*)  date_str;
-(NSMutableDictionary *) queryMonthReport:(NSString *) clock_id date_str:(NSString*)  date_str;
-(NSMutableDictionary *)queryYearReport:(NSString *) clock_id date_str:(NSString*)  date_str;
                                                                                                
-(BOOL)exists:(int) _id ;
 -(long)getRecordCount;
-(long)getDetailCount;


@end
