//
//  CommonUtil.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "CommonUtil.h"

#import "HttpUtil.h"

#import "AlarmClockDB_.h"
#import "MedicationRecordDB_.h"
#import "BloodPressureDB.h"
#import "BloodSugarDB.h"
#import "BaseDB.h"

@implementation CommonUtil

+(void)uploadRecord:(NSString*)user_id{
    
    BaseDB *dbDriver = [[BaseDB alloc]init];
    //读取未同步的血糖测量记录
    NSArray *sugarArr = [BloodSugarDB queryUpload:dbDriver];
    NSLog(@"sugarArr=%@",sugarArr);
    //读取未同步的血压测量记录
    NSArray *pressureArr = [BloodPressureDB queryUpload:dbDriver];
    NSLog(@"pressureArr=%@",pressureArr);
    //读取未同步的服药闹钟
    NSArray *clockArr = [AlarmClockDB_ queryUpload:dbDriver];
    NSLog(@"clockArr=%@",clockArr);
    //读取未同步的服药记录数据
    NSArray *medicationRecordArr = [MedicationRecordDB_ queryRecordUpload:dbDriver];
    NSLog(@"medicationRecordArr=%@",medicationRecordArr);
    NSArray *medicationDetailArr = [MedicationRecordDB_ queryDetailUpload:dbDriver];
    NSLog(@"medicationDetailArr=%@",medicationDetailArr);
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    if(sugarArr.count){
        [paramDic setObject:sugarArr forKey:@"sugarRecord"];
    }
    if(pressureArr.count){
        [paramDic setObject:pressureArr forKey:@"pressureRecord"];
    }
    if(clockArr.count){
        [paramDic setObject:clockArr forKey:@"alarmClock"];
    }
    if(medicationRecordArr.count){
        [paramDic setObject:medicationRecordArr forKey:@"medicationRecord"];
    }
    if(medicationDetailArr.count){
        [paramDic setObject:medicationDetailArr forKey:@"medicationDetail"];
    }
    
    if(paramDic.count==0){
        return;
    }
    [paramDic setValue:user_id forKey:@"user_id"];
    NSString *uploadUrl = [NSString stringWithFormat:@"%@!uploadRecord.ac", ClockActionUrl];
    [HttpUtil httpPost:uploadUrl paramDic:paramDic callbackHandler:^(NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            //解析json格式数据
            NSError *error;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if(error == nil){       //如果json解析正确
                //修改服药闹钟的传输状态
                NSArray *alarmClockIdArray = jsonDictionary[@"alarmClockIdArray"];
                [AlarmClockDB_ setUploaded:dbDriver arr:alarmClockIdArray];
                //修改服药记录的传输状态
                NSArray *medicationRecordIdArray = jsonDictionary[@"medicationRecordIdArray"];
                NSArray *medicationDetailIdArray = jsonDictionary[@"medicationDetailIdArray"];
                [MedicationRecordDB_ setRecordUploaded:dbDriver arr:medicationRecordIdArray];
                [MedicationRecordDB_ setDetailUploaded:dbDriver arr:medicationDetailIdArray];
                //修改血压血糖的传输状态
                NSArray *sugarRecordIdArray = jsonDictionary[@"sugarRecordIdArray"];
                NSArray *pressureRecordIdArray = jsonDictionary[@"pressureRecordIdArray"];
                [BloodSugarDB setUploaded:dbDriver arr:sugarRecordIdArray];
                [BloodPressureDB setUploaded:dbDriver arr:pressureRecordIdArray];
            }else{
                //否则显示错误信息
                NSLog(@"error=%@", error);
                NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"receiveStr=%@", receiveStr);
            }
        }else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }else if (error != nil){
            NSLog(@"Error happened = %@",error);
        }
    }];
    
//    String uploadUrl = Const.clockActionUrl+"!uploadRecord.ac";
//    Map<String, String> param = new HashMap<String, String>();
//    //读取未同步的血糖测量记录
//    List<Map<String, String>> sugar_list = BloodSugarRecordDB.getInstance().queryUpload();
//    if(sugar_list!=null && sugar_list.size()>0){//如果有血糖记录的话
//        //	        JSONArray sugarArray = new JSONArray(sugar_list);//JSONArray
//        JSONArray sugarArray = new JSONArray();
//        for(Map<String, String> temp : sugar_list){//
//            JSONObject jsonObject = new JSONObject(temp);//转成JsonObject
//            sugarArray.put(jsonObject);//放到JsonArray里面
//        }
//        param.put("sugarRecord", sugarArray.toString());//血糖纪录
//    }
//    //读取未同步的血压测量记录
//    List<Map<String, String>> pressure_list = BloodPressureRecordDB.getInstance().queryUpload();
//    if(pressure_list!=null && pressure_list.size()>0){
//        //        	JSONArray pressureArray = new JSONArray(pressure_list);
//        JSONArray pressureArray = new JSONArray();
//        for(Map<String, String> temp : pressure_list){
//            JSONObject jsonObject = new JSONObject(temp);
//            pressureArray.put(jsonObject);
//        }
//        param.put("pressureRecord", pressureArray.toString());
//    }
//    //读取未同步的服药闹钟
//    List<Map<String, String>> alarm_clock_list = AlarmClockDB.getInstance().queryRecordUpload();
//    if(alarm_clock_list!=null && alarm_clock_list.size()>0){
//        //	        JSONArray jsonArray = new JSONArray(alarm_clock_list);
//        JSONArray jsonArray = new JSONArray();
//        for(Map<String, String> temp : alarm_clock_list){
//            JSONObject jsonObject = new JSONObject(temp);
//            jsonArray.put(jsonObject);
//        }
//        param.put("alarmClock", jsonArray.toString());
//    }
//    //读取未同步的服药记录数据
//    List<Map<String, String>> medication_record_list = MedicationRecordDB.getInstance().queryRecordUpload();
//    if(medication_record_list!=null && medication_record_list.size()>0){
//        //	        JSONArray jsonArray = new JSONArray(medication_record_list);
//        JSONArray jsonArray = new JSONArray();
//        for(Map<String, String> temp : medication_record_list){
//            JSONObject jsonObject = new JSONObject(temp);
//            jsonArray.put(jsonObject);
//        }
//        param.put("medicationRecord", jsonArray.toString());
//    }
//    List<Map<String, String>> medication_detail_list = MedicationRecordDB.getInstance().queryDetailUpload();
//    if(medication_detail_list!=null && medication_detail_list.size()>0){
//        //	        JSONArray jsonArray = new JSONArray(medication_detail_list);
//        JSONArray jsonArray = new JSONArray();
//        for(Map<String, String> temp : medication_detail_list){
//            JSONObject jsonObject = new JSONObject(temp);
//            jsonArray.put(jsonObject);
//        }
//        param.put("medicationDetail", jsonArray.toString());
//    }
//    if(param.size()>0){
//        param.put("user_id", user_id);
//        Handler uploadHandler = new Handler(){
//            @Override
//            public void handleMessage(Message msg) {
//                int httpState = msg.what;
//                String result = msg.obj+"";
//                if(httpState==0){
//                    try {
//                        JSONObject jsonObject = new JSONObject(result);
//                        //修改服药闹钟的传输状态
//                        JSONArray alarmClockIdArray = jsonObject.optJSONArray("alarmClockIdArray");
//                        List<String> alarm_clock_id_list = new ArrayList<String>();
//                        for(int i=0;i<alarmClockIdArray.length();i++){
//                            alarm_clock_id_list.add(alarmClockIdArray.getString(i));
//                        }
//                        AlarmClockDB.getInstance().setUploaded(alarm_clock_id_list);
//                        //修改服药记录的传输状态
//                        JSONArray medicationRecordIdArray = jsonObject.optJSONArray("medicationRecordIdArray");
//                        JSONArray medicationDetailIdArray = jsonObject.optJSONArray("medicationDetailIdArray");
//                        List<String> medication_record_id_list = new ArrayList<String>();
//                        for(int i=0;i<medicationRecordIdArray.length();i++){
//                            medication_record_id_list.add(medicationRecordIdArray.getString(i));
//                        }
//                        List<String> medication_detail_id_list = new ArrayList<String>();
//                        for(int i=0;i<medicationDetailIdArray.length();i++){
//                            medication_detail_id_list.add(medicationDetailIdArray.getString(i));
//                        }
//                        MedicationRecordDB.getInstance().setRecordUploaded(medication_record_id_list);
//                        MedicationRecordDB.getInstance().setDetailUploaded(medication_detail_id_list);
//                        //修改血压血糖的传输状态
//                        JSONArray sugarRecordIdArray = jsonObject.optJSONArray("sugarRecordIdArray");
//                        JSONArray pressureRecordIdArray = jsonObject.optJSONArray("pressureRecordIdArray");
//                        List<String> sugar_id_list = new ArrayList<String>();
//                        for(int i=0;i<sugarRecordIdArray.length();i++){
//                            sugar_id_list.add(sugarRecordIdArray.getString(i));
//                        }
//                        List<String> pressure_id_list = new ArrayList<String>();
//                        for(int i=0;i<pressureRecordIdArray.length();i++){
//                            pressure_id_list.add(pressureRecordIdArray.getString(i));
//                        }
//                        BloodSugarRecordDB.getInstance().setUploaded(sugar_id_list);
//                        BloodPressureRecordDB.getInstance().setUploaded(pressure_id_list);
//                    } catch (JSONException e) {
//                        e.printStackTrace();
//                    }
//                }else{
//                    CommonUtil.showToast(result);
//                }
//            }
//        };
//        HttpUtil.postFromUrl(uploadHandler, uploadUrl, param);
    
}

+(void)showAlertView:(NSString*)msg{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
+(void)errorAlertView:(NSString*)msg{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"异常" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
