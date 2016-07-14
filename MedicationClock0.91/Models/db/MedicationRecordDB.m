//
//  MedicationRecordDB.m
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "MedicationRecordDB.h"

@implementation MedicationRecordDB
//单例对象
+(MedicationRecordDB *)getInstance
{
    static MedicationRecordDB * alarmClockDB=nil;
    if(alarmClockDB == nil)
    {
        alarmClockDB = [[MedicationRecordDB alloc] init];
    }
    return alarmClockDB;
}


-(long)getRecordCount
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];;
    NSString *sql = [NSString stringWithFormat:@"select count(*) as count from %@",DB_medication_record];
    NSMutableArray *res=[db select:sql,@"count",@"int",nil];
    // 获取数据中的LONG类型数据
    NSNumber *clock_id = [res[0] objectForKey:@"count"];
    return [clock_id longValue];
}
-(long)getDetailCount
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];;
    NSString *sql = [NSString stringWithFormat:@"select count(*) as count from %@",DB_medication_list];
    NSMutableArray *res=[db select:sql,@"count",@"int",nil];
    // 获取数据中的LONG类型数据
    NSNumber *clock_id = [res[0] objectForKey:@"count"];
    return [clock_id longValue];
}

-(void)deleteAll
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"delete from %@",DB_medication_list];
    [db execSQl:sql];
    sql =[NSString stringWithFormat:@"delete from %@",DB_medication_record];
    [db execSQl:sql];

    [db endTransaction];    //提交
}
@end
