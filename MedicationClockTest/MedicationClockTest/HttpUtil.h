//
//  HttpUtil.h
//  Learn2
//
//  Created by 歐陽 on 16/3/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>

//服务器配置信息
#define ServerIp @"www.xbrjblkj.com"			//服务器IP
#define HttpPort 8124                           //http端口号
#define UdpPort 9997                            //udp端口号
#define ServerName @"BlmemServer2.04"			//服务器端程序的项目名称
#define StoreId 1                               //药店ID
//HTTP端口的IP地址
#define ApacheUrl [NSString stringWithFormat:@"http://%@:%d", ServerIp, HttpPort]
#define AppActionUrl [NSString stringWithFormat:@"%@/%@/appAction", ApacheUrl, ServerName]
#define ClockActionUrl [NSString stringWithFormat:@"%@/%@/medicationClockAction", ApacheUrl, ServerName]
#define UserActionUrl [NSString stringWithFormat:@"%@/%@/appUserAction", ApacheUrl, ServerName]
#define Apache_Res [NSString stringWithFormat:@"%@/BlmemServer2.0_res", ApacheUrl]
#define Image_Res [NSString stringWithFormat:@"%@/Blmem_Image", Apache_Res]

@interface HttpUtil : NSObject

+ (void)httpGet:(NSString*)urlStr callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler;
+ (void)httpPost:(NSString*)urlStr param:(NSString*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler;
+ (void)httpPost:(NSString*)urlStr paramDic:(NSDictionary*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler;

@end
