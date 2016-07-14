//
//  MedicationDetailPage2.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/29.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "MedicationDetailPage2.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "MedicationRecordDB_.h"

@interface MedicationDetailPage2 ()

@end

@implementation MedicationDetailPage2{
    int screenWidth;
    int screenHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor myBgColor];
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height;
    
    NSLog(@"super.paramDic=%@",super.paramDic);
    NSString *clockId = [super.paramDic valueForKey:CLOCK_ID];
    NSString *dateStr = [super.paramDic valueForKey:RECORD_DATE];
    
    BaseDB *dbDriver = [[BaseDB alloc]init];
    NSDictionary *weekDic = [MedicationRecordDB_ queryReport:dbDriver byType:0 clockId:clockId dateStr:dateStr];
    NSDictionary *monthDic = [MedicationRecordDB_ queryReport:dbDriver byType:1 clockId:clockId dateStr:dateStr];
    NSDictionary *yearDic = [MedicationRecordDB_ queryReport:dbDriver byType:2 clockId:clockId dateStr:dateStr];
    [self initViewWithData_week:weekDic month:monthDic year:yearDic];
    /*
     NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
     [dic setValue:@""  forKey:@""];
     [dic setValue:@""  forKey:@""];
     [dic setValue:@""  forKey:@""];
     [self initViewWithDate_week:dic month:dic year:dic];
     */
}

- (void)initViewWithData_week:(NSDictionary*)weekDic month:(NSDictionary*)monthDic year:(NSDictionary*)yearDic{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.pagingEnabled = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    
    //周报告
    UIView *weeklyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0,screenHeight/50.0*2, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    weeklyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    weeklyReportView.layer.cornerRadius = screenWidth/32.0*5;
    [scrollView addSubview:weeklyReportView];
    
    UILabel *weeklyReportTitle = [[UILabel alloc]init];
    weeklyReportTitle.text=@"周报告";
    weeklyReportTitle.font=[UIFont systemFontOfSize:18];
    weeklyReportTitle.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportTitle];
    CGSize weeklyReportTitleSize = [weeklyReportTitle.text sizeWithFont:weeklyReportTitle.font];
    [weeklyReportTitle setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*1.5, weeklyReportTitleSize.width, weeklyReportTitleSize.height)];
    
    
    UILabel *weeklyReportYes = [[UILabel alloc]init];
    NSString *yes_week_take_medition_times = [weekDic valueForKey:@"total_state"];
    if(yes_week_take_medition_times==nil){
        weeklyReportYes.text=[NSString stringWithFormat:@"共吃药:0次"];
    }else{
        weeklyReportYes.text=[NSString stringWithFormat:@"共吃药:%@次", yes_week_take_medition_times];
    }
    weeklyReportYes.font=[UIFont systemFontOfSize:12];
    weeklyReportYes.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportYes];
    CGSize weeklyReportYesSize = [weeklyReportYes.text sizeWithFont:weeklyReportYes.font];
    [weeklyReportYes setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*4, weeklyReportYesSize.width, weeklyReportYesSize.height)];
    
    
    UILabel *weeklyReportNo = [[UILabel alloc]init];
    NSString *No_week_take_medition_times = [NSString stringWithFormat:@"%d", [[weekDic valueForKey:@"total_times"] intValue]-[yes_week_take_medition_times intValue]];
    //NSLog(@"before_low_times_str=%@",No_take_medition_times);
    if(No_week_take_medition_times==nil){
        weeklyReportNo.text=[NSString stringWithFormat:@"未吃药:0次"];
    }else{
        weeklyReportNo.text=[NSString stringWithFormat:@"未吃药:%@次", No_week_take_medition_times];
    }
    weeklyReportNo.font=[UIFont systemFontOfSize:12];
    weeklyReportNo.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportNo];
    CGSize weeklyReportNoSize = [weeklyReportNo.text sizeWithFont:weeklyReportNo.font];
    [weeklyReportNo setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5.5, weeklyReportNoSize.width, weeklyReportNoSize.height)];
    //周状况Lable
    UILabel *weeklyReportZhou = [[UILabel alloc]init];
    weeklyReportZhou.text=@"良好   ";
    weeklyReportZhou.font=[UIFont systemFontOfSize:20];
    weeklyReportZhou.textColor=[UIColor whiteColor];
    [weeklyReportView addSubview:weeklyReportZhou];
    CGSize weeklyReportZhouSize = [weeklyReportZhou.text sizeWithFont:weeklyReportNo.font];
    [weeklyReportZhou setFrame:CGRectMake(screenWidth/32.0*22.2, screenHeight/56.8*4, weeklyReportZhouSize.width*1.5, weeklyReportZhouSize.height)];
    
    UIImageView *imageview1=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*18.5, screenHeight/50.0*0.5, screenWidth/10.0*4.3, screenWidth/10.0*4.3)];
    imageview1.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview1];
    
    //月报告
    UIView *mouthlyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0,screenHeight/50.0*15, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    mouthlyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    mouthlyReportView.layer.cornerRadius = screenWidth/32.0*5;
    [scrollView addSubview:mouthlyReportView];
    //月状况lable
    UIImageView *imageview2=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*0.3,screenHeight/50.0*13.5, screenWidth/10.0*4.3, screenWidth/10.0*4.3)];
    imageview2.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview2];
    
    
    
    UILabel *mouthlyReportYue = [[UILabel alloc]init];
    mouthlyReportYue.text=@"良好   ";
    mouthlyReportYue.font=[UIFont systemFontOfSize:20];
    mouthlyReportYue.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportYue];
    CGSize mouthlyReportYueSize = [mouthlyReportYue.text sizeWithFont:mouthlyReportYue.font];
    [mouthlyReportYue setFrame:CGRectMake(screenWidth/32.0*4, screenHeight/56.8*4, mouthlyReportYueSize.width*1.5, mouthlyReportYueSize.height)];
    
    
    UILabel *mouthlyReportTitle = [[UILabel alloc]init];
    mouthlyReportTitle.text=@"月报告";
    mouthlyReportTitle.font=[UIFont systemFontOfSize:18];
    mouthlyReportTitle.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportTitle];
    CGSize mouthlyReportTitleSize = [mouthlyReportTitle.text sizeWithFont:mouthlyReportTitle.font];
    [mouthlyReportTitle setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*1.5, mouthlyReportTitleSize.width, mouthlyReportTitleSize.height)];
    
    UILabel *mouthlyReportYes = [[UILabel alloc]init];
    NSString *Yes_month_take_medition_times = [monthDic valueForKey:@"total_state"];
    if(Yes_month_take_medition_times==nil){
        mouthlyReportYes.text=[NSString stringWithFormat:@"共吃药:0次"];
    }else{
        mouthlyReportYes.text=[NSString stringWithFormat:@"共吃药:%@次", Yes_month_take_medition_times];
    }
    mouthlyReportYes.font=[UIFont systemFontOfSize:12];
    mouthlyReportYes.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportYes];
    CGSize mouthlyReportYesSize = [mouthlyReportYes.text sizeWithFont:mouthlyReportYes.font];
    [mouthlyReportYes setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*4, mouthlyReportYesSize.width, mouthlyReportYesSize.height)];
    
    UILabel * mouthlyReportNo = [[UILabel alloc]init];
    NSString * No_month_take_medition_times = [NSString stringWithFormat:@"%d", [[monthDic valueForKey:@"total_times"] intValue]-[Yes_month_take_medition_times intValue]];
    if(No_month_take_medition_times==nil){
        mouthlyReportNo.text=[NSString stringWithFormat:@"未吃药:0次"];
    }else{
        mouthlyReportNo.text=[NSString stringWithFormat:@"未吃药:%@次", No_month_take_medition_times];
    }
    mouthlyReportNo.font=[UIFont systemFontOfSize:12];
    mouthlyReportNo.textColor=[UIColor whiteColor];
    [mouthlyReportView addSubview:mouthlyReportNo];
    CGSize mouthlyReportNoSize = [mouthlyReportNo.text sizeWithFont:mouthlyReportNo.font];
    [mouthlyReportNo setFrame:CGRectMake(screenWidth/2.0, screenHeight/50.0*5.5, mouthlyReportNoSize.width, mouthlyReportNoSize.height)];
    //年报告
    UIView *yearlyReportView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/22.0,screenHeight/50.0*28, screenWidth-screenWidth/22.0*2, screenHeight/50.0*8.5)];
    yearlyReportView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    yearlyReportView.layer.cornerRadius = screenWidth/32.0*5;
    [scrollView addSubview:yearlyReportView];
    
    UILabel *yearlyReportTitle = [[UILabel alloc]init];
    yearlyReportTitle.text=@"年报告";
    yearlyReportTitle.font=[UIFont systemFontOfSize:18];
    yearlyReportTitle.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportTitle];
    CGSize yearlyReportTitleSize = [yearlyReportTitle.text sizeWithFont:yearlyReportTitle.font];
    [yearlyReportTitle setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*1.5, yearlyReportTitleSize.width, yearlyReportTitleSize.height)];
    
    UILabel *yearlyReportYes = [[UILabel alloc]init];
    
    NSString * Yes_year_take_medition_times = [yearDic valueForKey:@"total_state"];
    if(Yes_year_take_medition_times==nil){
        yearlyReportYes.text=[NSString stringWithFormat:@"共吃药:0次"];
    }else{
        yearlyReportYes.text=[NSString stringWithFormat:@"共吃药:%@次", Yes_year_take_medition_times];
    }
    yearlyReportYes.font=[UIFont systemFontOfSize:12];
    yearlyReportYes.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportYes];
    CGSize yearlyReportYesSize = [yearlyReportYes.text sizeWithFont:yearlyReportYes.font];
    [yearlyReportYes setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*4.3, yearlyReportYesSize.width, yearlyReportYesSize.height)];
    
    UILabel *yearlyReportNo = [[UILabel alloc]init];
    NSString * No_year_take_medition_times = [NSString stringWithFormat:@"%d", [[yearDic valueForKey:@"total_times"] intValue]-[Yes_year_take_medition_times intValue]];
    if(No_year_take_medition_times==nil){
        yearlyReportNo.text=[NSString stringWithFormat:@"未吃药:0次"];
    }else{
        yearlyReportNo.text=[NSString stringWithFormat:@"未吃药:%@次", No_year_take_medition_times];
    }
    yearlyReportNo.font=[UIFont systemFontOfSize:12];
    yearlyReportNo.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportNo];
    CGSize yearlyReportNoSize = [yearlyReportNo.text sizeWithFont:yearlyReportNo.font];
    [yearlyReportNo setFrame:CGRectMake(screenWidth/22.0*2, screenHeight/50.0*5.8, yearlyReportNoSize.width, yearlyReportNoSize.height)];
    
    ;
    //年状况Lable
    UILabel *yearlyReportZhou = [[UILabel alloc]init];
    yearlyReportZhou.text=@"良好   ";
    yearlyReportZhou.font=[UIFont systemFontOfSize:20];
    yearlyReportZhou.textColor=[UIColor whiteColor];
    [yearlyReportView addSubview:yearlyReportZhou];
    CGSize yearlyReportZhouSize = [yearlyReportZhou.text sizeWithFont:yearlyReportYes.font];
    [yearlyReportZhou setFrame:CGRectMake(screenWidth/32.0*22.2, screenHeight/56.8*4, yearlyReportZhouSize.width*1.5, yearlyReportZhouSize.height)];
    
    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/32.0*18.5,screenHeight/50.0*26.5, screenWidth/10.0*4.3, screenWidth/10.0*4.3)];
    imageview3.image=[UIImage imageNamed:@"circle.png"];
    [scrollView addSubview:imageview3];
    
    
    
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
