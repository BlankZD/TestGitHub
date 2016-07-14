//
//  BloodSugarRecordDB.m
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "BloodSugarRecordDB.h"

@implementation BloodSugarRecordDB


//单例对象
+(BloodSugarRecordDB *)getInstance
{
    static BloodSugarRecordDB * alarmClockDB=nil;
    if(alarmClockDB == nil)
    {
        alarmClockDB = [[BloodSugarRecordDB alloc] init];
    }
    return alarmClockDB;
}

-(void)insert:(NSDictionary *)param
{
    
}
-(void)insert_list:(NSMutableArray *)list
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    for(int i =0;i<list.count;i++){
        NSMutableDictionary * md = list[i];
        NSString * sql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@')",DB_blood_sugar_record,DB_BSR_blood_sugar,DB_BSR_after_meal,DB_BSR_record_date,DB_BSR_record_time,DB_BSR_state,[md objectForKey:DB_BSR_blood_sugar],[md objectForKey:DB_BSR_after_meal],[md objectForKey:DB_BSR_record_date],[md objectForKey:DB_BSR_record_time],@"1"];
        [db execSQl:sql];
    }
    [db endTransaction];
    
}

-(long)getCount
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];;
    NSString *sql = [NSString stringWithFormat:@"select count(*) as count from %@",DB_blood_sugar_record];
    NSMutableArray *res=[db select:sql,@"count",@"int",nil];
    // 获取数据中的LONG类型数据
    NSNumber *clock_id = [res[0] objectForKey:@"count"];
    return [clock_id longValue];
}

-(void)deleteAll
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"delete from %@",DB_blood_sugar_record];
    [db execSQl:sql];
    [db endTransaction];    //提交
}

@end
