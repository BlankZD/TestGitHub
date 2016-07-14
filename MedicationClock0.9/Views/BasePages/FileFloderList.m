//
//  FileFloderList.m
//  TestLoadImage
//
//  Created by 歐陽 on 16/5/11.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "FileFloderList.h"
#import "TxtViewController.h"

@interface FileFloderList ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation FileFloderList{
    UITableView *_tableView;
    NSMutableArray * fileList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height;
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _tableView.delegate =self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    NSString *path_sandox = NSHomeDirectory();
    [self getFiles:path_sandox];
}

-(void)getFiles:(NSString*)filePath{
//    NSString *floderName = [filePath substringFromIndex:[filePath indexOfAccessibilityElement:@""]];
    NSString *floderName = [filePath lastPathComponent];
    [self setTitle:floderName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *fileNameList = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    if(fileList==nil){
        fileList = [[NSMutableArray alloc]init];
    }
    [fileList removeAllObjects];
    [fileList addObject:@{@"fileName":@"返回上一层目录",@"filePath":[filePath stringByDeletingLastPathComponent]}];
    for(NSString *fileName in fileNameList){
        NSDictionary *fileDic = @{
            @"fileName":fileName,
            @"filePath":[filePath stringByAppendingPathComponent:fileName]
        };
        [fileList addObject:fileDic];
    }
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return fileList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *fileDic = fileList[indexPath.row];
    NSString *fileName = fileDic[@"fileName"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = fileName;
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *fileDic = fileList[indexPath.row];
//    NSString *fileName = fileDic[@"fileName"];
    NSString *filePath = fileDic[@"filePath"];
    BOOL isdir;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isdir];
    if(isdir){
        [self getFiles:filePath];
    }else{
        // 获得文件的后缀名（不带'.'）
        NSString *exestr = [filePath pathExtension];
        if([exestr isEqualToString:@"txt"]){
            TxtViewController *viewController = [[TxtViewController alloc]init];
            viewController.fileDic=fileDic;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            NSLog(@"无法打开的文件");
        }
    }
}

@end
