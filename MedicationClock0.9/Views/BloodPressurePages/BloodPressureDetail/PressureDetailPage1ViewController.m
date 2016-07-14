//
//  PressureDetailPage1ViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/14.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "PressureDetailPage1ViewController.h"
#import "Charts/Charts-Swift.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "BloodPressureDB.h"
#define SizeScale screenWidth/350
@interface PressureDetailPage1ViewController ()<ChartViewDelegate>

@end

@implementation PressureDetailPage1ViewController{
    int screenWidth;
    int screenHeight;
    UIScrollView *_scrollView;
    LineChartView *_bloodPressureChartView, *_heartRateChartView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height;
    //NSLog(@"h=%d",screenHeight);
    // Do any additional setup after loading the view from its nib.
    //[self.view setBackgroundColor:[UIColor myBgColor]];
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth,  screenHeight+10)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    [self initView];
}

- (void)initView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    [self initBloodPressureChartView];
    [self initHeartRateChartView];
    
    //初始化数据库操作对象
    BaseDB *dbDriver = [[BaseDB alloc]init];
    NSMutableArray *arr = [BloodPressureDB queryRecently:dbDriver];
    
    //折线图数据
    NSMutableArray *data1Array = [[NSMutableArray alloc]init];
    NSMutableArray *data2Array = [[NSMutableArray alloc]init];
    NSMutableArray *heartDataArr = [[NSMutableArray alloc]init];
    NSMutableArray *xVals = [[NSMutableArray alloc]init];
    
    //文本框数据
    int systolic_pressure_abnormal1=0, systolic_pressure_abnormal2=0,
				diastolic_pressure_abnormal1=0, diastolic_pressure_abnormal2=0,
				heart_rate_abnormal1=0, heart_rate_abnormal2=0;
    int systolic_pressure_average=0, diastolic_pressure_average=0, heart_rate_average=0;
    for(long i=arr.count-1;i>=0;i--){
        NSMutableDictionary *dic = [arr objectAtIndex:i];
        NSString *systolic_pressure = [dic valueForKey:SYSTOLIC_PRESSURE];
        NSString *diastolic_pressure = [dic valueForKey:DIASTOLIC_PRESSURE];
        NSString *heart_rate = [dic valueForKey:HEART_RATE];
        //折线图数据
        [data1Array addObject:systolic_pressure];//收缩压
        [data2Array addObject:diastolic_pressure];//舒张压
        [heartDataArr addObject:heart_rate];//心跳数据
        //横轴的日期和时间
        NSString *record_date = [dic valueForKey:RECORD_DATE];
        //        NSString *record_time = [dic valueForKey:RECORD_TIME];
        [xVals addObject:[record_date substringFromIndex:5]];
        //文本框数据
        int systolic_pressure_int = [systolic_pressure intValue];
        int diastolic_pressure_int = [diastolic_pressure intValue];
        int heart_rate_int = [heart_rate intValue];
        systolic_pressure_average += systolic_pressure_int;
        diastolic_pressure_average += diastolic_pressure_int;
        heart_rate_average += heart_rate_int;
        if(systolic_pressure_int>140){
            systolic_pressure_abnormal1++;
        }else if(systolic_pressure_int<90){
            systolic_pressure_abnormal2++;
        }
        if(diastolic_pressure_int>90){
            diastolic_pressure_abnormal1++;
        }else if(diastolic_pressure_int<60){
            diastolic_pressure_abnormal2++;
        }
        if(heart_rate_int>90){
            heart_rate_abnormal1++;
        }else if(heart_rate_int<60){
            heart_rate_abnormal2++;
        }
    }
    [self initBloodPressureChartViewData:xVals data1:data1Array data2:data2Array];
    [self initHeartRateChartViewData:heartDataArr xVals:xVals];
    
    //获取总测量次数
    long total_test_times = arr.count;
    systolic_pressure_average = systolic_pressure_average/total_test_times;
    diastolic_pressure_average = diastolic_pressure_average/total_test_times;
    heart_rate_average = heart_rate_average/total_test_times;
    
    UIView *timesView = [[UIView alloc]initWithFrame:CGRectMake(0, _heartRateChartView.frame.origin.y+_heartRateChartView.frame.size.height+screenWidth/22.0, screenWidth, screenHeight/20)];
    timesView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [_scrollView addSubview:timesView];
    UILabel *times_Label = [[UILabel alloc]init];
    times_Label.text=[NSString stringWithFormat:@"近7次"];
    times_Label.font=[UIFont systemFontOfSize:17*SizeScale];
    times_Label.textColor=[UIColor whiteColor];
    [timesView addSubview:times_Label];
    CGSize times_LabelSize = [times_Label.text sizeWithFont:times_Label.font];
    [times_Label setFrame:CGRectMake(screenWidth/16, screenWidth/320*7, times_LabelSize.width, times_LabelSize.height)];
    
    UIView *systolic_pressure_View = [[UIView alloc]initWithFrame:CGRectMake(0, _heartRateChartView.frame.origin.y+_heartRateChartView.frame.size.height+screenWidth*2/22.0+screenHeight/20, screenWidth, screenHeight*1/6)];
    systolic_pressure_View.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [_scrollView addSubview:systolic_pressure_View];
    
    UILabel *systolic_pressure_Label = [[UILabel alloc]init];
    systolic_pressure_Label.text=[NSString stringWithFormat:@"收缩压：%ld次",total_test_times];
    systolic_pressure_Label.font=[UIFont systemFontOfSize:17*SizeScale];
    systolic_pressure_Label.textColor=[UIColor whiteColor];
    [systolic_pressure_View addSubview:systolic_pressure_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize systolic_pressure_LabelSize = [systolic_pressure_Label.text sizeWithFont:systolic_pressure_Label.font];
    [systolic_pressure_Label setFrame:CGRectMake(screenWidth/16, screenWidth/320*8, systolic_pressure_LabelSize.width, systolic_pressure_LabelSize.height)];
    
    UILabel *systolic_pressure_average_Label = [[UILabel alloc]init];
    systolic_pressure_average_Label.text=[NSString stringWithFormat:@"平均：%dmmHg",systolic_pressure_average];
    systolic_pressure_average_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    systolic_pressure_average_Label.textColor=[UIColor whiteColor];
    [systolic_pressure_View addSubview:systolic_pressure_average_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize systolic_pressure_average_LabelSize = [systolic_pressure_average_Label.text sizeWithFont:systolic_pressure_average_Label.font];
    [systolic_pressure_average_Label setFrame:CGRectMake(screenWidth/16*2, systolic_pressure_Label.frame.origin.y+systolic_pressure_LabelSize.height*1.3, systolic_pressure_average_LabelSize.width, systolic_pressure_average_LabelSize.height)];
    
    UILabel *systolic_pressure_hyperglycaemia_Label = [[UILabel alloc]init];
    systolic_pressure_hyperglycaemia_Label.text=[NSString stringWithFormat:@"高于140mmHg：%d次",systolic_pressure_abnormal1];
    systolic_pressure_hyperglycaemia_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    systolic_pressure_hyperglycaemia_Label.textColor=[UIColor whiteColor];
    [systolic_pressure_View addSubview:systolic_pressure_hyperglycaemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize systolic_pressure_hyperglycaemia_LabelSize = [systolic_pressure_hyperglycaemia_Label.text sizeWithFont:systolic_pressure_hyperglycaemia_Label.font];
    [systolic_pressure_hyperglycaemia_Label setFrame:CGRectMake(screenWidth/16*2, systolic_pressure_average_Label.frame.origin.y+systolic_pressure_average_LabelSize.height*1.3, systolic_pressure_hyperglycaemia_LabelSize.width, systolic_pressure_hyperglycaemia_LabelSize.height)];
    
    UILabel *systolic_pressure_hypotension_Label = [[UILabel alloc]init];
    systolic_pressure_hypotension_Label.text=[NSString stringWithFormat:@"低于90mmHg：%d次",systolic_pressure_abnormal2];
    systolic_pressure_hypotension_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    systolic_pressure_hypotension_Label.textColor=[UIColor whiteColor];
    [systolic_pressure_View addSubview:systolic_pressure_hypotension_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize systolic_pressure_hypotension_LabelSize = [systolic_pressure_hypotension_Label.text sizeWithFont:systolic_pressure_hypotension_Label.font];
    [systolic_pressure_hypotension_Label setFrame:CGRectMake(screenWidth/16*2, systolic_pressure_hyperglycaemia_Label.frame.origin.y+systolic_pressure_hyperglycaemia_LabelSize.height*1.3, systolic_pressure_hypotension_LabelSize.width, systolic_pressure_hypotension_LabelSize.height)];
    
    UIView *diastolic_pressure_view = [[UIView alloc]initWithFrame:CGRectMake(0, systolic_pressure_View.frame.origin.y+systolic_pressure_View.frame.size.height+screenWidth/22.0, screenWidth, screenHeight*1/6)];
    diastolic_pressure_view.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [_scrollView addSubview:diastolic_pressure_view];
    
    UILabel *diastolic_pressure_Label = [[UILabel alloc]init];
    diastolic_pressure_Label.text=[NSString stringWithFormat:@"舒张压：%ld次",total_test_times];
    diastolic_pressure_Label.font=[UIFont systemFontOfSize:17*SizeScale];
    diastolic_pressure_Label.textColor=[UIColor whiteColor];
    [diastolic_pressure_view addSubview:diastolic_pressure_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize diastolic_pressure_LabelSize = [diastolic_pressure_Label.text sizeWithFont:diastolic_pressure_Label.font];
    [diastolic_pressure_Label setFrame:CGRectMake(screenWidth/16, screenWidth/320*8, diastolic_pressure_LabelSize.width, diastolic_pressure_LabelSize.height)];
    
    UILabel *diastolic_pressure_average_Label = [[UILabel alloc]init];
    diastolic_pressure_average_Label.text=[NSString stringWithFormat:@"平均：%dmmHg",diastolic_pressure_average];
    diastolic_pressure_average_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    diastolic_pressure_average_Label.textColor=[UIColor whiteColor];
    [diastolic_pressure_view addSubview:diastolic_pressure_average_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize diastolic_pressure_average_LabelSize = [diastolic_pressure_average_Label.text sizeWithFont:diastolic_pressure_average_Label.font];
    [diastolic_pressure_average_Label setFrame:CGRectMake(screenWidth/16*2, diastolic_pressure_Label.frame.origin.y+diastolic_pressure_LabelSize.height*1.3, diastolic_pressure_average_LabelSize.width, diastolic_pressure_average_LabelSize.height)];
    
    UILabel *diastolic_pressure_hyperglycaemia_Label = [[UILabel alloc]init];
    diastolic_pressure_hyperglycaemia_Label.text=[NSString stringWithFormat:@"高于90mmHg：%d次",diastolic_pressure_abnormal1];
    diastolic_pressure_hyperglycaemia_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    diastolic_pressure_hyperglycaemia_Label.textColor=[UIColor whiteColor];
    [diastolic_pressure_view addSubview:diastolic_pressure_hyperglycaemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize diastolic_pressure_hyperglycaemia_LabelSize = [diastolic_pressure_hyperglycaemia_Label.text sizeWithFont:systolic_pressure_hyperglycaemia_Label.font];
    [diastolic_pressure_hyperglycaemia_Label setFrame:CGRectMake(screenWidth/16*2, diastolic_pressure_average_Label.frame.origin.y+diastolic_pressure_average_LabelSize.height*1.3, diastolic_pressure_hyperglycaemia_LabelSize.width, diastolic_pressure_hyperglycaemia_LabelSize.height)];
    
    UILabel *diastolic_pressure_hypotension_Label = [[UILabel alloc]init];
    diastolic_pressure_hypotension_Label.text=[NSString stringWithFormat:@"低于60mmHg：%d次",diastolic_pressure_abnormal2];
    diastolic_pressure_hypotension_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    diastolic_pressure_hypotension_Label.textColor=[UIColor whiteColor];
    [diastolic_pressure_view addSubview:diastolic_pressure_hypotension_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize diastolic_pressure_hypotension_LabelSize = [diastolic_pressure_hypotension_Label.text sizeWithFont:diastolic_pressure_hypotension_Label.font];
    [diastolic_pressure_hypotension_Label setFrame:CGRectMake(screenWidth/16*2, diastolic_pressure_hyperglycaemia_Label.frame.origin.y+diastolic_pressure_hyperglycaemia_LabelSize.height*1.3, diastolic_pressure_hypotension_LabelSize.width, diastolic_pressure_hypotension_LabelSize.height)];
    
    
    UIView *heart_rate_view = [[UIView alloc]initWithFrame:CGRectMake(0, diastolic_pressure_view.frame.origin.y+diastolic_pressure_view.frame.size.height+screenWidth/22.0, screenWidth, screenHeight*1/6)];
    heart_rate_view.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [_scrollView addSubview:heart_rate_view];
    
    UILabel *heart_rate_Label = [[UILabel alloc]init];
    heart_rate_Label.text=[NSString stringWithFormat:@"心率：%ld次",total_test_times];
    heart_rate_Label.font=[UIFont systemFontOfSize:17*SizeScale];
    heart_rate_Label.textColor=[UIColor whiteColor];
    [heart_rate_view addSubview:heart_rate_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize heart_rate_LabelSize = [heart_rate_Label.text sizeWithFont:heart_rate_Label.font];
    [heart_rate_Label setFrame:CGRectMake(screenWidth/16, screenWidth/320*8, heart_rate_LabelSize.width, heart_rate_LabelSize.height)];
    
    UILabel *heart_rate_average_Label = [[UILabel alloc]init];
    heart_rate_average_Label.text=[NSString stringWithFormat:@"平均：%d次/分",heart_rate_average];
    heart_rate_average_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    heart_rate_average_Label.textColor=[UIColor whiteColor];
    [heart_rate_view addSubview:heart_rate_average_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize heart_rate_average_LabelSize = [heart_rate_average_Label.text sizeWithFont:heart_rate_average_Label.font];
    [heart_rate_average_Label setFrame:CGRectMake(screenWidth/16*2, heart_rate_Label.frame.origin.y+heart_rate_LabelSize.height*1.3, heart_rate_average_LabelSize.width, heart_rate_average_LabelSize.height)];
    
    UILabel *heart_rate_hyperglycaemia_Label = [[UILabel alloc]init];
    heart_rate_hyperglycaemia_Label.text=[NSString stringWithFormat:@"高于100次/分：%d次",heart_rate_abnormal1];
    heart_rate_hyperglycaemia_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    heart_rate_hyperglycaemia_Label.textColor=[UIColor whiteColor];
    [heart_rate_view addSubview:heart_rate_hyperglycaemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize heart_rate_hyperglycaemia_LabelSize = [heart_rate_hyperglycaemia_Label.text sizeWithFont:heart_rate_hyperglycaemia_Label.font];
    [heart_rate_hyperglycaemia_Label setFrame:CGRectMake(screenWidth/16*2, heart_rate_average_Label.frame.origin.y+heart_rate_average_LabelSize.height*1.3, heart_rate_hyperglycaemia_LabelSize.width, heart_rate_hyperglycaemia_LabelSize.height)];
    
    UILabel *heart_rate_hypotension_Label = [[UILabel alloc]init];
    heart_rate_hypotension_Label.text=[NSString stringWithFormat:@"低于60次/分：%d次",heart_rate_abnormal2];
    heart_rate_hypotension_Label.font=[UIFont systemFontOfSize:12*SizeScale];
    heart_rate_hypotension_Label.textColor=[UIColor whiteColor];
    [heart_rate_view addSubview:heart_rate_hypotension_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize heart_rate_hypotension_LabelSize = [heart_rate_hypotension_Label.text sizeWithFont:heart_rate_hypotension_Label.font];
    [heart_rate_hypotension_Label setFrame:CGRectMake(screenWidth/16*2, heart_rate_hyperglycaemia_Label.frame.origin.y+heart_rate_hyperglycaemia_LabelSize.height*1.3, heart_rate_hypotension_LabelSize.width, heart_rate_hypotension_LabelSize.height)];
    
    
    _scrollView.contentSize = CGSizeMake(0, 1200);
}

- (void)initBloodPressureChartViewData:(NSArray*)xVals data1:(NSArray*)data1Array data2:(NSArray*)data2Array{
    //创建图形报表数据的对象
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    long complement1 = xVals.count - data1Array.count;
    for (int i = 0; i < data1Array.count; i++){
        NSString *number = [data1Array objectAtIndex:i];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:[number floatValue] xIndex:i+complement1]];
    }
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    long complement2 = xVals.count - data2Array.count;
    for (int i = 0; i < data2Array.count; i++){
        NSNumber *number = [data2Array objectAtIndex:i];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:[number floatValue] xIndex:i+complement2]];
    }
    //创建图形报表的数据对象
    LineChartDataSet *set1 = nil, *set2 = nil;
    if (_bloodPressureChartView.data.dataSetCount > 0){
        set1 = (LineChartDataSet *)_bloodPressureChartView.data.dataSets[0];
        set2 = (LineChartDataSet *)_bloodPressureChartView.data.dataSets[1];
        set1.yVals = yVals1;
        set2.yVals = yVals2;
        _bloodPressureChartView.data.xValsObjc = xVals;
        [_bloodPressureChartView notifyDataSetChanged];
    }else{
        set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@"收缩压"];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor redColor]];
        [set1 setCircleColor:UIColor.redColor];
        set1.lineWidth = 2.0;
        set1.circleRadius = 3.0;
        set1.fillAlpha = 65/255.0;
        set1.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set1.drawCircleHoleEnabled = NO;
        
        set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"舒张压"];
        set2.axisDependency = AxisDependencyLeft;
        [set2 setColor:[UIColor yellowColor]];
        [set2 setCircleColor:UIColor.yellowColor];
        set2.lineWidth = 2.0;
        set2.circleRadius = 3.0;
        set2.fillAlpha = 65/255.0;
        set2.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set2.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        
        LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        _bloodPressureChartView.data = data;
    }
}

- (void)initHeartRateChartViewData:(NSArray*)dataArray xVals:(NSArray*)xVals{
    //创建图形报表数据的对象
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    long complement = xVals.count - dataArray.count;
    for (int i = 0; i < dataArray.count; i++){
        NSString *number = [dataArray objectAtIndex:i];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:[number floatValue] xIndex:i+complement]];
    }
    //创建图形报表的数据对象
    LineChartDataSet *set = nil;
    if (_heartRateChartView.data.dataSetCount > 0){
        set = (LineChartDataSet *)_heartRateChartView.data.dataSets[0];
        set.yVals = yVals;
        _heartRateChartView.data.xValsObjc = xVals;
        [_heartRateChartView notifyDataSetChanged];
    }else{
        set = [[LineChartDataSet alloc] initWithYVals:yVals label:@"心率"];
        set.axisDependency = AxisDependencyLeft;
        [set setColor:[UIColor whiteColor]];
        [set setCircleColor:UIColor.whiteColor];
        set.lineWidth = 2.0;
        set.circleRadius = 3.0;
        set.fillAlpha = 65/255.0;
        set.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set];
        
        LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        _heartRateChartView.data = data;
    }
}

- (void)initBloodPressureChartView{
    _bloodPressureChartView = [[LineChartView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/3)];
    _bloodPressureChartView.backgroundColor = [UIColor clearColor];
    //_bloodPressureChartView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    _bloodPressureChartView.delegate = self;
    
    _bloodPressureChartView.descriptionText = @"";
    _bloodPressureChartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _bloodPressureChartView.dragEnabled = YES;
    [_bloodPressureChartView setScaleEnabled:YES];
    _bloodPressureChartView.drawGridBackgroundEnabled = NO;
    _bloodPressureChartView.pinchZoomEnabled = YES;
    
    _bloodPressureChartView.legend.form = ChartLegendFormLine;
    _bloodPressureChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _bloodPressureChartView.legend.textColor = UIColor.whiteColor;
    _bloodPressureChartView.legend.position = ChartLegendPositionBelowChartLeft;
    
    //    _chartView.xAxis.labelPosition = .Bottom;
    
    
    ChartXAxis *xAxis = _bloodPressureChartView.xAxis;
    //    xAxis.gridColor = UIColor.whiteColor;
    //    xAxis.drawGridLinesEnabled = false;
    xAxis.axisLineColor = UIColor.whiteColor;
    xAxis.axisLineWidth = 2;
    xAxis.labelFont = [UIFont systemFontOfSize:12.f];
    xAxis.labelTextColor = UIColor.whiteColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 1.0;
    
    ChartYAxis *leftAxis = _bloodPressureChartView.leftAxis;
    leftAxis.axisLineColor = UIColor.whiteColor;
    leftAxis.axisLineWidth = 2;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.axisMinValue = 90.0;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.granularityEnabled = NO;
    
    ChartYAxis *rightAxis = _bloodPressureChartView.rightAxis;
    rightAxis.enabled = false;
    
    [_bloodPressureChartView animateWithXAxisDuration:2.5];
    
    [_scrollView addSubview:_bloodPressureChartView];
}

- (void)initHeartRateChartView{
    _heartRateChartView = [[LineChartView alloc]initWithFrame:CGRectMake(0, _bloodPressureChartView.frame.origin.y+_bloodPressureChartView.frame.size.height+15, screenWidth, screenHeight/3)];
    //_heartRateChartView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    _heartRateChartView.backgroundColor = [UIColor clearColor];
    _heartRateChartView.delegate = self;
    
    _heartRateChartView.descriptionText = @"";
    _heartRateChartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _heartRateChartView.dragEnabled = YES;
    [_heartRateChartView setScaleEnabled:YES];
    _heartRateChartView.drawGridBackgroundEnabled = NO;
    _heartRateChartView.pinchZoomEnabled = YES;
    
    _heartRateChartView.legend.form = ChartLegendFormLine;
    _heartRateChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _heartRateChartView.legend.textColor = UIColor.whiteColor;
    _heartRateChartView.legend.position = ChartLegendPositionBelowChartLeft;
    
    //    _chartView.xAxis.labelPosition = .Bottom;
    
    
    ChartXAxis *xAxis = _heartRateChartView.xAxis;
    //    xAxis.gridColor = UIColor.whiteColor;
    //    xAxis.drawGridLinesEnabled = false;
    xAxis.axisLineColor = UIColor.whiteColor;
    xAxis.axisLineWidth = 2;
    xAxis.labelFont = [UIFont systemFontOfSize:12.f];
    xAxis.labelTextColor = UIColor.whiteColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 1.0;
    
    ChartYAxis *leftAxis = _heartRateChartView.leftAxis;
    leftAxis.axisLineColor = UIColor.whiteColor;
    leftAxis.axisLineWidth = 2;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.axisMinValue = 90.0;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.granularityEnabled = NO;
    
    
    ChartYAxis *rightAxis = _heartRateChartView.rightAxis;
    rightAxis.enabled = false;
    
    [_heartRateChartView animateWithXAxisDuration:2.5];
    
    [_scrollView addSubview:_heartRateChartView];
}

#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight{
    NSLog(@"chartValueSelected");
    
    [_bloodPressureChartView centerViewToAnimatedWithXIndex:entry.xIndex yValue:entry.value axis:[_bloodPressureChartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    //[_chartView moveViewToAnimatedWithXIndex:entry.xIndex yValue:entry.value axis:[_chartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    //[_chartView zoomAndCenterViewAnimatedWithScaleX:1.8 scaleY:1.8 xIndex:entry.xIndex yValue:entry.value axis:[_chartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    
}
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView{
    NSLog(@"chartValueNothingSelected");
}

@end
