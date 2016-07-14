//
//  BloodSugarDB.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"

#define BLOOD_SUGAR @"blood_sugar"               //血糖
#define AFTER_MEAL @"after_meal"                 //是否饭后
#define RECORD_DATE @"record_date"               //记录日期
#define RECORD_TIME @"record_time"               //记录时间
#define UPLOAD_STATE @"upload_state"             //同步标记

@interface BloodSugarDB : NSObject

+(void)createTable:(BaseDB*)database;
+(NSString*)insert:(BaseDB*)database dic:(NSDictionary*)dic;
+(void)insert:(BaseDB*)dbDriver arr:(NSArray*)arr;

+(void)setUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr;

+(NSMutableSet*)queryState:(BaseDB*)database byYearMonthStr:(NSString*)ymStr;
+(NSMutableArray*)query:(BaseDB*)database byDateStr:(NSString *)dateStr;
+(NSMutableArray*)queryUpload:(BaseDB*)database;
+(NSMutableDictionary*)queryLast:(BaseDB*)dbDriver;
+(NSMutableDictionary*)queryTestTimes:(BaseDB*)dbDriver;
+(int)getCount:(BaseDB*)dbDriver;

+(NSDictionary*)queryRecent:(BaseDB*)dbDriver type:(int)type;
+(NSMutableArray*)queryRecently:(BaseDB*)dbDriver;

@end
