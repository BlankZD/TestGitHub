//
//  AlarmClockDB.m
//  SQLiteDemo
//
//  Created by jam on 16/3/28.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "AlarmClockDB.h"

@implementation AlarmClockDB

//单例对象
+(AlarmClockDB *)getInstance
{
    static AlarmClockDB * alarmClockDB=nil;
    if(alarmClockDB == nil)
    {
        alarmClockDB = [[AlarmClockDB alloc] init];
    }
    return alarmClockDB;
}

- (BOOL) insertClock:(NSMutableDictionary *)clock_param time_list:(NSMutableArray *)time_list
{
    BOOL result;
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString * sql =[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@) values(%@,%@,%@,%@,%@,%@);",DB_ALARM_CLOCK,DB_AC_TITLE,DB_AC_CONTENT,DB_AC_START_DATE,DB_AC_EXPIREDOSE,DB_AC_STATE,DB_AC_UPLOAD_STATE,[clock_param objectForKey:DB_AC_TITLE],[clock_param objectForKey:DB_AC_CONTENT],[clock_param objectForKey:DB_AC_START_DATE],[clock_param objectForKey:DB_AC_EXPIREDOSE],@"1",[clock_param objectForKey:DB_AC_UPLOAD_STATE]];
    [db execSQl:sql];
    
    if(time_list != nil && time_list.count > 0)
    {
        NSString *selectSql =[NSString stringWithFormat:@"select last_insert_rowid() as newid from %@",DB_ALARM_CLOCK];
        NSMutableArray *res=[db select:selectSql,@"newid",@"id",nil];
        if(res.count == 1)
        {
            NSNumber *clock_id = [res[0] objectForKey:@"newid"];
            [clock_param setObject:clock_id forKey:@"_id"];
            for(int i =0;i<time_list.count;i++)
            {
                NSMutableDictionary *timer_param=time_list[i];
                sql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@) values(%@,%@,%@,%@,%@;",DB_ALARM_TIME,DB_AT_CLOCK_ID,DB_AT_TIME_STR,DB_AT_HOUR,DB_AT_MINUTE,DB_AT_STATE,[timer_param objectForKey:DB_AT_CLOCK_ID],[timer_param objectForKey:DB_AT_TIME_STR],[timer_param objectForKey:DB_AT_HOUR],[timer_param objectForKey:DB_AT_MINUTE],@"1"];
                
                [db execSQl:sql];
                selectSql =[NSString stringWithFormat:@"select last_insert_rowid() as newid from %@",DB_ALARM_CLOCK];
                res=[db select:selectSql,@"newid",@"id",nil];
                if(res.count == 1)
                {
                    NSNumber *timer_id = [res[0] objectForKey:@"newid"];
                    [timer_param setObject:timer_id forKey:@"_id"];
                    
                }
                else{
                    result=NO;
                    break;
                }

            }
            
            
            
        }else
        {
            result =NO;
        }
        
     
    }else
    {
        result =NO;
    }
    if(result)
    {
        [db endTransaction];    //提交
    }else
    {
        [db rallback];          //回滚
    }
    
    return result;
}


- (void) insertClock:(NSMutableArray *)clock_list
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    
    for(int i =0;i<clock_list.count;i++)
    {
        NSMutableDictionary *temp=clock_list[i];
        NSString * sql =[NSString stringWithFormat:@"insert into %@ (_id,%@,%@,%@,%@,%@,%@) values(%@,'%@','%@','%@','%@','%@','%@');",DB_ALARM_CLOCK,DB_AC_TITLE,DB_AC_CONTENT,DB_AC_START_DATE,DB_AC_EXPIREDOSE,DB_AC_STATE,DB_AC_UPLOAD_STATE,[temp objectForKey:@"_id"],[temp objectForKey:DB_AC_TITLE],[temp objectForKey:DB_AC_CONTENT],[temp objectForKey:DB_AC_START_DATE],[temp objectForKey:DB_AC_EXPIREDOSE],@"1",[temp objectForKey:DB_AC_UPLOAD_STATE]];
        [db execSQl:sql];

        NSString *alarm_time = [temp objectForKey:DB_AT_TIME_STR];
        NSArray *alarms_time =[alarm_time componentsSeparatedByString:@","];
        for(int i =0;i<alarms_time.count;i++)
        {
            NSArray *h_m =[alarms_time[i] componentsSeparatedByString:@":"];
            
            NSDateFormatter * dateFormat =[[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"HH:mm"];
            NSString *time_1 =[dateFormat stringFromDate:[dateFormat dateFromString:alarms_time[i]]];
            
            //qushijianzhi
            sql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@) values('%@','%@','%@','%@','%@');",DB_ALARM_TIME,DB_AT_CLOCK_ID,DB_AT_TIME_STR,DB_AT_HOUR,DB_AT_MINUTE,DB_AT_STATE,[temp objectForKey:@"_id"],time_1,h_m[0],h_m[1],@"1"];
            
            [db execSQl:sql];
        
        }
     
    }
    [db endTransaction];    //提交

}

-(void)insertOnlineClock:(NSMutableArray *)clock_list
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    
    for(int i =0;i<clock_list.count;i++)
    {
        NSMutableDictionary *temp=clock_list[i];
        NSString * sql =[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@) values('%@','%@','%@','%@','%@','%@');",DB_ALARM_CLOCK,DB_AC_TITLE,DB_AC_CONTENT,DB_AC_START_DATE,DB_AC_EXPIREDOSE,DB_AC_STATE,DB_AC_UPLOAD_STATE,[temp objectForKey:DB_AC_TITLE],[temp objectForKey:DB_AC_CONTENT],[temp objectForKey:DB_AC_START_DATE],[temp objectForKey:DB_AC_EXPIREDOSE],@"1",[temp objectForKey:DB_AC_UPLOAD_STATE]];
        [db execSQl:sql];
        NSString *selectSql =[NSString stringWithFormat:@"select last_insert_rowid() as newid from %@;",DB_ALARM_CLOCK];
        NSMutableArray *res=[db select:selectSql,@"newid",@"id",nil];
        if(res.count == 1){
            NSNumber *timer_id = [res[0] objectForKey:@"newid"];
            
            NSString *alarm_time = [temp objectForKey:DB_AT_TIME_STR];
            NSArray *alarms_time =[alarm_time componentsSeparatedByString:@","];
            
            for(int i =0;i<alarms_time.count;i++)
            {
                NSArray *h_m =[alarms_time[i] componentsSeparatedByString:@":"];
            
                NSDateFormatter * dateFormat =[[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"HH:mm"];
                NSString *time_1 =[dateFormat stringFromDate:[dateFormat dateFromString:alarms_time[i]]];
            
                //qushijianzhi
                sql=[NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@) values('%@','%@','%@','%@','%@');",DB_ALARM_TIME,DB_AT_CLOCK_ID,DB_AT_TIME_STR,DB_AT_HOUR,DB_AT_MINUTE,DB_AT_STATE,timer_id,time_1,h_m[0],h_m[1],@"1"];
            
                [db execSQl:sql];
            
            }
        }
        
    }
    [db endTransaction];    //提交
}


-(void)deleteAll
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"delete from %@",DB_ALARM_CLOCK];
    [db execSQl:sql];
    sql =[NSString stringWithFormat:@"delete from %@",DB_ALARM_TIME];
    [db execSQl:sql];
    
    [db endTransaction];    //提交
}

-(void)deleteByClockId:(NSString * )clock_id
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"delete from %@ where _id = %@",DB_ALARM_CLOCK,clock_id];
    [db execSQl:sql];
    sql =[NSString stringWithFormat:@"delete from %@ where %@ = %@",DB_ALARM_TIME,DB_AT_CLOCK_ID,clock_id];
    [db execSQl:sql];
    
    [db endTransaction];    //提交
}

-(void)setClockState:(NSNumber *)_id state:(NSString *)state
{
    DBOpenHelper * db=[[DBOpenHelper getInstance] getConnect];
    [db beginTransaction];
    NSString *sql =[NSString stringWithFormat:@"update  %@ set %@ = ? where _id=?",DB_ALARM_CLOCK,DB_AC_STATE];
    [db updata:sql,state,@"text",_id,@"int"];
    sql =[NSString stringWithFormat:@"update %@ set %@=? where %@ = ?",DB_ALARM_TIME,DB_AT_STATE,DB_AT_CLOCK_ID];
    [db updata:sql,state,@"text",_id,@"int"];
    
    [db endTransaction];    //提交

}

// 设置闹钟过期
-(void)setClockExpire:(NSString *)clock_id
{
    [self setClockState:[NSNumber numberWithInt:[clock_id intValue] ] state:@"2"];
}



@end
