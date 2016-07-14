//
//  MedicationRecordDB_.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"


#define CLOCK_ID @"clock_id"                                  //闹钟id
#define TITLE @"title"                                        //服药标题
#define RECORD_DATE @"date"                                   //服药日期
#define ALARM_TIMES @"alarm_times"                            //闹铃次数
#define MEDICATION_STATE @"medication_state"                  //服药次数
#define RECORD_UPLOAD_STATE @"record_upload_state"            //与服务器同步的状态

#define RECORD_ID @"record_id"                            //总记录id
#define MEDICATION_TIME @"time"                                      //服药时间
#define DETAILS_UPLOAD_STATE @"details_upload_state"      //与服务器同步的状态

@interface MedicationRecordDB_ : NSObject

+ (void)createTable:(BaseDB*)dbDriver;
+ (void)insertRecordArray:(BaseDB*)dbDriver arr:(NSArray*)arr;
+ (void)insertDetailArray:(BaseDB*)dbDriver arr:(NSArray*)arr;
+ (NSString*)insertDetail:(BaseDB*)dbDriver dic:(NSDictionary*)dic;
+ (NSString*)insertByDate:(BaseDB*)dbDriver dic:(NSDictionary*)dic;

+(void)setRecordUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr;
+(void)setDetailUploaded:(BaseDB*)dbDriver arr:(NSArray*)arr;

+ (NSMutableArray*)queryRecordByDate:(BaseDB*)dbDriver dateStr:(NSString*)dateStr;
+ (NSMutableArray*)queryDetailsByClockIdAndDate:(BaseDB*)dbDriver clockId:(NSString*)clockId dateStr:(NSString*)dateStr;
+ (NSMutableArray*)queryDetailsByRecordId:(BaseDB*)dbDriver recordId:(NSString*)recordId;
+ (NSMutableSet*)queryState:(BaseDB*)dbDriver byYearMonthStr:(NSString*)ymStr;

+ (NSArray*)queryRecently:(BaseDB*)dbDriver clockId:(NSString*)clockId;
+ (NSString*)queryRecently:(BaseDB*)dbDriver clockId:(NSString*)clockId dateStr:(NSString*)dateStr;
+ (NSMutableDictionary*)queryReport:(BaseDB*)dbDriver byType:(int)type clockId:(NSString*)clockId dateStr:(NSString*)dateStr;

+(int)getRecordCount:(BaseDB*)dbDriver;
+(int)getDetailCount:(BaseDB*)dbDriver;

+(NSArray*)queryRecordUpload:(BaseDB*)dbDriver;
+(NSArray*)queryDetailUpload:(BaseDB*)dbDriver;

@end
