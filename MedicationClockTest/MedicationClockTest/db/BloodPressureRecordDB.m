//
//  BloodPressureRecordDB.m
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "BloodPressureRecordDB.h"
#import "DBOpenHelper.h"

@implementation BloodPressureRecordDB

//单例对象
+(BloodPressureRecordDB *)getInstance
{
    static BloodPressureRecordDB * alarmClockDB=nil;
    if(alarmClockDB == nil)
    {
        alarmClockDB = [[BloodPressureRecordDB alloc] init];
    }
    return alarmClockDB;
}

-(long)getCount
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    NSString *sql = [NSString stringWithFormat:@"select count(*) as count from %@",DB_blood_pressure_record];
    NSMutableArray *res=[db select:sql,@"count",@"int",nil];
    // 获取数据中的LONG类型数据
    NSNumber *clock_id = [res[0] objectForKey:@"count"];
    return [clock_id longValue];
}

-(void)insert_list:(NSMutableArray *)paramList
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    for(int i =0;i<paramList.count;i++){
        NSMutableDictionary * md = paramList[i];
        NSString * sql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@)values('%@','%@','%@','%@','%@','%@','%@')",DB_blood_pressure_record,DB_BPR_systolic_pressure,DB_BPR_diastolic_pressure,DB_BPR_heart_rate,DB_BPR_remarks,DB_BPR_record_date,DB_BPR_record_time,DB_BPR_state,[md objectForKey:DB_BPR_systolic_pressure],[md objectForKey:DB_BPR_diastolic_pressure],[md objectForKey:DB_BPR_heart_rate],[md objectForKey:DB_BPR_remarks],[md objectForKey:DB_BPR_record_date],[md objectForKey:DB_BPR_record_time],@"1"];
        [db execSQl:sql];
    }
    [db endTransaction];
}


-(NSMutableArray *)queryByDateStr:(NSString *)dateStr
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];

    NSString * sql =[NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ where %@='%@';",DB_BPR_systolic_pressure,DB_BPR_diastolic_pressure,DB_BPR_heart_rate,DB_BPR_remarks,DB_BPR_record_date,DB_BPR_record_time,DB_BPR_state,DB_blood_pressure_record,DB_BPR_record_date,dateStr];
    NSMutableArray * res = [db select:sql,@"_id",@"int",DB_BPR_systolic_pressure,@"text",DB_BPR_diastolic_pressure,@"text",DB_BPR_heart_rate,@"text",DB_BPR_remarks,@"text",DB_BPR_record_date,@"text",DB_BPR_record_time,@"text",DB_BPR_state,@"text",nil];
    /* 查所有的血压记录 测试数据的时候用到了
    sql =[NSString stringWithFormat:@"select _id,%@,%@,%@,%@,%@,%@,%@ from %@ ;",DB_BPR_systolic_pressure,DB_BPR_diastolic_pressure,DB_BPR_heart_rate,DB_BPR_remarks,DB_BPR_record_date,DB_BPR_record_time,DB_BPR_state,DB_blood_pressure_record,DB_BPR_record_date,dateStr];
    NSLog(@"----%@",[db select:sql,@"_id",@"int",DB_BPR_systolic_pressure,@"text",DB_BPR_diastolic_pressure,@"text",DB_BPR_heart_rate,@"text",DB_BPR_remarks,@"text",DB_BPR_record_date,@"text",DB_BPR_record_time,@"text",DB_BPR_state,@"text",nil]);
    */
    [db endTransaction];
    return res;
}

-(void)deleteAll
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"delete from %@",DB_blood_pressure_record];
    [db execSQl:sql];
    [db endTransaction];    //提交
}

@end
