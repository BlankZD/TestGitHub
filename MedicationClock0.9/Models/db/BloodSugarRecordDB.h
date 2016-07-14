//
//  BloodSugarRecordDB.h
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
#define  DB_blood_sugar_record @"blood_sugar_record"

#define DB_BSR_blood_sugar @"blood_sugar"               //血糖
#define DB_BSR_after_meal @"after_meal"                 //是否饭后
#define DB_BSR_record_date @"record_date"               //记录日期
#define DB_BSR_record_time @"record_time"               //记录时间
#define DB_BSR_state @"state"                           //同步标记


#define SQL_CREATE_blood_sugar_record [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ );",DB_blood_sugar_record,DB_BSR_blood_sugar,DB_BSR_after_meal,DB_BSR_record_date,DB_BSR_record_time,DB_BSR_state]




@interface BloodSugarRecordDB : NSObject

+(BloodSugarRecordDB *)getInstance;
//增
-(void) insert:(NSDictionary *) param;
-(void) insert_list:(NSMutableArray *) list;
//改
-(void) setRecentChat:(NSString* )chatContent chatTime:(NSString *) chatTime unread_count:(NSString* )unread_count user_id:(NSString*) user_id;


-(void) setUploaded:(NSString *) record_id;
-(void) setUploaded_list:(NSMutableArray *)list;//setUploaded
//查
/**
 * 查询血糖记录
 * @return
 */
-(NSMutableArray *)  queryUpload;
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
-(NSMutableArray *)  queryAll;
-(NSMutableArray *)  queryAll:(int) codeIndex;
-(BOOL)  exists:(NSString *)_id;
-(long) getCount;

-(void)deleteAll;

@end
