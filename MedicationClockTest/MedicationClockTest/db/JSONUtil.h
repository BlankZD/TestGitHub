//
//  JSONUtil.h
//  Test
//
//  Created by jam on 16/3/30.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtil : NSObject

/*   通过Data的JSON数据转换成字典  */
+(NSDictionary *)getJSONObject:(NSData *)data;
/*   通过字符串格式的JSON数据转换成字典  */
+(NSDictionary *)getJSONObjectByString:(NSString *)data;/*   通过Data的JSON数据转换成转换成list  */
+(NSMutableArray *)getJSONArray:(NSData *)data;

@end

@interface NSString (JSON)
-(NSMutableDictionary *)toJSONObject;
@end
