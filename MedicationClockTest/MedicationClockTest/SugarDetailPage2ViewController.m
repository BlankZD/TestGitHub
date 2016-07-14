//
//  SugarDetailPage2ViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/14.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "SugarDetailPage2ViewController.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "BloodSugarDB.h"

@interface SugarDetailPage2ViewController ()

@end

@implementation SugarDetailPage2ViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取状态栏的宽高
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    int statusHeight = rectStatus.size.height;
    //获取导航栏的宽高
    CGRect rectNav = self.navigationController.navigationBar.frame;
    int navHeight = rectNav.size.height;
    //获取屏幕的宽高
    y0 = statusHeight+navHeight;
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height-y0;
    // Do any additional setup after loading the view from its nib.
    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    NSDictionary *weekDic = [BloodSugarDB queryRecent:dbDriver type:0];
    NSDictionary *monthDic = [BloodSugarDB queryRecent:dbDriver type:1];
    NSDictionary *yearDic = [BloodSugarDB queryRecent:dbDriver type:2];
    [self initViewWithData_week:weekDic month:monthDic year:yearDic];
}

- (void)initViewWithData_week:(NSDictionary*)weekDic month:(NSDictionary*)monthDic year:(NSDictionary*)yearDic{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.backgroundColor = [UIColor r:246 g:246 b:246];
    scrollView.backgroundColor=[UIColor blueColor];
    scrollView.pagingEnabled = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UIFont *titleFont = [UIFont systemFontOfSize:17];
    
    UILabel *title1Label = [[UILabel alloc]init];
    title1Label.text=@"饭前";
    title1Label.font=[UIFont systemFontOfSize:20];
    title1Label.font=titleFont;
    title1Label.textColor=[UIColor whiteColor];
    [scrollView addSubview:title1Label];
    //根据文字长度和字体计算文本框的长度
    CGSize title1LabelSize = [title1Label.text sizeWithFont:title1Label.font];
    [title1Label setFrame:CGRectMake((screenWidth-title1LabelSize.width)/2, screenHeight/50.0*2, title1LabelSize.width, title1LabelSize.height)];
    //饭前周
    UIView *weeklyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0,screenHeight/50.0*6, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    weeklyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    weeklyReportView.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:weeklyReportView];
    
    UILabel *weeklyReportTitle = [[UILabel alloc]init];
    weeklyReportTitle.text=@"周报告";
    weeklyReportTitle.font=[UIFont systemFontOfSize:17];
    weeklyReportTitle.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportTitle];
    CGSize weeklyReportTitleSize = [weeklyReportTitle.text sizeWithFont:weeklyReportTitle.font];
    [weeklyReportTitle setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0, weeklyReportTitleSize.width, weeklyReportTitleSize.height)];
    
    
    UILabel *weeklyReportAverage = [[UILabel alloc]init];
    NSString *bloor_suger_value_str = [weekDic valueForKey:@"blood_sugar_before_meal_average"];
    if(bloor_suger_value_str==nil){
        weeklyReportAverage.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        weeklyReportAverage.text=[NSString stringWithFormat:@"平均:%@mmol/L", bloor_suger_value_str];
    }
    
    weeklyReportAverage.font=[UIFont systemFontOfSize:12];
    weeklyReportAverage.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportAverage];
    CGSize weeklyReportAverageSize = [weeklyReportAverage.text sizeWithFont:weeklyReportAverage.font];
    [weeklyReportAverage setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*2.8, weeklyReportAverageSize.width, weeklyReportAverageSize.height)];
    
    UILabel *weeklyReportHigh = [[UILabel alloc]init];
    
    NSString *before_high_times_str = [weekDic valueForKey:@"before_meal_times_hyperglycaemia"];
    if(before_high_times_str==nil){
        weeklyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:0次"];
    }else{
        weeklyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:%@次", before_high_times_str];
    }
    
    weeklyReportHigh.font=[UIFont systemFontOfSize:12];
    weeklyReportHigh.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportHigh];
    CGSize weeklyReportHighSize = [weeklyReportHigh.text sizeWithFont:weeklyReportHigh.font];
    [weeklyReportHigh setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*4.3, weeklyReportHighSize.width, weeklyReportHighSize.height)];
    
    
    
    UILabel *weeklyReportLow = [[UILabel alloc]init];
    
    NSString *before_low_times_str = [weekDic valueForKey:@"before_meal_times_hypoglycemia"];
    NSLog(@"before_low_times_str=%@",before_low_times_str);
    if(before_low_times_str==nil){
        weeklyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:0次"];
    }else{
        weeklyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:%@次", before_low_times_str];
    }
    
    weeklyReportLow.font=[UIFont systemFontOfSize:12];
    weeklyReportLow.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportLow];
    CGSize weeklyReportLowSize = [weeklyReportLow.text sizeWithFont:weeklyReportLow.font];
    [weeklyReportLow setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5.8, weeklyReportLowSize.width, weeklyReportLowSize.height)];
    //周状况Lable
    UILabel *weeklyReportZhou = [[UILabel alloc]init];
    weeklyReportZhou.text=@"良好   ";
    weeklyReportZhou.font=[UIFont systemFontOfSize:17];
    weeklyReportZhou.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportZhou];
    CGSize weeklyReportZhouSize = [weeklyReportZhou.text sizeWithFont:weeklyReportLow.font];
    [weeklyReportZhou setFrame:CGRectMake(screenWidth/32.0*22.7, screenWidth/10.0*1.2, weeklyReportZhouSize.width, weeklyReportZhouSize.height)];
    
    UIImageView *imageview1=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*19.4, screenHeight/50.0*4.5, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview1.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview1];
    
    //饭前月
    UIView *mouthlyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0, screenHeight/50.0*18, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    mouthlyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    mouthlyReportView.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:mouthlyReportView];
    //月状况lable
    UIImageView *imageview2=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*0.4,screenHeight/50.0*16.5, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview2.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview2];
    
    
    
    UILabel *mouthlyReportYue = [[UILabel alloc]init];
    mouthlyReportYue.text=@"良好   ";
    mouthlyReportYue.font=[UIFont systemFontOfSize:17];
    mouthlyReportYue.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportYue];
    CGSize mouthlyReportYueSize = [mouthlyReportYue.text sizeWithFont:mouthlyReportYue.font];
    [mouthlyReportYue setFrame:CGRectMake(screenWidth/32.0*3.4, screenWidth/10.0*1.2, mouthlyReportYueSize.width, mouthlyReportYueSize.height)];
    
    
    UILabel *mouthlyReportTitle = [[UILabel alloc]init];
    mouthlyReportTitle.text=@"月报告";
    mouthlyReportTitle.font=[UIFont systemFontOfSize:17];
    mouthlyReportTitle.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportTitle];
    CGSize mouthlyReportTitleSize = [mouthlyReportTitle.text sizeWithFont:mouthlyReportTitle.font];
    [mouthlyReportTitle setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*0.8, mouthlyReportTitleSize.width, mouthlyReportTitleSize.height)];
    
    UILabel *mouthlyReportAverage = [[UILabel alloc]init];
    NSString *mouth_bloor_suger_value_str = [monthDic valueForKey:@"blood_sugar_before_meal_average"];
    if(mouth_bloor_suger_value_str==nil){
        mouthlyReportAverage.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        mouthlyReportAverage.text=[NSString stringWithFormat:@"平均:%@mmol/L", mouth_bloor_suger_value_str];
    }
    
    mouthlyReportAverage.font=[UIFont systemFontOfSize:12];
    mouthlyReportAverage.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportAverage];
    CGSize mouthlyReportAverageSize = [mouthlyReportAverage.text sizeWithFont:mouthlyReportAverage.font];
    [mouthlyReportAverage setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*2.8, mouthlyReportAverageSize.width, mouthlyReportAverageSize.height)];
    
    UILabel *mouthlyReportHigh = [[UILabel alloc]init];
    NSString *month_before_high_times_str = [monthDic valueForKey:@"before_meal_times_hyperglycaemia"];
    if(month_before_high_times_str==nil){
        mouthlyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:0次"];
    }else{
        mouthlyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:%@次", month_before_high_times_str];
    }
    
    
    mouthlyReportHigh.font=[UIFont systemFontOfSize:12];
    mouthlyReportHigh.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportHigh];
    CGSize mouthlyReportHighSize = [mouthlyReportHigh.text sizeWithFont:mouthlyReportHigh.font];
    [mouthlyReportHigh setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*4.3, mouthlyReportHighSize.width, mouthlyReportHighSize.height)];
    
    UILabel * mouthlyReportLow = [[UILabel alloc]init];
    NSString * month_before_low_times_str = [monthDic valueForKey:@"before_meal_times_hypoglycemia"];
    if(month_before_low_times_str==nil){
        mouthlyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:0次"];
    }else{
        mouthlyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:%@次", month_before_low_times_str];
    }
    mouthlyReportLow.font=[UIFont systemFontOfSize:12];
    mouthlyReportLow.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportLow];
    CGSize mouthlyReportLowSize = [mouthlyReportLow.text sizeWithFont:mouthlyReportLow.font];
    [mouthlyReportLow setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*5.8, mouthlyReportLowSize.width, mouthlyReportLowSize.height)];
    //饭前年
    UIView *yearlyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0,screenHeight/50.0*30, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    yearlyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    yearlyReportView.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:yearlyReportView];
    
    UILabel *yearlyReportTitle = [[UILabel alloc]init];
    yearlyReportTitle.text=@"年报告";
    yearlyReportTitle.font=[UIFont systemFontOfSize:17];
    yearlyReportTitle.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportTitle];
    CGSize yearlyReportTitleSize = [yearlyReportTitle.text sizeWithFont:yearlyReportTitle.font];
    [yearlyReportTitle setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0, yearlyReportTitleSize.width, yearlyReportTitleSize.height)];
    
    UILabel *yearlyReportAverage = [[UILabel alloc]init];
    
    NSString * year_bloor_suger_value_str = [yearDic valueForKey:@"blood_sugar_before_meal_average"];
    if(year_bloor_suger_value_str==nil){
        yearlyReportAverage.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        yearlyReportAverage.text=[NSString stringWithFormat:@"平均:%@mmol/L", year_bloor_suger_value_str];
    }
    yearlyReportAverage.font=[UIFont systemFontOfSize:12];
    yearlyReportAverage.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportAverage];
    CGSize yearlyReportAverageSize = [yearlyReportAverage.text sizeWithFont:yearlyReportAverage.font];
    [yearlyReportAverage setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*2.8, yearlyReportAverageSize.width, yearlyReportAverageSize.height)];
    
    UILabel *yearlyReportHigh = [[UILabel alloc]init];
    
    NSString * year_before_high_times_str = [yearDic valueForKey:@"before_meal_times_hyperglycaemia"];
    if(year_before_high_times_str==nil){
        yearlyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:0次"];
    }else{
        yearlyReportHigh.text=[NSString stringWithFormat:@"高于6.1mmol/L:%@次", year_before_high_times_str];
    }
    yearlyReportHigh.font=[UIFont systemFontOfSize:12];
    yearlyReportHigh.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportHigh];
    CGSize yearlyReportHighSize = [yearlyReportHigh.text sizeWithFont:yearlyReportHigh.font];
    [yearlyReportHigh setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*4.3, yearlyReportHighSize.width, yearlyReportHighSize.height)];
    
    UILabel *yearlyReportLow = [[UILabel alloc]init];
    NSString * year_before_low_times_str = [yearDic valueForKey:@"before_meal_times_hypoglycemia"];
    if(year_before_low_times_str==nil){
        yearlyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:0次"];
    }else{
        yearlyReportLow.text=[NSString stringWithFormat:@"低于3.9mmol/L:%@次", year_before_low_times_str];
    }
    yearlyReportLow.font=[UIFont systemFontOfSize:12];
    yearlyReportLow.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportLow];
    CGSize yearlyReportLowSize = [yearlyReportLow.text sizeWithFont:yearlyReportLow.font];
    [yearlyReportLow setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5.8, yearlyReportLowSize.width, yearlyReportLowSize.height)];
    
    ;
    //年状况Lable
    UILabel *yearlyReportZhou = [[UILabel alloc]init];
    yearlyReportZhou.text=@"良好   ";
    yearlyReportZhou.font=[UIFont systemFontOfSize:17];
    yearlyReportZhou.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportZhou];
    CGSize yearlyReportZhouSize = [yearlyReportZhou.text sizeWithFont:yearlyReportLow.font];
    [yearlyReportZhou setFrame:CGRectMake(screenWidth/32.0*22.7, screenWidth/10.0*1.2, yearlyReportZhouSize.width, yearlyReportZhouSize.height)];
    
    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*19.4,screenHeight/50.0*28.5, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview3.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview3];
    
    
    
    
    
    UILabel *title2Label = [[UILabel alloc]init];
    title2Label.text=@"饭后";
    title2Label.font=[UIFont systemFontOfSize:20];
    title2Label.font=titleFont;
    title2Label.textColor=[UIColor whiteColor];
    [scrollView addSubview:title2Label];
    //根据文字长度和字体计算文本框的长度
    CGSize title2LabelSize = [title2Label.text sizeWithFont:title2Label.font];
    [title2Label setFrame:CGRectMake((screenWidth-title2LabelSize.width)/2,screenHeight/50.0*40.5, title2LabelSize.width, title2LabelSize.height)];
    
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
    
    //饭后周
    UIView *weeklyReportView1 = [[UIView alloc]initWithFrame:CGRectMake(15, screenHeight/50.0*44.5, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    weeklyReportView1.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    weeklyReportView1.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:weeklyReportView1];
    
    UILabel *weeklyReportTitle1= [[UILabel alloc]init];
    weeklyReportTitle1.text=@"周报告";
    weeklyReportTitle1.font=[UIFont systemFontOfSize:17];
    weeklyReportTitle1.textColor=[UIColor whiteColor];
    [weeklyReportView1 addSubview:weeklyReportTitle1];
    CGSize weeklyReportTitle1Size = [weeklyReportTitle1.text sizeWithFont:weeklyReportTitle1.font];
    [weeklyReportTitle1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0, weeklyReportTitle1Size.width, weeklyReportTitle1Size.height)];
    
    UILabel *weeklyReportAverage1 = [[UILabel alloc]init];
    NSString *after_bloor_suger_value_str = [weekDic valueForKey:@"blood_sugar_after_meal_average"];
    if(after_bloor_suger_value_str==nil){
        weeklyReportAverage1.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        weeklyReportAverage1.text=[NSString stringWithFormat:@"平均:%@mmol/L", after_bloor_suger_value_str];
    }
    
    weeklyReportAverage1.font=[UIFont systemFontOfSize:12];
    weeklyReportAverage1.textColor=[UIColor whiteColor];
    [weeklyReportView1 addSubview:weeklyReportAverage1];
    CGSize weeklyReportAverage1Size = [weeklyReportAverage1.text sizeWithFont:weeklyReportAverage1.font];
    [weeklyReportAverage1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*3, weeklyReportAverage1Size.width, weeklyReportAverage1Size.height)];
    
    UILabel *weeklyReportHigh1 = [[UILabel alloc]init];
    NSString *after_high_times_str = [weekDic valueForKey:@"after_meal_times_hyperglycaemia"];
    if(after_high_times_str==nil){
        weeklyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:0次"];
    }else{
        weeklyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:%@次", after_high_times_str];
    }
    weeklyReportHigh1.font=[UIFont systemFontOfSize:12];
    weeklyReportHigh1.textColor=[UIColor whiteColor];
    [weeklyReportView1 addSubview:weeklyReportHigh1];
    CGSize weeklyReportHigh1Size = [weeklyReportHigh1.text sizeWithFont:weeklyReportHigh1.font];
    [weeklyReportHigh1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5, weeklyReportHigh1Size.width, weeklyReportHigh1Size.height)];
    
    //周状况Lable
    UILabel *weeklyReportZhou1 = [[UILabel alloc]init];
    weeklyReportZhou1.text=@"良好   ";
    weeklyReportZhou1.font=[UIFont systemFontOfSize:17];
    weeklyReportZhou1.textColor=[UIColor whiteColor];
    [weeklyReportView1 addSubview:weeklyReportZhou1];
    CGSize weeklyReportZhou1Size = [weeklyReportZhou1.text sizeWithFont:weeklyReportHigh1.font];
    [weeklyReportZhou1 setFrame:CGRectMake(screenWidth/32.0*23.2, screenWidth/10.0*1.2, weeklyReportZhou1Size.width, weeklyReportZhou1Size.height)];
    
    UIImageView *imageview11=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*19.4, screenHeight/50.0*43, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview11.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview11];
    
    //饭后月
    
    
    UIView *mouthlyReportView1 = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0, screenHeight/50.0*56.5, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    mouthlyReportView1.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    mouthlyReportView1.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:mouthlyReportView1];
    //月状况lable
    UIImageView *imageview21=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*0.4,screenHeight/50.0*55, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview21.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview21];
    
    UILabel *mouthlyReportYue1 = [[UILabel alloc]init];
    mouthlyReportYue1.text=@"良好   ";
    mouthlyReportYue1.font=[UIFont systemFontOfSize:17];
    mouthlyReportYue1.textColor=[UIColor whiteColor];
    [mouthlyReportView1 addSubview:mouthlyReportYue1];
    CGSize mouthlyReportYue1Size = [mouthlyReportYue1.text sizeWithFont:mouthlyReportYue1.font];
    [mouthlyReportYue1 setFrame:CGRectMake(screenWidth/32.0*3.2, screenWidth/10.0*1.2, mouthlyReportYue1Size.width, mouthlyReportYue1Size.height)];
    
    
    UILabel *mouthlyReportTitle1 = [[UILabel alloc]init];
    mouthlyReportTitle1.text=@"月报告";
    mouthlyReportTitle1.font=[UIFont systemFontOfSize:17];
    mouthlyReportTitle1.textColor=[UIColor whiteColor];
    [mouthlyReportView1 addSubview:mouthlyReportTitle1];
    CGSize mouthlyReportTitle1Size = [mouthlyReportTitle1.text sizeWithFont:mouthlyReportTitle1.font];
    [mouthlyReportTitle1 setFrame:CGRectMake(screenWidth/2.0,screenHeight/50.0, mouthlyReportTitle1Size.width, mouthlyReportTitle1Size.height)];
    
    UILabel *mouthlyReportAverage1 = [[UILabel alloc]init];
    NSString *mouth_bloor_suger_value_str1 = [monthDic valueForKey:@"blood_sugar_after_meal_average"];
    if(mouth_bloor_suger_value_str1==nil){
        mouthlyReportAverage1.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        mouthlyReportAverage1.text=[NSString stringWithFormat:@"平均:%@mmol/L", mouth_bloor_suger_value_str1];
    }
    mouthlyReportAverage1.font=[UIFont systemFontOfSize:12];
    mouthlyReportAverage1.textColor=[UIColor whiteColor];
    [mouthlyReportView1 addSubview:mouthlyReportAverage1];
    CGSize mouthlyReportAverage1Size = [mouthlyReportAverage1.text sizeWithFont:mouthlyReportAverage1.font];
    [mouthlyReportAverage1 setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*3, mouthlyReportAverage1Size.width, mouthlyReportAverage1Size.height)];
    
    UILabel *mouthlyReportHigh1 = [[UILabel alloc]init];
    NSString *after_high_times_str1 = [monthDic valueForKey:@"after_meal_times_hyperglycaemia"];
    if(after_high_times_str1==nil){
        mouthlyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:0次"];
    }else{
        mouthlyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:%@次", after_high_times_str1];
    }
    
    mouthlyReportHigh1.font=[UIFont systemFontOfSize:12];
    mouthlyReportHigh1.textColor=[UIColor whiteColor];
    [mouthlyReportView1 addSubview:mouthlyReportHigh1];
    CGSize mouthlyReportHigh1Size = [mouthlyReportHigh1.text sizeWithFont:mouthlyReportHigh1.font];
    [mouthlyReportHigh1 setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*5, mouthlyReportHigh1Size.width, mouthlyReportHigh1Size.height)];
    
    //饭后年
    UIView *yearlyReportView1 = [[UIView alloc]initWithFrame:CGRectMake(15, screenHeight/50.0*68.5, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    yearlyReportView1.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    yearlyReportView1.layer.cornerRadius = screenWidth/32.0*4.7;
    [scrollView addSubview:yearlyReportView1];
    
    UILabel *yearlyReportTitle1 = [[UILabel alloc]init];
    yearlyReportTitle1.text=@"年报告";
    yearlyReportTitle1.font=[UIFont systemFontOfSize:17];
    yearlyReportTitle1.textColor=[UIColor whiteColor];
    [yearlyReportView1 addSubview:yearlyReportTitle1];
    CGSize yearlyReportTitle1Size = [yearlyReportTitle1.text sizeWithFont:yearlyReportTitle1.font];
    [yearlyReportTitle1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0, yearlyReportTitle1Size.width, yearlyReportTitle1Size.height)];
    
    UILabel *yearlyReportAverage1 = [[UILabel alloc]init];
    NSString *year_bloor_suger_value_str1 = [yearDic valueForKey:@"blood_sugar_after_meal_average"];
    if(year_bloor_suger_value_str1==nil){
        yearlyReportAverage1.text=[NSString stringWithFormat:@"平均:-mmol/L"];
    }else{
        yearlyReportAverage1.text=[NSString stringWithFormat:@"平均:%@mmol/L", year_bloor_suger_value_str1];
    }
    yearlyReportAverage1.font=[UIFont systemFontOfSize:12];
    yearlyReportAverage1.textColor=[UIColor whiteColor];
    [yearlyReportView1 addSubview:yearlyReportAverage1];
    CGSize yearlyReportAverage1Size = [yearlyReportAverage1.text sizeWithFont:yearlyReportAverage1.font];
    [yearlyReportAverage1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*3, yearlyReportAverage1Size.width, yearlyReportAverage1Size.height)];
    
    UILabel *yearlyReportHigh1 = [[UILabel alloc]init];
    NSString *after_high_times_str2 = [yearDic valueForKey:@"after_meal_times_hyperglycaemia"];
    if(after_high_times_str2==nil){
        yearlyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:0次"];
    }else{
        yearlyReportHigh1.text=[NSString stringWithFormat:@"高于11.1mmol/L:%@次", after_high_times_str2];
    }
    yearlyReportHigh1.font=[UIFont systemFontOfSize:12];
    yearlyReportHigh1.textColor=[UIColor whiteColor];
    [yearlyReportView1 addSubview:yearlyReportHigh1];
    CGSize yearlyReportHigh1Size = [yearlyReportHigh1.text sizeWithFont:yearlyReportHigh1.font];
    [yearlyReportHigh1 setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5, yearlyReportHigh1Size.width, yearlyReportHigh1Size.height)];
    
    //年状况Lable
    UILabel *yearlyReportZhou1 = [[UILabel alloc]init];
    yearlyReportZhou1.text=@"良好   ";
    yearlyReportZhou1.font=[UIFont systemFontOfSize:17];
    yearlyReportZhou1.textColor=[UIColor whiteColor];
    [yearlyReportView1 addSubview:yearlyReportZhou1];
    CGSize yearlyReportZhou1Size = [yearlyReportZhou1.text sizeWithFont:yearlyReportHigh1.font];
    [yearlyReportZhou1 setFrame:CGRectMake(screenWidth/32.0*22.7, screenWidth/10.0*1.2, yearlyReportZhou1Size.width, yearlyReportZhou1Size.height)];
    
    UIImageView *imageview31=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*19.4, screenHeight/50.0*67, screenWidth/10.0*4, screenWidth/10.0*4)];
    imageview31.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview31];

    
    scrollView.contentSize = CGSizeMake(0, 1000);
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

@end
