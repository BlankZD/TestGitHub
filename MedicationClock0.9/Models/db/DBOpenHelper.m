//
//  DBOpenHelper.m
//  SQLiteDemo
//
//  Created by jam on 16/3/28.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "DBOpenHelper.h"

@implementation DBOpenHelper


+(DBOpenHelper *)getInstance
{
    static DBOpenHelper * instance=nil;
    if(instance == nil)
    {
        instance = [[DBOpenHelper alloc] init];
        [instance connect];
        [instance beginTransaction];
        //初始化项目数据库 20160330 jjw
        //20160331 jjw
        [instance execSQl:SQL_CREATE_ALARM_CLOCK];                  //创建闹钟表
        [instance execSQl:SQL_CREATE_ALARM_TIME];                   //创建闹钟时间表
        [instance execSQl:SQL_CREATE_medication_record];            //创建服药记录表
        [instance execSQl:SQL_CREATE_medication_list];              //创建服药记录详情表
        [instance execSQl:SQL_CREATE_test_alarm_record];            //创建闹钟纪录表（统计测试数据）
        [instance execSQl:SQL_CREATE_blood_pressure_record];        //创建血压测量记录表
        [instance execSQl:SQL_CREATE_blood_sugar_record];           //创建血糖测量记录表
        
        [instance endTransaction];
    }
    return instance;
}

-(sqlite3 *)connect
{
    static sqlite3 *database;
    if(database == nil){
        //获取数据库文件路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *thePath = [paths objectAtIndex:0];
        NSString *file = [thePath stringByAppendingPathComponent:kDatabaseName];
        
        //创建数据库
        if (sqlite3_open([file UTF8String], &database) != SQLITE_OK)
        {
            sqlite3_close(database);
            NSAssert(0, @"未能打开数据库");
        }
    
    }
    return database;
}

-(DBOpenHelper *)getConnect
{
    [self connect];
    return self;
}

-(void)execSQl:(NSString *)sql 
{
    char *errmsg;
    //sqlite3_exec(),   执行非查询的sql语句
    if (sqlite3_exec([self connect], [sql UTF8String], nil, nil, &errmsg) != SQLITE_OK)
    {
        sqlite3_close([self connect]);
        NSAssert1(0, @"执行脚本出现问题：%s", errmsg);
        sqlite3_free(errmsg);
    }
}

/*
 *查询语句
 *20160328 jjw
 *参数
 *selectSQL 查询的sql语句
 *cols select 语句中所有的药返回参数的 子段名和类型配对
 *
 */
-(NSMutableArray *)select:(NSString * ) selectSQL,...{
    va_list names;
    va_start(names, selectSQL);
    NSMutableArray *array2=[[NSMutableArray alloc] init];
    int i=1;
    NSObject * value=nil;
    while((value = va_arg(names,id))){
        [array2 addObject:value];
    }
    va_end(names);
    
    NSMutableArray * array= [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare([self connect], [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK){

        while (sqlite3_step(statement) == SQLITE_ROW){
         //   while(sqlite3_step(statement))
            int count = array2.count;
            NSMutableDictionary * md = [NSMutableDictionary dictionaryWithCapacity:count];
            int index = 0;
            
            for(i =0;i<count;i=i+2){
                NSString *colName =array2[i];
                NSString *type =array2[i+1];
                if([type isEqualToString:@"text"]){
                    char *name = (char *)sqlite3_column_text(statement, index);
                    [md setObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding] forKey:colName];
                }else if([type isEqualToString:@"int"]){
                    int name = sqlite3_column_int(statement, index);
                    [md setObject:[NSNumber numberWithInt:name] forKey:colName];
                }
                index = index +1;
            }
            [array addObject:md];
            
            
            //nameLabel.text = [NSString stringWithFormat:@"%s", name];
        }
    }
    //sqlite3_finalize(stmt); 释放sql文资源
    sqlite3_finalize(statement);
    
    return array;
}

-(void)updata:(NSString * )sql,...
{
    va_list names;
    va_start(names, sql);
    NSMutableArray *array=[[NSMutableArray alloc] init];
    int i=1;
    NSObject * value=nil;
    while((value = va_arg(names,id)))
    {
        [array addObject:value];
    }
    va_end(names);
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2([self connect], [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        int index = 1;
        int count = array.count;
        for(i =0;i<count;i=i+2)
         {
            NSString *type =array[i];
            if([type isEqualToString:@"text"])
            {
               NSString *value = array[i +1];
               sqlite3_bind_text(stmt, index, [value UTF8String], -1, NULL);
                
            }else if([type isEqualToString:@"int"])
            {
                NSNumber * value = array[i +1];
                sqlite3_bind_int(stmt, index,[value intValue]);
            }
            index = index +1;
        }
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"数据更新失败");
        NSAssert(0, @"erroe updating tabels %s",errorMsg);
    }
    sqlite3_finalize(stmt);
}


-(void)beginTransaction
{
    [self execSQl:@"BEGIN"];
}

-(void)endTransaction
{
    [self execSQl:@"COMMIT"];
}

-(void)rallback
{
    [self execSQl:@"ROLLBACK"];
}



@end
