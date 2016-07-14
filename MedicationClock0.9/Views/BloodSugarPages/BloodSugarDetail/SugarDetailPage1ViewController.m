//
//  SugarDetailPage1ViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/14.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "SugarDetailPage1ViewController.h"
#import "Charts/Charts-Swift.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "BloodSugarDB.h"
#define SizeScale screenWidth/350
@interface SugarDetailPage1ViewController ()<ChartViewDelegate>

@end

@implementation SugarDetailPage1ViewController{
    int screenWidth;
    int screenHeight;
    
    BaseDB *dbDriver;
    LineChartView *_chartView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = self.view.frame.size.height+10;
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = [UIColor myBgColor];
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth,  screenHeight+10)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    [self initChartView];

    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    NSMutableArray *arr = [BloodSugarDB queryRecently:dbDriver];
    
    //折线图数据
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    NSMutableArray *xVals = [[NSMutableArray alloc]init];
    //文本框数据
    int before_meal_times=0, after_meal_times=0, before_meal_hyperglycaemia=0, before_meal_hypoglycemia=0, after_meal_hyperglycaemia=0;
    float before_meal_average=0.0f, after_meal_average=0.0f;
    
    for(long i=arr.count-1;i>=0;i--){
        NSMutableDictionary *dic = [arr objectAtIndex:i];
        //折线图数据
        NSString *blood_sugar = [dic valueForKey:BLOOD_SUGAR];
        [dataArray addObject:blood_sugar];
        NSString *record_date = [dic valueForKey:RECORD_DATE];
        NSString *record_time = [dic valueForKey:RECORD_TIME];
        [xVals addObject:[NSString stringWithFormat:@"%@ %@",[record_date substringFromIndex:5],record_time]];
        //文本框数据
        NSString* after_meal = [dic valueForKey:AFTER_MEAL];
        float blood_sugar_float = [blood_sugar floatValue];
        if([@"true" isEqualToString:after_meal]){
            after_meal_times++;
            after_meal_average += blood_sugar_float;
            if(blood_sugar_float>7.8){
                after_meal_hyperglycaemia++;
            }
        }else{
            before_meal_times++;
            before_meal_average += blood_sugar_float;
            if(blood_sugar_float>6.0){
                before_meal_hyperglycaemia++;
            }else if(blood_sugar_float<2.8){
                before_meal_hypoglycemia++;
            }
        }
    }
    
    [self initChartViewData:dataArray xVals:xVals];
    
    if(before_meal_times!=0){
        before_meal_average = before_meal_average/before_meal_times;
    }
    if(after_meal_times!=0){
        after_meal_average = after_meal_average/after_meal_times;
    }
    
    UIView *before_meal_View = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight/3+screenWidth/22.0, screenWidth, screenHeight*9/50)];
    before_meal_View.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [self.view addSubview:before_meal_View];
    
    UILabel *before_meal_Label = [[UILabel alloc]init];
    before_meal_Label.text=[NSString stringWithFormat:@"饭前：%d次",before_meal_times];
    before_meal_Label.font=[UIFont systemFontOfSize:17*screenWidth/320];
    before_meal_Label.textColor=[UIColor whiteColor];
    [before_meal_View addSubview:before_meal_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize before_meal_LabelSize = [before_meal_Label.text sizeWithFont:before_meal_Label.font];
    [before_meal_Label setFrame:CGRectMake(screenWidth/16, 5, before_meal_LabelSize.width, before_meal_LabelSize.height)];
    
    UILabel *before_meal_average_Label = [[UILabel alloc]init];
    before_meal_average_Label.text=[NSString stringWithFormat:@"平均：%fmmol/L",before_meal_average];
    before_meal_average_Label.font=[UIFont systemFontOfSize:12*screenWidth/320];
    before_meal_average_Label.textColor=[UIColor whiteColor];
    [before_meal_View addSubview:before_meal_average_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize before_meal_average_LabelSize = [before_meal_average_Label.text sizeWithFont:before_meal_average_Label.font];
    [before_meal_average_Label setFrame:CGRectMake(screenWidth/16*2, before_meal_Label.frame.origin.y+before_meal_LabelSize.height*1.3, before_meal_average_LabelSize.width, before_meal_average_LabelSize.height)];
    
    UILabel *before_meal_hyperglycaemia_Label = [[UILabel alloc]init];
    before_meal_hyperglycaemia_Label.text=[NSString stringWithFormat:@"高于6.0mmol/L：%d次",before_meal_hyperglycaemia];
    before_meal_hyperglycaemia_Label.font=[UIFont systemFontOfSize:12*screenWidth/320];
    before_meal_hyperglycaemia_Label.textColor=[UIColor whiteColor];
    [before_meal_View addSubview:before_meal_hyperglycaemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize before_meal_hyperglycaemia_LabelSize = [before_meal_hyperglycaemia_Label.text sizeWithFont:before_meal_hyperglycaemia_Label.font];
    [before_meal_hyperglycaemia_Label setFrame:CGRectMake(screenWidth/16*2, before_meal_average_Label.frame.origin.y+before_meal_average_LabelSize.height*1.3, before_meal_hyperglycaemia_LabelSize.width, before_meal_hyperglycaemia_LabelSize.height)];
    
    UILabel *before_meal_hypoglycemia_Label = [[UILabel alloc]init];
    before_meal_hypoglycemia_Label.text=[NSString stringWithFormat:@"低于2.8mmol/L：%d次",before_meal_hypoglycemia];
    before_meal_hypoglycemia_Label.font=[UIFont systemFontOfSize:12*screenWidth/320];
    before_meal_hypoglycemia_Label.textColor=[UIColor whiteColor];
    [before_meal_View addSubview:before_meal_hypoglycemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize before_meal_hypoglycemia_LabelSize = [before_meal_hypoglycemia_Label.text sizeWithFont:before_meal_hypoglycemia_Label.font];
    [before_meal_hypoglycemia_Label setFrame:CGRectMake(screenWidth/16*2, before_meal_hyperglycaemia_Label.frame.origin.y+before_meal_hyperglycaemia_LabelSize.height*1.3, before_meal_hypoglycemia_LabelSize.width, before_meal_hypoglycemia_LabelSize.height)];
    
    
    UIView *after_meal_View = [[UIView alloc]initWithFrame:CGRectMake(0, before_meal_View.frame.origin.y+before_meal_View.frame.size.height+15, screenWidth, screenHeight*7/50)];
    after_meal_View.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
    [self.view addSubview:after_meal_View];
    
    UILabel *after_meal_Label = [[UILabel alloc]init];
    after_meal_Label.text=[NSString stringWithFormat:@"饭后：%d次",after_meal_times];
    after_meal_Label.font=[UIFont systemFontOfSize:17*screenWidth/320];
    after_meal_Label.textColor=[UIColor whiteColor];
    [after_meal_View addSubview:after_meal_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize after_meal_LabelSize = [after_meal_Label.text sizeWithFont:after_meal_Label.font];
    [after_meal_Label setFrame:CGRectMake(screenWidth/16, 5, after_meal_LabelSize.width, after_meal_LabelSize.height)];
    
    UILabel *after_meal_average_Label = [[UILabel alloc]init];
    after_meal_average_Label.text=[NSString stringWithFormat:@"平均：%fmmol/L",after_meal_average];
    after_meal_average_Label.font=[UIFont systemFontOfSize:12*screenWidth/320];
    after_meal_average_Label.textColor=[UIColor whiteColor];
    [after_meal_View addSubview:after_meal_average_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize after_meal_average_LabelSize = [after_meal_average_Label.text sizeWithFont:after_meal_average_Label.font];
    [after_meal_average_Label setFrame:CGRectMake(screenWidth/16*2, after_meal_Label.frame.origin.y+after_meal_LabelSize.height*1.3, after_meal_average_LabelSize.width, after_meal_average_LabelSize.height)];
    
    UILabel *after_meal_hyperglycaemia_Label = [[UILabel alloc]init];
    after_meal_hyperglycaemia_Label.text=[NSString stringWithFormat:@"高于7.8mmol/L：%d次",after_meal_hyperglycaemia];
    after_meal_hyperglycaemia_Label.font=[UIFont systemFontOfSize:12*screenWidth/320];
    after_meal_hyperglycaemia_Label.textColor=[UIColor whiteColor];
    [after_meal_View addSubview:after_meal_hyperglycaemia_Label];
    //根据文字长度和字体计算文本框的长度
    CGSize after_meal_hyperglycaemia_LabelSize = [after_meal_hyperglycaemia_Label.text sizeWithFont:after_meal_hyperglycaemia_Label.font];
    [after_meal_hyperglycaemia_Label setFrame:CGRectMake(screenWidth/16*2, after_meal_average_Label.frame.origin.y+after_meal_average_LabelSize.height*1.3, after_meal_hyperglycaemia_LabelSize.width, after_meal_hyperglycaemia_LabelSize.height)];
}

- (void)initChartViewData:(NSArray*)dataArray xVals:(NSArray*)xVals{
    //创建图形报表数据的对象
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    long complement = xVals.count - dataArray.count;
    for (int i = 0; i < dataArray.count; i++){
        NSString *number = [dataArray objectAtIndex:i];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:[number floatValue] xIndex:i+complement]];
    }
    //创建图形报表的数据对象
    LineChartDataSet *set = nil;
    if (_chartView.data.dataSetCount > 0){
        set = (LineChartDataSet *)_chartView.data.dataSets[0];
        set.yVals = yVals;
        _chartView.data.xValsObjc = xVals;
        [_chartView notifyDataSetChanged];
    }else{
        set = [[LineChartDataSet alloc] initWithYVals:yVals label:@"血糖测量记录"];
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
        
        _chartView.data = data;
    }
}

- (void)initChartView{
    _chartView = [[LineChartView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/3)];
    _chartView.backgroundColor = [UIColor clearColor];   // _chartView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.pinchZoomEnabled = YES;
    
    _chartView.legend.form = ChartLegendFormLine;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.textColor = UIColor.whiteColor;
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    
    //    _chartView.xAxis.labelPosition = .Bottom;
    
    
    ChartXAxis *xAxis = _chartView.xAxis;
    //    xAxis.gridColor = UIColor.whiteColor;
    //    xAxis.drawGridLinesEnabled = false;
    xAxis.axisLineColor = UIColor.whiteColor;
    xAxis.axisLineWidth = 2;
    xAxis.labelFont = [UIFont systemFontOfSize:12.f];
    xAxis.labelTextColor = UIColor.whiteColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 1.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.axisLineColor = UIColor.whiteColor;
    leftAxis.axisLineWidth = 0.3;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.axisMinValue = 8.1;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.granularityEnabled = NO;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = false;
    
    [_chartView animateWithXAxisDuration:2.5];
    
    [self.view addSubview:_chartView];
}

#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight{
    NSLog(@"chartValueSelected");
    
    [_chartView centerViewToAnimatedWithXIndex:entry.xIndex yValue:entry.value axis:[_chartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    //[_chartView moveViewToAnimatedWithXIndex:entry.xIndex yValue:entry.value axis:[_chartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    //[_chartView zoomAndCenterViewAnimatedWithScaleX:1.8 scaleY:1.8 xIndex:entry.xIndex yValue:entry.value axis:[_chartView.data getDataSetByIndex:dataSetIndex].axisDependency duration:1.0];
    
}
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView{
    NSLog(@"chartValueNothingSelected");
}

@end
