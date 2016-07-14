//
//  BloodPressureDB.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"

#define SYSTOLIC_PRESSURE @"systolic_pressure"               //收缩压
#define DIASTOLIC_PRESSURE @"diastolic_pressure"             //舒张压
#define HEART_RATE @"heart_rate"                             //心率
#define REMARKS @"remarks"                                   //备注
#define RECORD_DATE @"record_date"                           //记录日期
#define RECORD_TIME @"record_time"                           //记录时间
#define UPLOAD_STATE @"upload_state"                         //同步标记

@interface BloodPressureDB : NSObject

+(void)createTable:(BaseDB*)dbDriver;
+(NSString*)insert:(BaseDB*)dbDriver dic:(NSDictionary*)dic;
+(void)insert:(BaseDB*)dbDriver arr:(NSArray*)arr;

+(void)setUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr;

+(NSMutableSet*)queryState:(BaseDB*)dbDriver byYearMonthStr:(NSString*)ymStr;
+(NSArray*)queryUpload:(BaseDB*)dbDriver;
+(NSMutableArray*)query:(BaseDB*)dbDriver byDateStr:(NSString *)dateStr;
+(NSMutableDictionary*)queryLast:(BaseDB*)dbDriver;
+(NSMutableDictionary*)queryTestTimes:(BaseDB*)dbDriver;
+(int)getCount:(BaseDB*)dbDriver;

+(NSDictionary*)queryRecent:(BaseDB*)dbDriver type:(int)type;
+(NSMutableArray*)queryRecently:(BaseDB*)dbDriver;

@end
