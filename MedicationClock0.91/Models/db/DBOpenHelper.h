//
//  DBOpenHelper.h
//  SQLiteDemo
//
//  Created by jam on 16/3/28.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sqlite3.h"

#import "BloodSugarRecordDB.h"
#import "AlarmClockDB.h"
#import "BloodPressureRecordDB.h"
#import "MedicationRecordDB.h"
#import "TestAlarmRecordDB.h"


#define kDatabaseName @"database.sqlite"

@interface DBOpenHelper : NSObject
+(DBOpenHelper *)getInstance;
-(DBOpenHelper *)getConnect;
-(void)execSQl:(NSString *)sql;
-(NSMutableArray *)select:(NSString * ) selectSQL,...;
-(void)updata:(NSString * )sql,...;
-(void)beginTransaction;
-(void)endTransaction;
-(void)rallback;
@end
