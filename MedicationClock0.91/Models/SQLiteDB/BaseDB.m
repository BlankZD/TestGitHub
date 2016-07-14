//
//  BaseDB.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BaseDB.h"

#define kDatabaseName @"test.db"

@implementation BaseDB{
    sqlite3 *database;
}

- (sqlite3*)getDatabase{
    return database;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        if([self openDB]){
            return self;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

-(BOOL)openDB{
    //获取数据库文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *thePath = [paths objectAtIndex:0];
    NSString *file = [thePath stringByAppendingPathComponent:kDatabaseName];
    
    //创建数据库或打开数据库
    if (sqlite3_open([file UTF8String], &database) == SQLITE_OK){
        return TRUE;
    }else{
        sqlite3_close(database);
        NSAssert(0, @"未能打开数据库");
        return FALSE;
    }
}

//执行非查询的sql语句
-(void)execSQl:(NSString*)sqlStr{
    char *errmsg;
    if (sqlite3_exec(database, [sqlStr UTF8String], nil, nil, &errmsg) != SQLITE_OK){
        NSAssert1(0, @"执行语句出错：%s", errmsg);
        sqlite3_free(errmsg);
    }
}

-(void)beginTransaction{
    [self execSQl:@"BEGIN"];
}

-(void)endTransaction{
    [self execSQl:@"COMMIT"];
}

-(void)rallback{
    [self execSQl:@"ROLLBACK"];
}

-(void)dealloc{
    sqlite3_close(database);
}

@end
