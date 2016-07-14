//
//  ImageUtil.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/10.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUtil : NSObject

+ (UIImage*)loadImage:(NSString*)urlStr;
+ (void)loadImage:(NSString*)urlStr callbackHandler:(void (^)(NSData *imgData))callbackHandler;

@end
