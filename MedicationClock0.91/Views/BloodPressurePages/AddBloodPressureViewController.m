//
//  AddBloodPressureViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/26.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AddBloodPressureViewController.h"
#import "BloodPressureInputViewController.h"
#import "BloodPressureBluetoothViewController.h"
#import "BloodPressureDetailViewController.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "BloodPressureDB.h"

#define SizeScale screenWidth/450

@interface AddBloodPressureViewController ()

@end

@implementation AddBloodPressureViewController{
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏标题
    [self.navigationItem setTitle:@"血压测量"];
    self.view.backgroundColor = [UIColor myBgColor];
    //初始化操作SQLite的对象
    dbDriver = [[BaseDB alloc]init];
    //初始化视图控件
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic addEntriesFromDictionary:[BloodPressureDB queryLast:dbDriver]];
    [dic addEntriesFromDictionary:[BloodPressureDB queryTestTimes:dbDriver]];
    [self initView:dic];
}

//自定义封装的初始化视图控件的函数
-(void)initView:(NSMutableDictionary*)dic{
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
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0, screenWidth,  screenHeight+y0)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    
    UIButton *manualBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/7, y0+screenHeight/12, screenHeight/6, screenHeight/6)];
    [manualBtn setImage:[UIImage imageNamed:@"manual_btn_normal.png"] forState:UIControlStateNormal];
    [manualBtn addTarget:self action:@selector(manualBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:manualBtn];
    
    UIButton *bluetoothBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth*6/7-screenHeight/6, y0+screenHeight/12, screenHeight/6, screenHeight/6)];
    [bluetoothBtn setImage:[UIImage imageNamed:@"automatic_btn_normal.png"] forState:UIControlStateNormal];
    [bluetoothBtn addTarget:self action:@selector(bluetoothBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bluetoothBtn];
    
    UIView *betweenLine = [[UIView alloc]initWithFrame:CGRectMake((screenWidth-2)/2, y0+screenHeight/12, 2, screenHeight/6)];
    betweenLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:betweenLine];
    
    UILabel *label1 = [[UILabel alloc]init];
    label1.textColor = [UIColor whiteColor];
    NSString *labelStr1 = @"手动输入";
    label1.text = labelStr1;
    label1.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    //根据文字长度和字体计算文本框的长度
    [label1 setFrame:CGRectMake(screenWidth/32*6.5, y0+screenHeight/13+screenHeight/6, screenWidth/32*8, screenHeight/56.8*4)];
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]init];
    label2.textColor = [UIColor whiteColor];
    NSString *labelStr2 = @"蓝牙输入";
    label2.text = labelStr2;
    label2.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    //根据文字长度和字体计算文本框的长度
    [label2 setFrame:CGRectMake(screenWidth/2+screenWidth/7,y0+screenHeight/13+screenHeight/6, screenWidth/32*8, screenHeight/56.8*4)];
    [self.view addSubview:label2];

    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight/3, screenWidth, screenHeight/10)];
    centerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    [self.view addSubview:centerView];
    
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, screenWidth, screenHeight/10)];
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    NSString *last_record_date = [dic objectForKey:@"record_date"];
    NSString *last_record_time = [dic objectForKey:@"record_time"];
    if(last_record_date==nil){
        centerLabel.text = @"上次测量时间：无";
    }else{
        centerLabel.text = [[NSString alloc]initWithFormat:@"上次测量时间：%@ %@", last_record_date, last_record_time];
    }
    [centerView addSubview:centerLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight/56.8*24.5, screenWidth, 2)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight*19/40, screenWidth, screenHeight*3/12)];
    bottomView.backgroundColor = [UIColor clearColor];
    //bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    [self.view addSubview:bottomView];
    
    UIFont *font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];    //设置一个字体和文字大小
    CGSize size = CGSizeMake(320,2000);         //设置一个行高上限
    
    UILabel *systolic_pressure = [[UILabel alloc]init];
    systolic_pressure.textColor = [UIColor whiteColor];
    systolic_pressure.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    NSString *systolic_pressure_str = [dic objectForKey:@"systolic_pressure"];
    if(systolic_pressure_str==nil){
        systolic_pressure.text = @"收缩压：-mmHg";
    }else{
        systolic_pressure.text = [[NSString alloc]initWithFormat:@"收缩压：%@mmHg", systolic_pressure_str];
    }
    //根据文字长度和字体计算文本框的长度
    CGSize sp_labelsize = [systolic_pressure.text sizeWithFont:font constrainedToSize:size];
    [systolic_pressure setFrame:CGRectMake(20, 12*SizeScale, sp_labelsize.width, sp_labelsize.height)];
    [bottomView addSubview:systolic_pressure];
    
    UILabel *diastolic_pressure = [[UILabel alloc]init];
    diastolic_pressure.textColor = [UIColor whiteColor];
    diastolic_pressure.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    NSString *diastolic_pressure_str = [dic objectForKey:@"diastolic_pressure"];
    if(diastolic_pressure_str==nil){
        diastolic_pressure.text = @"舒张压：-mmHg";
    }else{
        diastolic_pressure.text = [[NSString alloc]initWithFormat:@"舒张压：%@mmHg", diastolic_pressure_str];
    }
    //根据文字长度和字体计算文本框的长度
    CGSize dp_labelsize = [diastolic_pressure.text sizeWithFont:font constrainedToSize:size];
    [diastolic_pressure setFrame:CGRectMake(systolic_pressure.frame.origin.x+sp_labelsize.width+15*SizeScale, 12*SizeScale, dp_labelsize.width, dp_labelsize.height)];
    [bottomView addSubview:diastolic_pressure];
    
    UILabel *heart_rate = [[UILabel alloc]init];
    heart_rate.textColor = [UIColor whiteColor];
    heart_rate.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    NSString *heart_rate_str = [dic objectForKey:@"heart_rate"];
    if(heart_rate_str==nil){
        heart_rate.text = @"心    率：-mmHg";
    }else{
        heart_rate.text = [[NSString alloc]initWithFormat:@"心   率：%@mmHg", heart_rate_str];
    }
    //根据文字长度和字体计算文本框的长度
    CGSize hr_labelsize = [diastolic_pressure.text sizeWithFont:font constrainedToSize:size];
    [heart_rate setFrame:CGRectMake(20, 40*SizeScale, hr_labelsize.width*1.5, hr_labelsize.height)];
    [bottomView addSubview:heart_rate];
    
    UILabel *label11 = [[UILabel alloc]init];
    label11.textColor = [UIColor whiteColor];
    NSString *labelStr11 = @"测量次数";
    label11.text = labelStr11;
    label11.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize11 = [labelStr11 sizeWithFont:font constrainedToSize:size];
    [label11 setFrame:CGRectMake(20, 90*SizeScale, labelsize11.width, labelsize11.height)];
    [bottomView addSubview:label11];
    
    UILabel *label12 = [[UILabel alloc]init];
    label12.textColor = [UIColor whiteColor];
    NSString *record_times = [dic objectForKey:@"record_times"];
    NSString *labelStr12 = [[NSString alloc]initWithFormat:@"%@次", record_times];
    label12.text = labelStr12;
    label12.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize12 = [labelStr12 sizeWithFont:font constrainedToSize:size];
    [label12 setFrame:CGRectMake(label11.frame.origin.x, 115*SizeScale, labelsize12.width, labelsize12.height)];
    [bottomView addSubview:label12];
    
    UILabel *label21 = [[UILabel alloc]init];
    label21.textColor = [UIColor whiteColor];
    NSString *labelStr21 = @"正常次数";
    label21.text = labelStr21;
    label21.font = font;
    CGSize labelsize21 = [labelStr21 sizeWithFont:font constrainedToSize:size];
    [label21 setFrame:CGRectMake((screenWidth-labelsize21.width)/2, 90*SizeScale, labelsize21.width, labelsize21.height)];
    [bottomView addSubview:label21];
    
    UILabel *label22 = [[UILabel alloc]init];
    label22.textColor = [UIColor whiteColor];
    NSString *normal_times = [[NSString alloc]initWithFormat:@"%d", [record_times intValue]-[[dic objectForKey:@"abnormal_times"] intValue]];
    NSString *labelStr22 = [[NSString alloc]initWithFormat:@"%@次", normal_times];
    label22.text = labelStr22;
    label22.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize22 = [labelStr22 sizeWithFont:font constrainedToSize:size];
    [label22 setFrame:CGRectMake(label21.frame.origin.x, 115*SizeScale, labelsize22.width, labelsize22.height)];
    [bottomView addSubview:label22];
    
    UILabel *label31 = [[UILabel alloc]init];
    label31.textColor = [UIColor whiteColor];
    NSString *labelStr31 = @"异常次数";
    label31.text = labelStr31;
    label31.font = font;
    CGSize labelsize31 = [labelStr31 sizeWithFont:font constrainedToSize:size];
    [label31 setFrame:CGRectMake(screenWidth-30-60, 90*SizeScale, labelsize31.width, labelsize31.height)];
    [bottomView addSubview:label31];
    
    UILabel *label32 = [[UILabel alloc]init];
    label32.textColor = [UIColor whiteColor];
    NSString *abnormal_times = [dic objectForKey:@"abnormal_times"];
    NSString *labelStr32 = [[NSString alloc]initWithFormat:@"%@次", abnormal_times];
    label32.text = labelStr32;
    label32.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize32 = [labelStr32 sizeWithFont:font constrainedToSize:size];
    [label32 setFrame:CGRectMake(label31.frame.origin.x, 115*SizeScale, labelsize32.width, labelsize32.height)];
    [bottomView addSubview:label32];
    
    UIButton *recordBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-screenWidth/32*24)/2, y0+screenHeight*4/5, screenWidth/32*24, 45*SizeScale)];
    recordBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    recordBtn.layer.cornerRadius = 10;
    [recordBtn setTitle:@"最近血压记录" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [recordBtn addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(recordBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(recordBtnCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.view addSubview:recordBtn];
}
-(void)manualBtnClick{
    UIViewController *viewController= [[BloodPressureInputViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)bluetoothBtnClick{
    UIViewController *viewController= [[BloodPressureBluetoothViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)recordBtnClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    UIViewController *viewController= [[BloodPressureDetailViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)recordBtnPressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
}
-(void)recordBtnCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
