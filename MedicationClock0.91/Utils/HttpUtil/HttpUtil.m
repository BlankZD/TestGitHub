//
//  HttpUtil.m
//  Learn2
//
//  Created by 歐陽 on 16/3/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "HttpUtil.h"

//定义宏
#define Timeout_Interval 10        //访问http网络请求默认超时时间/秒

@implementation HttpUtil

+ (void)httpGet:(NSString*)urlStr callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    NSLog(@"\nget访问网络：%@", urlStr);
    [self httpGetBefore8_0:urlStr callbackHandler:callbackHandler];
}
+ (void)httpGetBefore8_0:(NSString*)urlStr callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:urlStr];
    //第二步，创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:Timeout_Interval];
    [request setHTTPMethod:@"GET"];//设置请求方式为GET，默认为GET
    //创建回调函数
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        //调用自定义回调函数
        callbackHandler(data, error);
    };
    //连接服务器（使用NSOperationQueue的方式）
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completionHandler];
}

+ (void)httpPost:(NSString*)urlStr param:(NSString*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    NSLog(@"\npost访问网络：%@ params：%@", urlStr, params);
    [self httpPostBefore8_0:urlStr param:params callbackHandler:callbackHandler];
//    [self httpPostIn8_0:urlStr param:params callbackHandler:callbackHandler];
}

+ (void)httpPost:(NSString*)urlStr paramDic:(NSDictionary*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    NSLog(@"\npost访问网络：%@ paramDic：%@", urlStr, params);
    NSString *paramStr = [[NSString alloc]init];
    int i=0;
    for (NSString *key in params) {
        paramStr=[paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
        i++;
        if(i<params.count){
            paramStr=[paramStr stringByAppendingString:@"&"];
        }
    }
    [self httpPostBefore8_0:urlStr param:paramStr callbackHandler:callbackHandler];
//    [self httpPostIn8_0:urlStr param:paramStr callbackHandler:callbackHandler];
}

+ (void)httpPostBefore8_0:(NSString*)urlStr param:(NSString*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:urlStr];
    //第二步，创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:Timeout_Interval];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    //设置要发送的正文内容（适用于Post请求）
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //创建回调函数
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        //调用自定义回调函数
        callbackHandler(data, error);
    };
    //连接服务器（使用NSOperationQueue的方式）
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completionHandler];
}
+ (void)httpPostIn8_0:(NSString*)urlStr param:(NSString*)params callbackHandler:(void (^)(NSData *data, NSError *error))callbackHandler{
    //创建Url
    NSURL *url = [NSURL URLWithString:urlStr];
    //创建http访问请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置访问的函数
    [request setHTTPMethod:@"POST"];
    //设置要发送的正文内容（适用于Post请求）
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //创建session
    NSURLSession *session = [NSURLSession sharedSession];
    //创建回调函数
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData* data, NSURLResponse* response, NSError* error) {
        //调用自定义回调函数
        callbackHandler(data, error);
    };
    //调用task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

@end
