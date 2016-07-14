//
//  ImageUtil.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/10.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ImageUtil.h"

@interface ImageUtil()

@property (strong, nonatomic) NSCache *imageCache;

@end

static NSOperationQueue *queue;
static NSCache *imageCache;
@implementation ImageUtil

//静态构造函数，初始化一些静态变量
+(void)initialize{
    NSLog(@"initialize");
    queue = [[NSOperationQueue alloc] init];
    imageCache = [[NSCache alloc] init];
}

+ (UIImage*)loadImage:(NSString*)urlStr{
    NSURL *url=[NSURL URLWithString:urlStr];
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    return img;
}

+ (void)loadImage:(NSString*)urlStr callbackHandler:(void (^)(NSData *imgData))callbackHandler{
    NSURL *url=[NSURL URLWithString:urlStr];
    [queue addOperationWithBlock:^() {
        NSData *imgData = [NSData dataWithContentsOfURL:url];
//        callbackHandler(imgData);
        dispatch_async(dispatch_get_main_queue(), ^{
            //在UI线程（主线程）中调用回调函数
            callbackHandler(imgData);
        });
    }];
}

@end
