//
//  MedicationRecordDB_.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "MedicationRecordDB_.h"
#import "sqlite3.h"
#import "DateUtil.h"

#define RecordTableName @"medication_record"
#define DetailTableName @"medication_detail"

@implementation MedicationRecordDB_

+ (void)createTable:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return;
    }
    sqlite3 *database = [dbDriver getDatabase];
    //创建表
    char *errmsg;
    NSString *createRecordTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@, %@ );", RecordTableName, CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE];
    if (sqlite3_exec(database, [createRecordTableSQL UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert1(0, @"未能创建表：%s", errmsg);
        sqlite3_free(errmsg);
    }
    NSString *createDetailTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(_id INTEGER PRIMARY KEY autoincrement , %@, %@, %@ );", DetailTableName, RECORD_ID, MEDICATION_TIME, DETAILS_UPLOAD_STATE];
    if (sqlite3_exec(database, [createDetailTableSQL UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert1(0, @"未能创建表：%s", errmsg);
        sqlite3_free(errmsg);
    }
}


#pragma 增

+ (void)insertRecordArray:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSDictionary *dic in arr){
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@')", RecordTableName, CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE, [dic objectForKey:CLOCK_ID], [dic objectForKey:TITLE], [dic objectForKey:RECORD_DATE], [dic objectForKey:ALARM_TIMES], [dic objectForKey:MEDICATION_STATE], [dic objectForKey:RECORD_UPLOAD_STATE]];
        [dbDriver execSQl:insertSQL];
    }
}

+ (void)insertDetailArray:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSDictionary *dic in arr){
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@)values('%@','%@','%@')", DetailTableName, RECORD_ID, MEDICATION_TIME, DETAILS_UPLOAD_STATE, [dic objectForKey:RECORD_ID], [dic objectForKey:MEDICATION_TIME], [dic objectForKey:DETAILS_UPLOAD_STATE]];
        [dbDriver execSQl:insertSQL];
    }
}
+ (NSString*)insertDetail:(BaseDB*)dbDriver dic:(NSDictionary*)dic{
    if(dbDriver==nil){
        return @"数据库对象不能为空";
    }
    @try {
        [dbDriver execSQl:@"BEGIN"];
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@)values('%@','%@','0')", DetailTableName, RECORD_ID, MEDICATION_TIME, DETAILS_UPLOAD_STATE, [dic objectForKey:RECORD_ID], [dic objectForKey:MEDICATION_TIME]];
        [dbDriver execSQl:insertSQL];

        NSString *medication_state;
        NSString *selectSQL = [NSString stringWithFormat:@"select %@ from %@ where _id='%@'", MEDICATION_STATE, RecordTableName, [dic objectForKey:RECORD_ID]];
        sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
        sqlite3 *database = [dbDriver getDatabase];
        if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
            //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
            if (sqlite3_step(statement) == SQLITE_ROW){
                //sqlite3_column_text(), 取text类型的数据。
                medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            }
            NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='%@' where _id='%@'", RecordTableName, MEDICATION_STATE, [NSString stringWithFormat:@"%d",[medication_state intValue]+1], [dic objectForKey:RECORD_ID]];
            [dbDriver execSQl:updateSQL];
            [dbDriver execSQl:@"COMMIT"];
        }else{
            NSLog(@"查询报错");
            [dbDriver execSQl:@"ROLLBACK"];
        }
        sqlite3_finalize(statement);    //释放sql文资源
        return @"true";
    } @catch (NSException *exception) {
        [dbDriver execSQl:@"ROLLBACK"];
        return [exception description];
    }
}

+ (NSString*)insertByDate:(BaseDB*)dbDriver dic:(NSDictionary*)dic{
    if(dbDriver==nil){
        return @"操作数据库的对象不能为nil";
    }
    NSString *res;
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@ from %@ where %@='%@' and %@='%@'", ALARM_TIMES, MEDICATION_STATE, RecordTableName, CLOCK_ID, [dic valueForKey:CLOCK_ID], RECORD_DATE, [dic valueForKey:RECORD_DATE]];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    @try {
        if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
            NSString *_id;
            //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
            if (sqlite3_step(statement) == SQLITE_ROW){
                //如果已存在当天的服药记录
                _id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
                NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
                if([alarm_times intValue]<=[medication_state intValue]){
                    res = @"补录服药记录失败，请确认当天服药次数是否已满";
                    NSLog(@"补录服药记录失败，请确认当天服药次数是否已满");
                    _id=nil;
                }else{
                    medication_state = [NSString stringWithFormat:@"%d", [medication_state intValue]+1];
                    //服药记录概要表的服药次数加1,并将与服务器同步状态设置为未同步
                    NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='%@',%@='1' where _id='%@'", RecordTableName, MEDICATION_STATE, medication_state, RECORD_UPLOAD_STATE, _id];
                    [dbDriver execSQl:updateSQL];
                }
            }else{
                //如果当天还没有服药记录
                NSString *insertSQL = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@')", RecordTableName, CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE, [dic valueForKey:CLOCK_ID], [dic valueForKey:TITLE], [dic valueForKey:RECORD_DATE], [dic valueForKey:ALARM_TIMES], @"1", @"0"];
                NSLog(@"insertSQL=%@",insertSQL);
                [dbDriver execSQl:insertSQL];
                //查询最后一条插入的数据的id
                selectSQL = [NSString stringWithFormat:@"select last_insert_rowid() from %@", RecordTableName];
                sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
                if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
                    //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
                    if (sqlite3_step(statement) == SQLITE_ROW){
                        _id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                    }
                }else{
                    res = @"查询服药详情表报错";
                    NSLog(@"查询服药详情表报错");
                }
                sqlite3_finalize(statement);
            }
            if(_id!=nil){
                NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@)values('%@','%@','0')", DetailTableName, RECORD_ID, MEDICATION_TIME, DETAILS_UPLOAD_STATE, _id, [dic objectForKey:MEDICATION_TIME]];
                [dbDriver execSQl:insertSQL];
                res = @"true";
            }
        }else{
            res = @"查询服药概要表报错";
            NSLog(@"查询服药概要表报错");
        }
    } @catch (NSException *exception) {
        res = [exception description];
    } @finally {
        //释放sql文资源
        sqlite3_finalize(statement);
    }
    return res;
}


#pragma 改

+(void)setRecordUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSString *_id in arr){
        NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='2' where _id='%@'", RecordTableName, RECORD_UPLOAD_STATE, _id];
        [dbDriver execSQl:updateSQL];
    }
}
+(void)setDetailUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr{
    if(dbDriver==nil){
        return;
    }
    for(NSString *_id in arr){
        NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@='2' where _id='%@'", DetailTableName, DETAILS_UPLOAD_STATE, _id];
        [dbDriver execSQl:updateSQL];
    }
}

+ (NSMutableArray*)queryRecordByDate:(BaseDB*)dbDriver dateStr:(NSString*)dateStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@ from %@ where %@='%@';", CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE, RecordTableName, RECORD_DATE, dateStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            NSString *clock_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:clock_id forKey:CLOCK_ID];
            NSString *title = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:title forKey:TITLE];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:alarm_times forKey:ALARM_TIMES];
            NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:medication_state forKey:MEDICATION_STATE];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:RECORD_UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+ (NSMutableArray*)queryDetailsByClockIdAndDate:(BaseDB*)dbDriver clockId:(NSString*)clockId dateStr:(NSString*)dateStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    
    
    
    
    
    return res;
}

+ (NSMutableArray*)queryDetailsByRecordId:(BaseDB*)dbDriver recordId:(NSString*)recordId{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@ from %@ where %@='%@' ", RECORD_ID, MEDICATION_TIME, DetailTableName, RECORD_ID, recordId];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            
            NSString *record_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:record_id forKey:RECORD_ID];
            
            NSString *medication_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:medication_time forKey:MEDICATION_TIME];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
        NSLog(@"selectSQL=%@",selectSQL);
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+ (NSMutableSet*)queryState:(BaseDB*)dbDriver byYearMonthStr:(NSString*)ymStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableSet *res = [[NSMutableSet alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@,%@ from %@ where %@ like '%@%%'", RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RecordTableName, RECORD_DATE, ymStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            if([medication_state intValue]<[alarm_times intValue]){
                [res addObject:record_date];
            }
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

//unused
+ (NSArray*)queryRecently:(BaseDB*)dbDriver clockId:(NSString*)clockId{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@ from %@ where %@='%@' order by _id DESC limit 0,7", CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE, RecordTableName, CLOCK_ID, clockId];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            NSString *clock_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:clock_id forKey:CLOCK_ID];
            NSString *title = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:title forKey:TITLE];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:alarm_times forKey:ALARM_TIMES];
            NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:medication_state forKey:MEDICATION_STATE];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:RECORD_UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

+ (NSString*)queryRecently:(BaseDB*)dbDriver clockId:(NSString*)clockId dateStr:(NSString*)dateStr{
    if(dbDriver==nil){
        return nil;
    }
    sqlite3 *database = [dbDriver getDatabase];
    
    NSString *medication_state=@"0";
    NSString *selectSQL = [NSString stringWithFormat:@"select %@ from %@ where %@='%@' and %@='%@' ", MEDICATION_STATE, RecordTableName, CLOCK_ID, clockId, RECORD_DATE, dateStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        if (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return medication_state;
}

+ (NSMutableDictionary*)queryReport:(BaseDB*)dbDriver byType:(int)type clockId:(NSString*)clockId dateStr:(NSString*)dateStr{
    if(dbDriver==nil){
        return nil;
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    if(type==0){
        [comps setWeekOfYear:-1];
    }else if(type==1){
        [comps setMonth:-1];
    }else if(type==2){
        [comps setYear:-1];
    }
    NSDate *date = [DateUtil getDateFromStr:dateStr formatStr:@"yyyy-MM-dd"];
    NSDate *dateFrom = [calendar dateByAddingComponents:comps toDate:date options:0];
    NSString *dateStrFrom = [DateUtil getStrFromDate:dateFrom formatStr:@"yyyy-MM-dd"];
    NSMutableDictionary *res = [[NSMutableDictionary alloc]init];
    
    int total_times = 0;
    int total_state = 0;
    sqlite3 *database = [dbDriver getDatabase];
    NSString *selectSQL = [NSString stringWithFormat:@"select %@,%@ from %@ where %@='%@' and (%@ between '%@' and '%@')", ALARM_TIMES, MEDICATION_STATE, RecordTableName, CLOCK_ID, clockId, RECORD_DATE, dateStrFrom, dateStr];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        if (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            total_times += [alarm_times intValue];
            total_state += [medication_state intValue];
            //NSMutableDictionary 存放的都是对象,所以在存放整形时,需要把 int 转为NSNumber对象,这里使用@()语法糖
            [res setObject:@(total_times) forKey:@"total_times"];
            [res setObject:@(total_state) forKey:@"total_state"];
        }
    }else{
        NSLog(@"查询报错");
    }
    //释放sql文资源
    sqlite3_finalize(statement);
    return res;
}

+(int)getRecordCount:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return 0;
    }
    sqlite3 *database = [dbDriver getDatabase];
    int count;
    NSString *selectSQL = [NSString stringWithFormat:@"select count(*) as count from %@", RecordTableName];
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
    return count;
}
+(int)getDetailCount:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return 0;
    }
    sqlite3 *database = [dbDriver getDatabase];
    int count;
    NSString *selectSQL = [NSString stringWithFormat:@"select count(*) as count from %@", DetailTableName];
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
    return count;
}

+(NSArray*)queryRecordUpload:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return 0;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@ from %@ where %@<'2';", CLOCK_ID, TITLE, RECORD_DATE, ALARM_TIMES, MEDICATION_STATE, RECORD_UPLOAD_STATE, RecordTableName, RECORD_UPLOAD_STATE];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            NSString *clock_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:clock_id forKey:CLOCK_ID];
            NSString *title = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:title forKey:TITLE];
            NSString *record_date = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            [dic setValue:record_date forKey:RECORD_DATE];
            NSString *alarm_times = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            [dic setValue:alarm_times forKey:ALARM_TIMES];
            NSString *medication_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            [dic setValue:medication_state forKey:MEDICATION_STATE];
            NSString *upload_state = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            [dic setValue:upload_state forKey:RECORD_UPLOAD_STATE];
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}
+(NSArray*)queryDetailUpload:(BaseDB*)dbDriver{
    if(dbDriver==nil){
        return 0;
    }
    sqlite3 *database = [dbDriver getDatabase];
    NSMutableArray *res = [[NSMutableArray alloc]init];
    NSString *selectSQL = [NSString stringWithFormat:@"select _id,%@,%@ from %@ where %@<'2' ", RECORD_ID, MEDICATION_TIME, DetailTableName, DETAILS_UPLOAD_STATE];
    sqlite3_stmt *statement;    //这个相当于ODBC的Command对象，用于保存编译好的SQL语句
    if (sqlite3_prepare(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){
        //Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
        while (sqlite3_step(statement) == SQLITE_ROW){
            //sqlite3_column_text(), 取text类型的数据。
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            [dic setValue:_id forKey:@"_id"];
            
            NSString *record_id = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            [dic setValue:record_id forKey:RECORD_ID];
            
            NSString *medication_time = [NSString stringWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            [dic setValue:medication_time forKey:MEDICATION_TIME];
            
            [res addObject:dic];
        }
    }else{
        NSLog(@"查询报错");
        NSLog(@"selectSQL=%@",selectSQL);
    }
    sqlite3_finalize(statement);    //释放sql文资源
    return res;
}

@end
