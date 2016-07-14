//
//  FileUtil.m
//  TestLoadImage
//
//  Created by 歐陽 on 16/5/10.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+(UIImage*)getImageFile:(NSString*)filePath{
    UIImage* image;
    NSString *imagePath = [FileUtil getAbsolutePath:filePath];
    NSLog(@"getImageFile:%@",imagePath);
    image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+(BOOL)saveImageFile:(UIImage*)image path:(NSString*)filePath{
    NSString *imagePath = [FileUtil getAbsolutePath:filePath];
    NSLog(@"saveImageFile:%@",imagePath);
    [FileUtil createDirs:[imagePath stringByDeletingLastPathComponent]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    BOOL res = [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    return res;
}

//参考资料：http://worldligang.baijia.baidu.com/article/116280
+(BOOL)saveTxtFile:(NSString*)txtStr path:(NSString*)filePath{
    [FileUtil createDirs:[filePath stringByDeletingLastPathComponent]];
    BOOL isSuccess=[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if(isSuccess){
        BOOL res=[txtStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if(res){
            NSLog(@"writesuccess");
            return true;
        }else{
            NSLog(@"writefail");
            return false;
        }
    }else{
        return false;
    }
}
+(NSString*)readTxtFile:(NSString*)filePath{
    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return content;
}

+(void)createDirs:(NSString*)filePath{
    // 判断文件夹是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //如果不存在，则创建文件夹
        BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
//        NSAssert(bo,@"创建目录失败");
        if(res){
            NSLog(@"创建目录成功");
        }else{
            NSLog(@"创建目录失败");
        }
    }else{
        NSLog(@"FileDir is exists.");
    }
}

+(void)deleteFile:(NSString*)filePath{
    
}

+(void)deleteFolder:(NSString*)folderPath{
    
}

+(NSString*)getFullPath:(NSString*)filePath{
    //读取沙盒路径
    NSString *path_sandox = NSHomeDirectory();
    //设置图片的存储路径
    NSString *fullPath = [path_sandox stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",filePath]];
    return fullPath;
}

+(NSString*)getAbsolutePath:(NSString*)filePath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *docPaths = [paths objectAtIndex:0];
    NSString *absolutePath = [docPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];
    return absolutePath;
}

@end
