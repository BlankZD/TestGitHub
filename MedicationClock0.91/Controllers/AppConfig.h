//
//  AppConfig.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+(BOOL)isSystolicPressureRegular:(NSString*)systolic_pressure;
+(BOOL)isElevatedSystolicPressure:(NSString*)systolic_pressure;
+(BOOL)isHypopiesiaSystolicPressure:(NSString*)systolic_pressure;
+(BOOL)isDiastolicPressureRegular:(NSString*)diastolic_pressure;
+(BOOL)isElevatedDiastolicPressure:(NSString*)diastolic_pressure;
+(BOOL)isHypopiesiaDiastolicPressure:(NSString*)diastolic_pressure;
+(BOOL)isHeartRateRegular:(NSString*)heart_rate;
+(BOOL)isHyperglycaemia:(NSString*)blood_sugar after_meal:(BOOL)after_meal;
+(BOOL)isHyperglycaemia:(NSString*)blood_sugar after_meals:(NSString*)after_meal;
+(BOOL)isGlucopenia:(NSString*)blood_sugar;

@end
