//
//  AddBloodSugarViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/26.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AddBloodSugarViewController.h"
#import "BloodSugarInputViewController.h"
#import "BloodSugarBluetoothViewController.h"
#import "BloodSugarDetailViewController.h"
#import "BaseDB.h"
#import "BloodSugarDB.h"

#define SizeScale screenWidth/400

@interface AddBloodSugarViewController ()

@end

@implementation AddBloodSugarViewController{
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏标题
    [self.navigationItem setTitle:@"血糖测量"];
    //初始化操作SQLite的对象
    dbDriver = [[BaseDB alloc]init];
    //初始化视图控件
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic addEntriesFromDictionary:[BloodSugarDB queryLast:dbDriver]];
    [dic addEntriesFromDictionary:[BloodSugarDB queryTestTimes:dbDriver]];
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
    
    UIButton *manualBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth*1/7, y0+screenHeight/12, screenHeight/5, screenHeight/5)];
    [manualBtn setImage:[UIImage imageNamed:@"manual_btn_pressed.png"] forState:UIControlStateNormal];
    [manualBtn addTarget:self action:@selector(manualBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:manualBtn];
    
    UIButton *bluetoothBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth*6/7-screenHeight/5, y0+screenHeight/12, screenHeight/5, screenHeight/5)];
    [bluetoothBtn setImage:[UIImage imageNamed:@"automatic_btn_pressed.png"] forState:UIControlStateNormal];
    [bluetoothBtn addTarget:self action:@selector(bluetoothBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bluetoothBtn];
    
    UIView *betweenLine = [[UIView alloc]initWithFrame:CGRectMake((screenWidth-2)/2, y0+screenHeight*7/120, 2, screenHeight/4)];
    betweenLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:betweenLine];
    UILabel *label1 = [[UILabel alloc]init];
    label1.textColor = [UIColor whiteColor];
    NSString *labelStr1 = @"手动输入";
    label1.text = labelStr1;
    label1.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    //根据文字长度和字体计算文本框的长度
    [label1 setFrame:CGRectMake(screenWidth/32*7, screenHeight/56.8*22, screenWidth/32*8, screenHeight/56.8*4)];
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]init];
    label2.textColor = [UIColor whiteColor];
    NSString *labelStr2 = @"蓝牙输入";
    label2.text = labelStr2;
    label2.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    //根据文字长度和字体计算文本框的长度
    [label2 setFrame:CGRectMake(screenWidth/32*20.5,screenHeight/56.8*22, screenWidth/32*8, screenHeight/56.8*4)];
    [self.view addSubview:label2];
    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight/3, screenWidth, screenHeight/10)];
    centerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    [self.view addSubview:centerView];
    
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, screenWidth, screenHeight/10)];
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    NSString *last_record_date = [dic objectForKey:@"record_date"];
    NSString *last_record_time = [dic objectForKey:@"record_time"];
    if(last_record_date==nil){
        centerLabel.text = [NSString stringWithFormat:@"上次测量时间：无"];
    }else{
        centerLabel.text = [NSString stringWithFormat:@"上次测量时间：%@ %@", last_record_date, last_record_time];
    }
    [centerView addSubview:centerLabel];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight*19/40, screenWidth, screenHeight*3/10)];
    bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    [self.view addSubview:bottomView];
    
    UIFont *font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];    //设置一个字体和文字大小
    CGSize size = CGSizeMake(320,2000);         //设置一个行高上限
    
    UILabel *blood_sugar = [[UILabel alloc]init];
    blood_sugar.textColor = [UIColor whiteColor];
    NSString *blood_sugar_Str = @"血糖：";
    blood_sugar.text = blood_sugar_Str;
    blood_sugar.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize blood_sugar_labelsize = [blood_sugar_Str sizeWithFont:font constrainedToSize:size];
    [blood_sugar setFrame:CGRectMake(20, 30*SizeScale, blood_sugar_labelsize.width, blood_sugar_labelsize.height)];
    [bottomView addSubview:blood_sugar];
    
    UILabel *blood_sugar_value = [[UILabel alloc]init];
    blood_sugar_value.textColor = [UIColor whiteColor];
    NSString *blood_sugar_value_Str = [dic objectForKey:@"blood_sugar"];
    if(blood_sugar_value_Str==nil){
        blood_sugar_value.text = [NSString stringWithFormat:@"- mmol/L"];
    }else{
        blood_sugar_value.text = [NSString stringWithFormat:@"%@mmol/L", blood_sugar_value_Str];
    }
    blood_sugar_value.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize blood_sugar_value_labelsize = [blood_sugar_value.text sizeWithFont:font constrainedToSize:size];
    [blood_sugar_value setFrame:CGRectMake(blood_sugar.frame.origin.x+blood_sugar_labelsize.width, 30*SizeScale, blood_sugar_value_labelsize.width, blood_sugar_value_labelsize.height)];
    [bottomView addSubview:blood_sugar_value];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight/56.8*24.5, screenWidth, 2)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    UILabel *after_meal_label = [[UILabel alloc]init];
    after_meal_label.textColor = [UIColor whiteColor];
    NSString *after_meal_Str = [dic objectForKey:@"after_meal"];
    if([after_meal_Str isEqual:@"false"]){
        after_meal_label.text = @"饭前";
    }else if([after_meal_Str isEqual:@"true"]){
        after_meal_label.text = @"饭后";
    }
    after_meal_label.font = font;
    //根据文字长度和字体计算文本框的长度
    CGSize after_meal_labelsize = [after_meal_label.text sizeWithFont:font constrainedToSize:size];
    [after_meal_label setFrame:CGRectMake(blood_sugar_value.frame.origin.x+blood_sugar_value_labelsize.width+5, 30*SizeScale, after_meal_labelsize.width, after_meal_labelsize.height)];
    [bottomView addSubview:after_meal_label];
    
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
    
    UIButton *recordBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/6, y0+screenHeight*4/5, screenWidth*2/3, 45*SizeScale)];
    recordBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    recordBtn.layer.cornerRadius = 10;
    [recordBtn setTitle:@"最近测量记录" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [recordBtn addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(recordBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(recordBtnCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.view addSubview:recordBtn];
}
-(void)manualBtnClick{
    UIViewController *viewController= [[BloodSugarInputViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)bluetoothBtnClick{
    UIViewController *viewController= [[BloodSugarBluetoothViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)recordBtnClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    UIViewController *viewController= [[BloodSugarDetailViewController alloc] init];
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
