//
//  FileUtil.h
//  TestLoadImage
//
//  Created by 歐陽 on 16/5/10.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileUtil : NSObject

+(UIImage*)getImageFile:(NSString*)filePath;
+(BOOL)saveImageFile:(UIImage*)image path:(NSString*)filePath;

+(BOOL)saveTxtFile:(NSString*)txtStr path:(NSString*)filePath;
+(NSString*)readTxtFile:(NSString*)filePath;

+(void)createDirs:(NSString*)filePath;
+(NSString*)getFullPath:(NSString*)filePath;
+(NSString*)getAbsolutePath:(NSString*)filePath;

@end
