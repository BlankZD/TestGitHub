//
//  CommonUtil.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

//系统参数变量
#define IOS9 [[[UIDevice currentDevice]systemVersion] floatValue] >= 9.0
#define IOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0
#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define IOS6 [[[UIDevice currentDevice]systemVersion] floatValue] >= 6.0

@interface CommonUtil : NSObject

+(void)uploadRecord:(NSString*)user_id;

+(void)showAlertView:(NSString*)msg;
+(void)errorAlertView:(NSString*)msg;

@end
