//
//  BloodPressureDB.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodPressureDB.h"
#import "DateUtil.h"
#import "AppConfig.h"
#import "sqlite3.h"

#define TableName @"blood_pressure_record"

@implementation BloodPressureDB

+(void)createTable:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return;
    }
    sqlite3 *database = [dbDriver getDatabase];
    //创建表
    char *errmsg;
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@, %@, %@  );", TableName, SYSTOLIC_PRESSURE,DIASTOLIC_PRESSURE, HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE];
    if (sqlite3_exec(database, [createTableSQL UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert1(0, @"未能创建表：%s", errmsg);
        sqlite3_free(errmsg);
    }
}


#pragma 增

+(NSString*)insert:(BaseDB*)dbDriver dic:(NSDictionary*)dic{
    if(dbDriver==nil){
        return @"数据库对象不能为空";
    }
    @try {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@','%@')", TableName, SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, [dic objectForKey:SYSTOLIC_PRESSURE], [dic objectForKey:DIASTOLIC_PRESSURE], [dic objectForKey:HEART_RATE], [dic objectForKey:REMARKS], [dic objectForKey:RECORD_DATE], [dic objectForKey:RECORD_TIME], @"1"];
        [dbDriver execSQl:insertSQL];
        return @"true";
    } @catch (NSException *exception) {
        return [exception description];
    }
}

+(void)insert:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSDictionary *dic in arr){
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@','%@')", TableName, SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, [dic objectForKey:SYSTOLIC_PRESSURE], [dic objectForKey:DIASTOLIC_PRESSURE], [dic objectForKey:HEART_RATE], [dic objectForKey:REMARKS], [dic objectForKey:RECORD_DATE], [dic objectForKey:RECORD_TIME], @"1"];
        [dbDriver execSQl:insertSQL];
    }
}


#pragma 改

+(void)setUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSString *_id in arr){
        NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='2' where _id='%@'", TableName, UPLOAD_STATE, _id];
        [dbDriver execSQl:updateSQL];
    }
}


#pragma 查

+(NSMutableSet*)queryState:(BaseDB*)dbDriver byYearMonthStr:(NSString*)ymStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableSet *res = [[NSMutableSet alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ where %@  like '%@%%';", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName, RECORD_DATE, ymStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
            
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
            
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:heart_rate forKey:HEART_RATE];
            
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            
            if([AppConfig isSystolicPressureRegular:systolic_pressure]
               && [AppConfig isDiastolicPressureRegular:diastolic_pressure]
               && [AppConfig isHeartRateRegular:heart_rate]){
                //如果收缩压舒张压和心率都正常，则表示数据状态为正常
            }else{
                //否则不正常
                [res addObject:record_date];
            }
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSMutableArray*)query:(BaseDB*)dbDriver byDateStr:(NSString *)dateStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ where %@='%@';", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName, RECORD_DATE, dateStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            int _id = sqlite3_column_int(statement, 0);
            [dic setValue:[NSString stringWithFormat:@"%d",_id] forKey:@"_id"];
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:heart_rate forKey:HEART_RATE];
            NSString *remarks = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:remarks forKey:REMARKS];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *record_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:record_time forKey:RECORD_TIME];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSArray*)queryUpload:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ where %@='0';", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName, UPLOAD_STATE];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            int _id = sqlite3_column_int(statement, 0);
            [dic setValue:[NSString stringWithFormat:@"%d",_id] forKey:@"_id"];
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:heart_rate forKey:HEART_RATE];
            NSString *remarks = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:remarks forKey:REMARKS];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *record_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:record_time forKey:RECORD_TIME];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSMutableDictionary*)queryLast:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableDictionary *res = [[NSMutableDictionary alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ order by _id desc limit 0,1", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE, HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            int _id = sqlite3_column_int(statement, 0);
            [res setValue:[NSString stringWithFormat:@"%d",_id] forKey:@"_id"];
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [res setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [res setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [res setValue:heart_rate forKey:HEART_RATE];
            NSString *remarks = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [res setValue:remarks forKey:REMARKS];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [res setValue:record_date forKey:RECORD_DATE];
            NSString *record_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [res setValue:record_time forKey:RECORD_TIME];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            [res setValue:upload_state forKey:UPLOAD_STATE];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSMutableDictionary*)queryTestTimes:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableDictionary *res = [[NSMutableDictionary alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@,%@ from %@", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE, HEART_RATE, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        int record_times=0, normal_times=0, abnormal_times=0;
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            if([AppConfig isSystolicPressureRegular:systolic_pressure]
               && [AppConfig isDiastolicPressureRegular:diastolic_pressure]
               && [AppConfig isHeartRateRegular:heart_rate]){
                //如果收缩压舒张压和心率都正常，则表示数据状态为正常
                normal_times++;
            }else{
                abnormal_times++;
            }
            record_times++;
        }
        //NSMutableDictionary 存放的都是对象,所以在存放整形时,需要把 int 转为NSNumber对象,这里使用@()语法糖
        [res setObject:@(normal_times) forKey:@"normal_times"];
        [res setObject:@(abnormal_times) forKey:@"abnormal_times"];
        [res setObject:@(record_times) forKey:@"record_times"];
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(int)getCount:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return 0;
    }
    sqlite3 *database = [dbDriver getDatabase];
    int count = -1;
    NSString *selectSQL = [NSString stringWithFormat:@"select count(*) as count from %@", TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW){
            count = (int)sqlite3_column_int(statement, 0);
        }
    }
    return count;
}

+(NSDictionary*)queryRecent:(BaseDB*)dbDriver type:(int)type{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    if(type==0){
        [comps setWeekOfYear:-1];
    }else if(type==1){
        [comps setMonth:-1];
    }else if(type==2){
        [comps setYear:-1];
    }
    NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    NSString *date_str = [DateUtil getStrFromDate:date formatStr:@"yyyy-MM-dd"];
    NSString *now_date_str = [DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyy-MM-dd"];
    
    NSMutableDictionary *res = [[NSMutableDictionary alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@,%@ from %@ where %@ between '%@' and '%@'", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE, HEART_RATE, TableName, RECORD_DATE, date_str, now_date_str];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        float systolic_pressure_total = 0.0f;		//收缩压总量
        float diastolic_pressure_total = 0.0f;		//舒张压总量
        int heart_rate_total = 0;					//心率总量
        int measure_times = 0;						//测量次数
        int systolic_pressure_hypertension_times = 0;			//收缩压高血压次数
        int systolic_pressure_hypotension_times = 0;			//收缩压低血压次数
        int diastolic_pressure_hypertension_times = 0;			//舒张压高血压次数
        int diastolic_pressure_hypotension_times = 0;		//舒张压低血压次数
        int heart_rate_elevated_times = 0;				//心率过高次数
        int heart_rate_hypopiesia_times = 0;			//心率过低次数
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            systolic_pressure_total += [systolic_pressure floatValue];
            diastolic_pressure_total += [diastolic_pressure floatValue];
            heart_rate_total += [heart_rate floatValue];
            if([AppConfig isElevatedSystolicPressure:systolic_pressure]){
                systolic_pressure_hypertension_times++;//收缩压高血压次数+1
            }else if([AppConfig isHypopiesiaSystolicPressure:systolic_pressure]){
                systolic_pressure_hypotension_times++;//收缩压低血压次数+1
            }
            if([AppConfig isElevatedDiastolicPressure:diastolic_pressure]){
                diastolic_pressure_hypertension_times++;//舒张压高血压次数+1
            }else if([AppConfig isHypopiesiaDiastolicPressure:diastolic_pressure]){
                diastolic_pressure_hypotension_times++;//舒张压低血压次数+1
            }
            measure_times++;
        }
        int systolic_pressure_average = 0;		//平均收缩压
        int diastolic_pressure_average = 0;		//平均舒张压
        if(measure_times!=0){
            systolic_pressure_average = (int) (systolic_pressure_total / measure_times);
            diastolic_pressure_average = (int) (diastolic_pressure_total / measure_times);
        }
        //NSMutableDictionary 存放的都是对象,所以在存放整形时,需要把 int 转为NSNumber对象,这里使用@()语法糖
        [res setObject:@(systolic_pressure_average) forKey:@"systolic_pressure_average"];//收缩压平均值
        [res setObject:@(diastolic_pressure_average) forKey:@"diastolic_pressure_average"];//舒张压平均值
        [res setObject:@(systolic_pressure_hypertension_times) forKey:@"systolic_pressure_hypertension_times"];//收缩压高血压次数
        [res setObject:@(systolic_pressure_hypotension_times) forKey:@"systolic_pressure_hypotension_times"];//收缩压低血压次数
        [res setObject:@(diastolic_pressure_hypertension_times) forKey:@"diastolic_pressure_hypertension_times"];//舒张压高血压次数
        [res setObject:@(diastolic_pressure_hypotension_times) forKey:@"diastolic_pressure_hypotension_times"];//舒张压低血压次数
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSMutableArray*)queryRecently:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ order by _id DESC limit 0,7", SYSTOLIC_PRESSURE, DIASTOLIC_PRESSURE,HEART_RATE, REMARKS, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            int _id = sqlite3_column_int(statement, 0);
            [dic setValue:[NSString stringWithFormat:@"%d",_id] forKey:@"_id"];
            NSString *systolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
            NSString *diastolic_pressure = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
            NSString *heart_rate = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:heart_rate forKey:HEART_RATE];
            NSString *remarks = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:remarks forKey:REMARKS];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *record_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:record_time forKey:RECORD_TIME];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

@end
