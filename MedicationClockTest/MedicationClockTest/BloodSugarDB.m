//
//  BloodSugarDB.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodSugarDB.h"
#import "DateUtil.h"
#import "AppConfig.h"
#import "sqlite3.h"

#define TableName @"blood_sugar_record"

@implementation BloodSugarDB

+(void)createTable:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return;
    }
    sqlite3 *database = [dbDriver getDatabase];
    //创建表
    char *errmsg;
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ );", TableName, BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE];
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
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@')", TableName, BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, [dic objectForKey:BLOOD_SUGAR], [dic objectForKey:AFTER_MEAL], [dic objectForKey:RECORD_DATE], [dic objectForKey:RECORD_TIME], @"1"];
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
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@')", TableName, BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, [dic objectForKey:BLOOD_SUGAR], [dic objectForKey:AFTER_MEAL], [dic objectForKey:RECORD_DATE], [dic objectForKey:RECORD_TIME], @"1"];
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
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@ from %@ where %@  like '%@%%';", BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, TableName, RECORD_DATE, ymStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            
            NSString *blood_sugar = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:blood_sugar forKey:BLOOD_SUGAR];
            
            NSString *after_meal = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:after_meal forKey:AFTER_MEAL];
            
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            
            if([AppConfig isHyperglycaemia:blood_sugar after_meals:after_meal]
               || [AppConfig isGlucopenia:blood_sugar]){
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
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ where %@='%@';", BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName, RECORD_DATE, dateStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            char *blood_sugar = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:blood_sugar encoding:NSUTF8StringEncoding] forKey:BLOOD_SUGAR];
            char *after_meal = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:after_meal encoding:NSUTF8StringEncoding] forKey:AFTER_MEAL];
            char *record_date = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:record_date encoding:NSUTF8StringEncoding] forKey:RECORD_DATE];
            char *record_time = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:record_time encoding:NSUTF8StringEncoding] forKey:RECORD_TIME];
            char *upload_state = (char *)sqlite3_column_text(statement, 5);
            [dic setValue:[NSString stringWithCString:upload_state encoding:NSUTF8StringEncoding] forKey:UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+(NSMutableArray*)queryUpload:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ where %@='0';", BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName, UPLOAD_STATE];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            char *blood_sugar = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:blood_sugar encoding:NSUTF8StringEncoding] forKey:BLOOD_SUGAR];
            char *after_meal = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:after_meal encoding:NSUTF8StringEncoding] forKey:AFTER_MEAL];
            char *record_date = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:record_date encoding:NSUTF8StringEncoding] forKey:RECORD_DATE];
            char *record_time = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:record_time encoding:NSUTF8StringEncoding] forKey:RECORD_TIME];
            char *upload_state = (char *)sqlite3_column_text(statement, 5);
            [dic setValue:[NSString stringWithCString:upload_state encoding:NSUTF8StringEncoding] forKey:UPLOAD_STATE];
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
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ order by _id desc limit 0,1", BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [res setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            char *blood_sugar = (char *)sqlite3_column_text(statement, 1);
            [res setValue:[NSString stringWithCString:blood_sugar encoding:NSUTF8StringEncoding] forKey:BLOOD_SUGAR];
            char *after_meal = (char *)sqlite3_column_text(statement, 2);
            [res setValue:[NSString stringWithCString:after_meal encoding:NSUTF8StringEncoding] forKey:AFTER_MEAL];
            char *record_date = (char *)sqlite3_column_text(statement, 3);
            [res setValue:[NSString stringWithCString:record_date encoding:NSUTF8StringEncoding] forKey:RECORD_DATE];
            char *record_time = (char *)sqlite3_column_text(statement, 4);
            [res setValue:[NSString stringWithCString:record_time encoding:NSUTF8StringEncoding] forKey:RECORD_TIME];
            char *upload_state = (char *)sqlite3_column_text(statement, 5);
            [res setValue:[NSString stringWithCString:upload_state encoding:NSUTF8StringEncoding] forKey:UPLOAD_STATE];
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
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@ from %@", BLOOD_SUGAR, AFTER_MEAL, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        int record_times=0, normal_times=0, abnormal_times=0;
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *blood_sugar = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *after_meal = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            if([AppConfig isHyperglycaemia:blood_sugar after_meals:after_meal]
               || [AppConfig isGlucopenia:blood_sugar]){
                //高血糖或低血糖都表示数据状态为不正常
                abnormal_times++;
            }else{
                normal_times++;
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
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@ from %@ where %@ between '%@' and '%@'", BLOOD_SUGAR, AFTER_MEAL, TableName, RECORD_DATE, date_str, now_date_str];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        float blood_sugar_total_after_meal = 0.0f;		//饭后血糖总量
        float blood_sugar_total_before_meal = 0.0f;		//饭前血糖总量
        int blood_sugar_times_after_meal = 0;			//饭后测量次数
        int blood_sugar_times_before_meal = 0;			//饭前测量次数
        int after_meal_times_hyperglycaemia = 0;			//饭后高血糖次数
        int before_meal_times_hyperglycaemia = 0;			//饭前高血糖次数
        int before_meal_times_hypoglycemia = 0;			//饭前低血糖次数
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *blood_sugar = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *after_meal = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            if([@"true" isEqualToString:after_meal]){
                blood_sugar_total_after_meal += [blood_sugar floatValue];
                blood_sugar_times_after_meal++;
                if([AppConfig isHyperglycaemia:blood_sugar after_meals:after_meal]){
                    //饭后高血糖次数+1
                    after_meal_times_hyperglycaemia++;
                }
            }else{
                blood_sugar_total_before_meal += [blood_sugar floatValue];
                blood_sugar_times_before_meal++;
                if([AppConfig isHyperglycaemia:blood_sugar after_meals:after_meal]){
                    //饭前高血糖次数+1
                    before_meal_times_hyperglycaemia++;
                }else if([AppConfig isGlucopenia:blood_sugar]){
                    //饭前低血糖次数+1
                    before_meal_times_hypoglycemia++;
                }
            }
        }
        int blood_sugar_after_meal_average = 0;		//饭后平均血糖
        int blood_sugar_before_meal_average = 0;		//饭前平均血糖
        if(blood_sugar_times_after_meal!=0){
            blood_sugar_after_meal_average = (int) (blood_sugar_total_after_meal / blood_sugar_times_after_meal);
        }
        if(blood_sugar_times_before_meal!=0){
            blood_sugar_before_meal_average = (int) (blood_sugar_total_before_meal / blood_sugar_times_before_meal);
        }
        //NSMutableDictionary 存放的都是对象,所以在存放整形时,需要把 int 转为NSNumber对象,这里使用@()语法糖
        [res setObject:@(blood_sugar_after_meal_average) forKey:@"blood_sugar_after_meal_average"];//饭后平均血糖
        [res setObject:@(blood_sugar_before_meal_average) forKey:@"blood_sugar_before_meal_average"];//饭前平均血糖
        [res setObject:@(after_meal_times_hyperglycaemia) forKey:@"after_meal_times_hyperglycaemia"];//饭后高血糖次数
        [res setObject:@(before_meal_times_hyperglycaemia) forKey:@"before_meal_times_hyperglycaemia"];//饭前高血糖次数
        [res setObject:@(before_meal_times_hypoglycemia) forKey:@"before_meal_times_hypoglycemia"];//饭前低血糖次数
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
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ order by _id DESC limit 0,7", BLOOD_SUGAR, AFTER_MEAL, RECORD_DATE, RECORD_TIME, UPLOAD_STATE, TableName];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            char *blood_sugar = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:blood_sugar encoding:NSUTF8StringEncoding] forKey:BLOOD_SUGAR];
            char *after_meal = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:after_meal encoding:NSUTF8StringEncoding] forKey:AFTER_MEAL];
            char *record_date = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:record_date encoding:NSUTF8StringEncoding] forKey:RECORD_DATE];
            char *record_time = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:record_time encoding:NSUTF8StringEncoding] forKey:RECORD_TIME];
            char *upload_state = (char *)sqlite3_column_text(statement, 5);
            [dic setValue:[NSString stringWithCString:upload_state encoding:NSUTF8StringEncoding] forKey:UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

@end
