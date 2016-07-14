//
//  JSONUtil.m
//  Test
//
//  Created by jam on 16/3/30.
//  Copyright © 2016年 jam. All rights reserved.
//

#import "JSONUtil.h"

@implementation JSONUtil

/*   通过Data的JSON数据转换成字典  */
+(NSDictionary *)getJSONObject:(NSData *)data{
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if(error == nil){
        return jsonDictionary;
    }else{
        return nil;
    }
}
/*   通过字符串格式的JSON数据转换成字典  */
+(NSDictionary *)getJSONObjectByString:(NSString *)str{
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if(error == nil){
        return jsonDictionary;
    }else{
        return nil;
    }
}
/*   通过Data的JSON数据转换成转换成list  */
+(NSMutableArray *)getJSONArray:(NSData *)data{
    NSError * error;
    NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if(error == nil){
        return jsonArray;
    }else{
        return nil;
    }
}

@end


@implementation NSString (JSON)

-(NSMutableDictionary *)toJSONObject{
    NSError * error;
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
}
-(NSMutableArray *)toJSONArray{
    NSError * error;
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
}

@end
