//
//  AppConfig.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/5.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

//判断收缩压是否正常90~140
+(BOOL)isSystolicPressureRegular:(NSString*)systolic_pressure{
    int sp = [systolic_pressure intValue];
    if(sp>=90 && sp<=140){
        return true;
    }else{
        return false;
    }
}

/**
 * 收缩压高于140算不正常
 * @param systolic_pressure
 * @return		返回判断结果：true表示高血压，false表示正常
 */
+(BOOL)isElevatedSystolicPressure:(NSString*)systolic_pressure{
    int sp = [systolic_pressure intValue];
    if(sp>140){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断收缩压是否低血压
 * @param systolic_pressure
 * @return		返回判断结果：true表示低血压，false表示正常
 */
+(BOOL)isHypopiesiaSystolicPressure:(NSString*)systolic_pressure{
    int sp = [systolic_pressure intValue];
    if(sp<90){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断舒张压是否正常60~90
 * @param diastolic_pressure
 * @return		返回判断结果：true表示高血压，false表示正常
 */
+(BOOL)isDiastolicPressureRegular:(NSString*)diastolic_pressure{
    int dp = [diastolic_pressure intValue];
    if(dp>=60 && dp<=90){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断舒张压是否高血压
 * @param diastolic_pressure
 * @return		返回判断结果：true表示高血压，false表示正常
 */
+(BOOL)isElevatedDiastolicPressure:(NSString*)diastolic_pressure{
    int dp = [diastolic_pressure intValue];
    if(dp>90){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断舒张压是否低血压
 * @param diastolic_pressure
 * @return		返回判断结果：true表示低血压，false表示正常
 */
+(BOOL)isHypopiesiaDiastolicPressure:(NSString*)diastolic_pressure{
    int dp = [diastolic_pressure intValue];
    if(dp<60){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断心率是否正常60~100
 * @param heart_rate
 * @return		返回判断结果：true表示正常，false表示不正常
 */
+(BOOL)isHeartRateRegular:(NSString*)heart_rate{
    int h = [heart_rate intValue];
    if(h>=60 && h<=100){
        return true;
    }else{
        return false;
    }
}
/**
 * 判断血糖是否正常
 * @param blood_sugar		血糖的字符串数据
 * @param after_meal		是否饭后，true表示饭后，false表示饭前
 * @return				返回判断结果：true表示正常，false表示高血糖
 */
+(BOOL)isHyperglycaemia:(NSString*)blood_sugar after_meal:(BOOL)after_meal{
    int sp = [blood_sugar intValue];
    if(after_meal){
        if(sp>7.8){
            return true;
        }else{
            return false;
        }
    }else{
        if(sp>6.1){
            return true;
        }else{
            return false;
        }
    }
}
/**
 * 判断是否高血糖
 * @param blood_sugar		血糖
 * @param after_meal		饭前还是饭后
 * @return				返回判断结果：true表示高血糖，false表示正常
 */
+(BOOL)isHyperglycaemia:(NSString*)blood_sugar after_meals:(NSString*)after_meal{
    float sp = [blood_sugar floatValue];
    if([after_meal isEqual:@"true"]){//饭后
        if(sp>7.8){//饭后如果大于7.8的话文字就变红
            return true;
        }else{
            return false;
        }
    }else{
        if(sp>6.1){//饭前大于6.0的文字就变红
            return true;
        }else{
            return false;
        }
    }
}
/**
 * 判断是否低血糖
 * @param blood_sugar		血糖
 * @param after_meal		饭前还是饭后
 * @return				返回判断结果：true表示正常，false表示高血糖
 */
+(BOOL)isGlucopenia:(NSString*)blood_sugar{
    float sp = [blood_sugar floatValue];
    if(sp<2.8){
        return true;
    }else{
        return false;
    }
}

@end
