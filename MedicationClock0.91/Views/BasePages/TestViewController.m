//
//  TestViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/13.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "TestViewController.h"

#import "FileFloderList.h"

#import "PatientBloodPressureViewController.h"
#import "PatientBloodSugarViewController.h"
#import "PatientInfoViewController.h"

#import "BloodPressureDetailViewController.h"
#import "BloodSugarDetailViewController.h"
#import "PressureDetailPage2ViewController.h"
#import "MedicationDetailViewController.h"

#import "BaseDB.h"
#import "AlarmClockDB_.h"
#import "MedicationRecordDB_.h"

#import "DateUtil.h"

#import "AlarmViewController.h"
#import "ClockListViewController.h"

#import "MedicationClockViewController.h"
#import "BloodSugarBluetoothViewController.h"

#import "BloodSugarInputViewController.h"

#import "NotificationUtil.h"

@interface TestViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation TestViewController{
    UITableView *_tableView;
    NSArray *_itemDefs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"测试页面"];
    // Do any additional setup after loading the view from its nib.
    //获取状态栏的宽高
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    int statusHeight = rectStatus.size.height;
    //获取导航栏的宽高
    CGRect rectNav = self.navigationController.navigationBar.frame;
    int navHeight = rectNav.size.height;
    //获取屏幕的宽高
    int y0 = statusHeight+navHeight;
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height-y0;
    // Do any additional setup after loading the view, typically from a nib.
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight/2)];
    _tableView.delegate =self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    _itemDefs = @[
                  @{
                      @"title": @"查看崩溃日志",
                      @"subtitle": @"FileFloderList",
                      @"class": FileFloderList.class
                      },
                  @{
                      @"title": @"Test1",
                      @"subtitle": @"MedicationDetailViewController",
                      @"class": MedicationDetailViewController.class
                      },
                  @{
                      @"title": @"Test2",
                      @"subtitle": @"PressureDetailPage2ViewController",
                      @"class": PressureDetailPage2ViewController.class
                      },
                  @{
                      @"title": @"Test3",
                      @"subtitle": @"MedicationClockViewController",
                      @"class": MedicationClockViewController.class
                      },
                  @{
                      @"title": @"Test4",
                      @"subtitle": @"服药闹铃列表",
                      @"class": BloodSugarDetailViewController.class
                      },
                  @{
                      @"title": @"测试闹钟",
                      @"subtitle": @"AlarmViewController",
                      @"class": AlarmViewController.class
                      },
                  @{
                      @"title": @"测试蓝牙",
                      @"subtitle": @"BloodSugarBluetoothViewController",
                      @"class": BloodSugarBluetoothViewController.class
                      }
                  ];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemDefs.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *def = _itemDefs[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = def[@"title"];
    cell.detailTextLabel.text = def[@"subtitle"];
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==1){
//        MedicationDetailViewController *viewController=[[MedicationDetailViewController alloc] init];
//        viewController.paramDic=[NSDictionary dictionaryWithObjectsAndKeys:@"7", @"user_id", @"ls", @"username", nil];
//        [self.navigationController pushViewController:viewController animated:YES];
    }else if(indexPath.row==3){
        ClockListViewController *viewController=[[ClockListViewController alloc] init];
//        viewController.paramDic = [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"user_id", @"ls", @"username", nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if(indexPath.row==4){
        AlarmViewController *viewController= [[AlarmViewController alloc]initWithNibName:@"AlarmViewController" bundle:[NSBundle mainBundle]];
        viewController.infoDict = [NSDictionary dictionaryWithObject:@"19:01" forKey:@"alarm_time"];
        [self presentViewController:viewController animated:YES completion:nil];
    }else{
        NSDictionary *def = _itemDefs[indexPath.row];
        
        Class vcClass = def[@"class"];
        UIViewController *vc = [[vcClass alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)testBtn:(id)sender {
    [NotificationUtil showAllNotification];
}

@end
