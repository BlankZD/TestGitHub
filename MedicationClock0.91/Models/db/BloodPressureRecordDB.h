//
//  BloodPressureRecordDB.h
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 表名以及表子段常量
 */
#define  DB_blood_pressure_record @"blood_pressure_record"

#define DB_BPR_systolic_pressure @"systolic_pressure"               //收缩压
#define DB_BPR_diastolic_pressure @"diastolic_pressure"             //舒张压
#define DB_BPR_heart_rate @"heart_rate"                             //心率
#define DB_BPR_remarks @"remarks"                                   //备注
#define DB_BPR_record_date @"record_date"                           //记录日期
#define DB_BPR_record_time @"record_time"                           //记录时间
#define DB_BPR_state @"state"                                       //同步标记

#define SQL_CREATE_blood_pressure_record [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@, %@, %@  );",DB_blood_pressure_record,DB_BPR_systolic_pressure,DB_BPR_diastolic_pressure,DB_BPR_heart_rate,DB_BPR_remarks,DB_BPR_record_date,DB_BPR_record_time,DB_BPR_state]


@interface BloodPressureRecordDB : NSObject

+(BloodPressureRecordDB *)getInstance;
/*
//数据库表名
public static final String TABLE_NAME = "blood_pressure_record";
//数据库字段名
public static final String SYSTOLIC_PRESSURE = "systolic_pressure";		//收缩压
public static final String DIASTOLIC_PRESSURE = "diastolic_pressure";	//舒张压
public static final String HEART_RATE = "heart_rate";				//心率
public static final String REMARKS = "remarks";						//备注
public static final String RECORD_DATE = "record_date";			//记录日期
public static final String RECORD_TIME = "record_time";			//记录时间
public static final String UPLOAD_STATE = "state";					//同步标记
//数据库创建表的sql语句
public static final String TABLE_CREATE = "create table "+TABLE_NAME+" (_id integer primary key autoincrement,"
+SYSTOLIC_PRESSURE+","+DIASTOLIC_PRESSURE+","+HEART_RATE+","+REMARKS+","+RECORD_DATE+","+RECORD_TIME+","+UPLOAD_STATE+")";
*/
//增
-(void) insert:(NSDictionary *) param;
-(void) insert_list:(NSMutableArray *) paramList;//insert

//改
-(void) setRecentChat:(NSString* )chatContent chatTime:(NSString *) chatTime unread_count:(NSString* )unread_count user_id:(NSString*) user_id;
                                                                                                                            
                                                                                                                            
-(void) setUploaded:(NSString *) record_id;
-(void) setUploaded_list:(NSMutableArray *)list;//setUploaded
//查
-(NSMutableArray *) queryByDateStr:(NSString *)  dateStr;
-(BOOL) queryStateByDateStr:(NSString *) dateStr;
-(NSMutableArray *) queryRecently;
/**
 * 按状态查询最近记录
 * @param type		0表示查询最近一周记录，1表示查询最近一月记录，2表示查询最近一年记录
 * @return
 */
-(NSMutableDictionary *)queryRecent:(int) type;
-(NSMutableDictionary *) queryLast;
-(NSMutableDictionary *) queryTestParam;
/**
 * 查询血压记录
 * @return
 */
-(NSMutableArray *)  queryUpload;

-(NSMutableArray *)  queryAll;
-(NSMutableArray *)  queryAll:(int) codeIndex;

-(BOOL)  exists:(NSString *)_id;
-(long) getCount;


-(void)deleteAll;

@end
