//
//  AlarmClockDB_.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/25.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AlarmClockDB_.h"
#import "sqlite3.h"

#define ClockTableName @"alarm_clock"
#define TimeTableName @"alarm_time"

@implementation AlarmClockDB_

+(void)createTable:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return;
    }
    sqlite3 *database = [dbDriver getDatabase];
    //创建表
    char *errmsg;
    NSString *createClockTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id PRIMARY KEY , %@, %@, %@, %@, %@, %@ );", ClockTableName, CLOCK_TITLE, CLOCK_CONTENT, START_DATE, EXPIRE_DOSE, STATE, UPLOAD_STATE];
    if (sqlite3_exec(database, [createClockTableSQL UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert1(0, @"未能创建表：%s", errmsg);
        sqlite3_free(errmsg);
    }
    NSString *createTimeTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@ );", TimeTableName, CLOCK_ID, TIME_STR, STATE];
    if (sqlite3_exec(database, [createTimeTableSQL UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert1(0, @"未能创建表：%s", errmsg);
        sqlite3_free(errmsg);
    }
}

+(NSString*)insert:(BaseDB*)dbDriver clockDic:(NSDictionary*)dic timeArr:(NSArray*)arr{
    if(dbDriver==nil){
        return @"数据库对象不能为空";
    }
    [dbDriver execSQl:@"BEGIN"];
    @try {
        NSString *clock_id = [dic objectForKey:@"_id"];
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (_id,%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@','%@')", ClockTableName, CLOCK_TITLE, CLOCK_CONTENT, START_DATE, EXPIRE_DOSE, STATE, UPLOAD_STATE, clock_id, [dic objectForKey:CLOCK_TITLE], [dic objectForKey:CLOCK_CONTENT], [dic objectForKey:START_DATE], [dic objectForKey:EXPIRE_DOSE], @"1", [dic objectForKey:UPLOAD_STATE]];
        [dbDriver execSQl:insertSQL];
        if(arr!=nil && arr.count>0){
            for(NSString *time_str in arr){
                insertSQL=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@) values('%@','%@','%@')",TimeTableName, CLOCK_ID, TIME_STR, STATE,clock_id,time_str,@"1"];
                [dbDriver execSQl:insertSQL];
            }
            [dbDriver execSQl:@"COMMIT"];
            return @"true";
        }else{
            [dbDriver execSQl:@"ROLLBACK"];
            return @"闹铃时间不能为空";
        }
    } @catch (NSException *exception) {
        [dbDriver execSQl:@"ROLLBACK"];
        return [exception description];
    }
}

+(void)insert:(BaseDB*)dbDriver clockArr:(NSArray*)arr {
    if(dbDriver==nil){
        return;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSString *clockSql = [NSString stringWithFormat:@"insert into %@ (_id,%@,%@,%@,%@,%@,%@)values(?,?,?,?,?,?,?)", ClockTableName, CLOCK_TITLE, CLOCK_CONTENT, START_DATE, EXPIRE_DOSE, STATE, UPLOAD_STATE];
    char *errmsg;
    sqlite3_stmt *statement = NULL;
    for(NSDictionary *tempDic in arr){
        NSString *clock_id = [tempDic objectForKey:@"_id"];
        NSString *clock_title = [tempDic objectForKey:CLOCK_TITLE];
        NSString *clock_content = [tempDic objectForKey:CLOCK_CONTENT];
        NSString *start_date = [tempDic objectForKey:START_DATE];
        NSString *exprire_dose = [tempDic objectForKey:EXPIRE_DOSE];
        NSString *upload_state = [tempDic objectForKey:UPLOAD_STATE];
        NSLog(@"tempDic=%@",tempDic);
        @try {
            if (sqlite3_prepare_v2(database, [clockSql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                sqlite3_bind_text(statement, 1, [clock_id UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 2, [clock_title UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 3, [clock_content UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 4, [start_date UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 5, [exprire_dose UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 6, [@"1" UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 6, [upload_state UTF8String], -1, NULL);
            }
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"数据插入失败");
                NSAssert(0, @"erroe updating tabels %s",errmsg);
            }else{
                NSString *alarm_time = [tempDic objectForKey:@"alarm_time"];
                NSArray *timeArr = [alarm_time componentsSeparatedByString:@","];
                for(NSString *time_str in timeArr){
                    NSString *timeSql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@) values('%@','%@','%@')",TimeTableName, CLOCK_ID, TIME_STR, STATE,clock_id,time_str,@"1"];
                    [dbDriver execSQl:timeSql];
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"exception=%@",[exception description]);
        }
        
    }
}


# pragma 改

//设置闹钟药品剩余剂量-1
+ (NSString*)reduceClockExpireDose:(BaseDB*)dbDriver clockId:(NSString *)clock_id{
    if(dbDriver==nil){
        return nil;
    }
    //先查询药品剩余药量
    NSString *expireDose;
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@ from %@ where _id='%@'", EXPIRE_DOSE,ClockTableName, clock_id];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        if (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            expireDose = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            expireDose = [NSString stringWithFormat:@"%d", [expireDose intValue]-1];
            NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='%@',%@='1' where _id='%@'", ClockTableName, EXPIRE_DOSE, expireDose, STATE, clock_id];
            [dbDriver execSQl:updateSQL];
        }
    }else{
        NSLog(@"selectSQL=%@",selectSQL);
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return expireDose;
}

//设置闹钟过期
+(void)setClockExpire:(BaseDB*)dbDriver clockId:(NSString *)clock_id{
    if(dbDriver==nil){
        return;
    }
    NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='1' where _id='%@'", ClockTableName, STATE, clock_id];
    [dbDriver execSQl:updateSQL];
    updateSQL = [NSString stringWithFormat:@"update %@ set %@='1' where %@='%@'", TimeTableName, STATE, CLOCK_ID, clock_id];
    [dbDriver execSQl:updateSQL];
}

//修改闹钟同步状态
+(void)setUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSString *_id in arr){
        NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='2' where _id='%@'", ClockTableName, UPLOAD_STATE, _id];
        [dbDriver execSQl:updateSQL];
    }
}


# pragma 查

+(NSMutableArray*)query:(BaseDB*)dbDriver byState:(int)state{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ where %@='%d'", CLOCK_TITLE, CLOCK_CONTENT, START_DATE, EXPIRE_DOSE, STATE, ClockTableName, STATE, state];
    NSLog(@"selectSQL=%@",selectSQL);
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            
            char *title = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:title encoding:NSUTF8StringEncoding] forKey:CLOCK_TITLE];
            
            char *content = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:content encoding:NSUTF8StringEncoding] forKey:CLOCK_CONTENT];
            
            char *start_date = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:start_date encoding:NSUTF8StringEncoding] forKey:START_DATE];
            
            char *expire_dose = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:expire_dose encoding:NSUTF8StringEncoding] forKey:EXPIRE_DOSE];
            
            char *state = (char *)sqlite3_column_text(statement, 5);
            [dic setValue:[NSString stringWithCString:state encoding:NSUTF8StringEncoding] forKey:STATE];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

+(NSMutableArray*)query:(BaseDB*)dbDriver byAlarmTime:(NSString*)alarmTime{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@ from %@(unlock) inner join %@ on %@._id=%@.%@  and %@.%@='1'  where %@.%@='%@' ", CLOCK_ID, CLOCK_TITLE, CLOCK_CONTENT, EXPIRE_DOSE, TIME_STR, TimeTableName, ClockTableName, ClockTableName, TimeTableName, CLOCK_ID, ClockTableName, STATE, TimeTableName, TIME_STR, alarmTime];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            char *clock_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:clock_id encoding:NSUTF8StringEncoding] forKey:CLOCK_ID];
            
            char *title = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:title encoding:NSUTF8StringEncoding] forKey:CLOCK_TITLE];
            
            char *content = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:content encoding:NSUTF8StringEncoding] forKey:CLOCK_CONTENT];
            
            char *expire_dose = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:expire_dose encoding:NSUTF8StringEncoding] forKey:EXPIRE_DOSE];
            
            char *alarm_time = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:alarm_time encoding:NSUTF8StringEncoding] forKey:TIME_STR];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

+(NSMutableArray*)queryTimeList:(BaseDB*)dbDriver clockId:(NSString*)clockId{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@ from %@ where %@='%@' ORDER BY %@ asc", CLOCK_ID, TIME_STR, STATE, TimeTableName, CLOCK_ID, clockId, TIME_STR];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            char *_id = (char *)sqlite3_column_text(statement, 0);
            [dic setValue:[NSString stringWithCString:_id encoding:NSUTF8StringEncoding] forKey:@"_id"];
            
            char *clock_id = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:clock_id encoding:NSUTF8StringEncoding] forKey:CLOCK_ID];
            
            char *alarm_time = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:alarm_time encoding:NSUTF8StringEncoding] forKey:TIME_STR];
            
            char *state = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:state encoding:NSUTF8StringEncoding] forKey:STATE];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

//查询闹铃时间下有无药品
+(BOOL)queryExistsByAlarmTime:(BaseDB*)dbDriver alarmTime:(NSString *)alarm_time{
    if(dbDriver==nil){
        return nil;
    }
    int count;
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from %@ where %@='1' and %@='%@'", TimeTableName, STATE, TIME_STR, alarm_time];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        if (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            count = sqlite3_column_int(statement, 0);
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    if(count>0){
        return true;
    }else{
        return false;
    }
}

//通过闹钟id查询该闹钟所对应哪几个闹铃时间
+(NSString*)queryClockTimeCount:(BaseDB*)dbDriver byClockId:(NSString *)clock_id{
    if(dbDriver==nil){
        return nil;
    }
    NSString *count;
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from %@ where %@='%@'", TimeTableName, CLOCK_ID, clock_id];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        if (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            count = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return count;
}

+(NSMutableArray*)queryTimeListDistinct:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    NSMutableArray *res = [[NSMutableArray alloc]init];
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select DISTINCT %@ from %@ where %@='1' ORDER BY %@ asc", TIME_STR, TimeTableName, STATE, TIME_STR];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    NSMutableArray *timeArr = [[NSMutableArray alloc]init];
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *alarm_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [timeArr addObject:alarm_time];
        }
        for(NSString *alarm_time in timeArr){
            selectSQL = [NSString stringWithFormat:@"select %@,%@ from %@ c,%@ t where c.'_id'=t.%@ and t.%@='%@' ",CLOCK_TITLE,CLOCK_CONTENT,ClockTableName,TimeTableName,CLOCK_ID,TIME_STR,alarm_time];
            sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
            NSMutableArray *clockArr = [[NSMutableArray alloc]init];
            if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
                //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
                while (sqlite3_step(statement) == SQLITE_ROW){
                    //sqlite3_column_text(), 取text类型的数据。
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    NSString *clock_title = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                    [dic setValue:clock_title forKey:CLOCK_TITLE];
                    NSString *clock_content = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
                    [dic setValue:clock_content forKey:CLOCK_CONTENT];
                    [clockArr addObject:dic];
                }
            }else{
                NSLog(@"selectSQL=%@",selectSQL);
                NSLog(@"查询报错");
            }
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
            [tempDic setValue:alarm_time forKey:@"alarm_time"];
            [tempDic setObject:clockArr forKey:@"clockArr"];
            [res addObject:tempDic];
        }
    }else{
        NSLog(@"selectSQL=%@",selectSQL);
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

+(NSMutableArray*)getNotificationTime:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    NSMutableArray *res = [[NSMutableArray alloc]init];
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select DISTINCT %@ from %@ where %@='1' ORDER BY %@ asc", TIME_STR, TimeTableName, STATE, TIME_STR];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *alarm_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [res addObject:alarm_time];
        }
    }else{
        NSLog(@"selectSQL=%@",selectSQL);
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

+(NSArray*)queryUpload:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return nil;
    }
    NSMutableArray *res = [[NSMutableArray alloc]init];
    sqlite3 *database = [dbDriver getDatabase];
    
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@ from %@ where %@<'2'", CLOCK_TITLE, CLOCK_CONTENT, START_DATE, EXPIRE_DOSE, STATE, ClockTableName, UPLOAD_STATE];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            char *title = (char *)sqlite3_column_text(statement, 1);
            [dic setValue:[NSString stringWithCString:title encoding:NSUTF8StringEncoding] forKey:CLOCK_TITLE];
            char *content = (char *)sqlite3_column_text(statement, 2);
            [dic setValue:[NSString stringWithCString:content encoding:NSUTF8StringEncoding] forKey:CLOCK_CONTENT];
            char *start_date = (char *)sqlite3_column_text(statement, 3);
            [dic setValue:[NSString stringWithCString:start_date encoding:NSUTF8StringEncoding] forKey:START_DATE];
            char *expire_dose = (char *)sqlite3_column_text(statement, 4);
            [dic setValue:[NSString stringWithCString:expire_dose encoding:NSUTF8StringEncoding] forKey:EXPIRE_DOSE];
            char *state = (char *)sqlite3_column_text(statement, 5);
            [dic setValue:[NSString stringWithCString:state encoding:NSUTF8StringEncoding] forKey:STATE];
            
            NSString *alarm_time;
            selectSQL = [NSString stringWithFormat:@"select %@ from %@ where %@='%@'", TIME_STR, TimeTableName, CLOCK_ID, _id];
            sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
            if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
                while (sqlite3_step(statement) == SQLITE_ROW){
                    if(alarm_time==nil){
                        alarm_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                    }else{
                        [alarm_time stringByAppendingString:[NSString stringWithFormat:@",%@",[NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding]]];
                    }
                }
            }
            [dic setValue:alarm_time forKey:TIME_STR];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

@end
