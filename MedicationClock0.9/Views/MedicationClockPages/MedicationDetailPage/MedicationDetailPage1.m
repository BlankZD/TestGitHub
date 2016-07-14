//
//  MedicationDetailPage1.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/29.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "MedicationDetailPage1.h"

#import "MedicationDetailViewController.h"

#import "Charts/Charts-Swift.h"
#import "UIColor+DIY.h"
#import "DateUtil.h"
#import "CommonUtil.h"

#import "BaseDB.h"
#import "AlarmClockDB_.h"
#import "MedicationRecordDB_.h"

@interface MedicationDetailPage1 ()<ChartViewDelegate, UITableViewDataSource,UITableViewDelegate>

@end

@implementation MedicationDetailPage1{
    int screenWidth;
    int screenHeight;
    
    BaseDB *dbDriver;
    
    UIScrollView *_scrollView;
    LineChartView *_chartView;
    UITableView *_tableView;
    NSMutableArray *_array, *_medicationArr;
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
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
//    _scrollView.backgroundColor=[UIColor blueColor];
    _scrollView.pagingEnabled = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    //初始化折线图报表控件
    [self initChartView];
    
    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    
    NSString *clockId = [super.paramDic valueForKey:CLOCK_ID];
    NSString *recordDate = [super.paramDic valueForKey:RECORD_DATE];
    NSLog(@"super.paramDic=%@",super.paramDic);
    
    //折线图数据
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    NSMutableArray *xVals = [[NSMutableArray alloc]init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    for(int i=6;i>=0;i--){
        [comps setDay:-i];
        NSDate *date = [calendar dateByAddingComponents:comps toDate:[DateUtil getDateFromStr:recordDate formatStr:@"yyyy-MM-dd"] options:0];
        NSString *date_str = [DateUtil getStrFromDate:date formatStr:@"MM-dd"];
        [xVals addObject:date_str];
        //动态读取服药状态
        NSString *dateStr = [DateUtil getStrFromDate:date formatStr:@"yyyy-MM-dd"];
        NSString *medication_state = [MedicationRecordDB_ queryRecently:dbDriver clockId:clockId dateStr:dateStr];
        [dataArray addObject:medication_state];
    }
    [self initChartViewData:dataArray xVals:xVals];
    
    //加载其它界面
    _array = [AlarmClockDB_ queryTimeList:dbDriver clockId:clockId];
//    _medicationArr = [MedicationRecordDB_ queryDetailsByClockIdAndDate:dbDriver clockId:clockId dateStr:recordDate];
    NSString *recordId = [super.paramDic valueForKey:@"_id"];
    _medicationArr = [MedicationRecordDB_ queryDetailsByRecordId:dbDriver recordId:recordId];
    if(_medicationArr==nil){
        _medicationArr = [[NSMutableArray alloc]init];
    }
    if(_medicationArr.count<_array.count){
        long n = _array.count-_medicationArr.count;
        for(int i=0;i<n;i++){
            [_medicationArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"点击补录服药记录",MEDICATION_TIME, nil]];
        }
    }
    [self initView:super.paramDic];
    
    _scrollView.contentSize = CGSizeMake(0, 750);
    
    //注册notification的监听函数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"medication" object:nil];
}
//notification传值 自定义接收信息和处理的方法
- (void) notificationHandler:(NSNotification *) notification{
    NSString *recordId = [super.paramDic valueForKey:@"_id"];
    //刷新列表显示的数据
    _medicationArr = [MedicationRecordDB_ queryDetailsByRecordId:dbDriver recordId:recordId];
    if(_medicationArr==nil){
        _medicationArr = [[NSMutableArray alloc]init];
    }
    if(_medicationArr.count<_array.count){
        for(int i=0;i<_array.count-_medicationArr.count;i++){
            [_medicationArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"点击补录服药记录",MEDICATION_TIME, nil]];
        }
    }
    //刷新列表视图控件显示的数据
    [_tableView reloadData];
    NSLog(@"notificationHandler");
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
        set = [[LineChartDataSet alloc] initWithYVals:yVals label:@"服药次数记录"];
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
    _chartView.backgroundColor = [UIColor clearColor];
    //_chartView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
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
    leftAxis.axisLineWidth = 2;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.axisMinValue = 0.0;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.granularityEnabled = NO;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = false;
    
    [_chartView animateWithXAxisDuration:2.5];
    
    [_scrollView addSubview:_chartView];
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

-(void)initView:(NSDictionary*)dic{
    
    UIView *TitleView = [[UIView alloc]initWithFrame:CGRectMake(0, _chartView.frame.origin.y+_chartView.frame.size.height+15, screenWidth,screenHeight/56.8*6)];
    TitleView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    [_scrollView addSubview:TitleView];
    
    
    UIImageView *imageview1=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth/32*0.5, screenHeight/56.8*6)];
    imageview1.image=[UIImage imageNamed:@"blue.png"];
    [TitleView addSubview:imageview1];
    
    UILabel *Titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(15, screenHeight/56.8*0.8,screenWidth,screenHeight/56.8*2.5)];
    Titlelabel.backgroundColor = [UIColor clearColor];
    Titlelabel.textColor = [UIColor colorWithRed:107/255.0 green:202/255.0 blue:236/255.0 alpha:1];
    Titlelabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                      size:16];
    Titlelabel.text = @"闹钟标题";
    [TitleView addSubview:Titlelabel];
    
    
    UILabel *TitlelabelValue = [[UILabel alloc]initWithFrame:CGRectMake(15, screenHeight/56.8*3, screenWidth, screenHeight/56.8*2.5)];
    TitlelabelValue.backgroundColor = [UIColor clearColor];
    TitlelabelValue.textColor = [UIColor blackColor];
    TitlelabelValue.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                           size:14];
    NSString *Titlevalue = [dic valueForKey:@"title"];
    if(Titlevalue==nil){
        TitlelabelValue.text=[NSString stringWithFormat:@" "];
    }else{
        TitlelabelValue.text=[NSString stringWithFormat:@"%@", Titlevalue];
    }
    
    [TitleView addSubview:TitlelabelValue];
    
    UIView *ContentView = [[UIView alloc]initWithFrame:CGRectMake(0, TitleView.frame.origin.y+TitleView.frame.size.height+10, screenWidth,screenHeight/56.8*6)];
    ContentView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    [_scrollView addSubview:ContentView];
    
    UIImageView *imageview2=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth/32*0.5, screenHeight/56.8*6)];
    imageview2.image=[UIImage imageNamed:@"green2.png"];
    [ContentView addSubview:imageview2];
    
    UILabel *Contentlabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*0.8,screenWidth,screenHeight/56.8*2.5)];
    Contentlabel.backgroundColor = [UIColor clearColor];
    Contentlabel.textColor = [UIColor colorWithRed:174/255.0 green:219/255.0 blue:128/255.0 alpha:1];
    Contentlabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                        size:16];
    Contentlabel.text = @"内容";
    [ContentView addSubview:Contentlabel];
    
    
    UILabel * ContentlabelValue = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*3,screenWidth,screenHeight/56.8*2.5)];
    ContentlabelValue.backgroundColor = [UIColor clearColor];
    ContentlabelValue.textColor = [UIColor blackColor];
    ContentlabelValue.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                             size:14];
    
    NSString *Contentvalue = [dic valueForKey:@"content"];
    if(Contentvalue==nil){
        ContentlabelValue.text=[NSString stringWithFormat:@" "];
    }else{
        ContentlabelValue.text=[NSString stringWithFormat:@"%@", Contentvalue];
    }
    
    [ContentView addSubview: ContentlabelValue];
    
    UIView *DateView = [[UIView alloc]initWithFrame:CGRectMake(0, ContentView.frame.origin.y+ContentView.frame.size.height+10, screenWidth,screenHeight/56.8*6)];
    DateView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    [_scrollView addSubview:DateView];
    
    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth/32*0.5, screenHeight/56.8*6)];
    imageview3.image=[UIImage imageNamed:@"red.png"];
    [DateView addSubview:imageview3];
    
    UILabel *Datelabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*0.8,screenWidth,screenHeight/56.8*2.5)];
    Datelabel.backgroundColor = [UIColor clearColor];
    Datelabel.textColor = [UIColor colorWithRed:241/255.0 green:113/255.0 blue:125/255.0 alpha:1];
    Datelabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                     size:16];
    Datelabel.text = @"记录日期";
    [DateView addSubview:Datelabel];
    
    UILabel * DatelabelValue = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*3,screenWidth,screenHeight/56.8*2.5)];
    DatelabelValue.backgroundColor = [UIColor clearColor];
    DatelabelValue.textColor = [UIColor blackColor];
    DatelabelValue.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    NSString *Datevalue = [dic valueForKey:@"date"];
    if(Datevalue==nil){
        DatelabelValue.text=[NSString stringWithFormat:@" "];
    }else{
        DatelabelValue.text=[NSString stringWithFormat:@"%@", Datevalue];
    }
    
    [DateView addSubview: DatelabelValue];
    
    UIView *TimeView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/32*0.8, DateView.frame.origin.y+DateView.frame.size.height+10, screenWidth-screenWidth/32*1.6, screenHeight/56.8*3)];
    TimeView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    [_scrollView addSubview:TimeView];
    
    UILabel *Timelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*2, screenHeight/56.8*0.8,screenWidth/3.0,screenHeight/56.8*1.5)];
    Timelabel1.backgroundColor = [UIColor clearColor];
    Timelabel1.textColor = [UIColor whiteColor];
    Timelabel1.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                      size:15];
    Timelabel1.text = @"响铃时间";
    [TimeView addSubview:Timelabel1];
    
    UILabel *Timelabel2 = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*19, screenHeight/56.8*0.8,screenWidth/4.0,screenHeight/56.8*1.5)];
    Timelabel2.backgroundColor = [UIColor clearColor];
    Timelabel2.textColor = [UIColor whiteColor];
    Timelabel2.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                      size:15];
    Timelabel2.text = @"服药时间";
    [TimeView addSubview:Timelabel2];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth/32*0.8, TimeView.frame.origin.y+TimeView.frame.size.height, screenWidth-screenWidth/32*1.6, screenHeight/56.8*13) style:UITableViewStylePlain] ;
    // 设置tableView的数据源
    _tableView.dataSource = self;
    // 设置tableView的委托
    _tableView.delegate = self;
    
    _tableView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    [_scrollView addSubview:_tableView];
    _scrollView.contentSize = CGSizeMake(0, 2000);
}

-(void)showTimePicker:(void (^)(NSString *time_str))callbackHandler{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    //解释1,是用于给UIDatePicker留出空间的,因为UIDatePicker的大小是系统定死的,我试过用frame来设置,当然是没有效果的.
    //还有就是UIAlertControllerStyleActionSheet是用来设置ActionSheet还是alert的
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //增加子控件--直接添加到alert的view上面
    [alert.view addSubview:datePicker];
    //解释2: handler是一个block,当点击ok这个按钮的时候,就会调用handler里面的代码.
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];//设定时间格式
        //求出当天的时间字符串
        NSString *dateString = [dateFormat stringFromDate:datePicker.date];
        NSLog(@"%@",dateString);
        callbackHandler(dateString);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:ok];//添加按钮
    [alert addAction:cancel];//添加按钮
    //以modal的形式
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
/* 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section） */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}
/* 添加cell的点击事件 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [_medicationArr objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
    NSString *medication_time = [dic objectForKey:MEDICATION_TIME];
    //如果服药时间符合00:00格式
//    NSString *re = @"^\\d+:\\d+$";
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
//    if([pre evaluateWithObject:medication_time]){
    //如果服药时间不等于“点击补录服药记录”
    if(![medication_time isEqualToString:@"点击补录服药记录"]){
        [CommonUtil showAlertView:medication_time];
    }else{
        void (^callbackHandler)(NSString *) = ^(NSString *time_str) {
            NSString *recordId = [super.paramDic valueForKey:@"_id"];
//            NSString *title = [super.paramDic valueForKey:TITLE];
            //根据服药闹钟插入一条服药记录
            NSString *now_time = [DateUtil getStrFromDate:[NSDate date] formatStr:@"HH:mm"];
//            NSString *record_date = [DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyy-MM-dd"];
//            NSString *alarm_times = [AlarmClockDB_ queryClockTimeCount:dbDriver byClockId:clockId];
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//            [dic setValue:clockId forKey:CLOCK_ID];
//            [dic setValue:title forKey:TITLE];
//            [dic setValue:alarm_times forKey:ALARM_TIMES];
//            [dic setValue:record_date forKey:RECORD_DATE];
//            [dic setValue:[NSString stringWithFormat:@"%@(%@补录)",time_str,now_time] forKey:MEDICATION_TIME];
//            NSString *res = [MedicationRecordDB_ insertByDate:dbDriver dic:dic];
//            if([res isEqualToString:@"true"]){
//                //设置药品剩余剂量减1，返回药品剩余药量
//                NSString *expire_dose = [AlarmClockDB_ reduceClockExpireDose:dbDriver clockId:clockId];
//                //如果该药品剩余药量小于或等于0
//                if([expire_dose intValue]<=0){
//                    //设置该闹铃及闹钟所属下的所有闹铃过期
//                    [AlarmClockDB_ setClockExpire:dbDriver clockId:clockId];
//                }
//            }else{
//                [CommonUtil showAlertView:res];
//            }
            //根据服药闹钟插入一条服药记录
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:recordId,RECORD_ID,[NSString stringWithFormat:@"%@(%@补录)",time_str,now_time],MEDICATION_TIME, nil];
            NSString *res = [MedicationRecordDB_ insertDetail:dbDriver dic:dic];
            if([res isEqualToString:@"true"]){
                MedicationDetailViewController *parentPage = (MedicationDetailViewController*)super.parentPage;
                parentPage.dataChanged = true;
                //调用同步的函数
                NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
                [CommonUtil uploadRecord:user_id];
                //刷新列表显示的数据
                _medicationArr = [MedicationRecordDB_ queryDetailsByRecordId:dbDriver recordId:recordId];
                if(_medicationArr==nil){
                    _medicationArr = [[NSMutableArray alloc]init];
                }
                if(_medicationArr.count<_array.count){
                    for(int i=0;i<_array.count-_medicationArr.count;i++){
                        [_medicationArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"点击补录服药记录",MEDICATION_TIME, nil]];
                    }
                }
                //刷新列表视图控件显示的数据
                [tableView reloadData];
            }else{
                [CommonUtil errorAlertView:res];
            }
            
        };
        [self showTimePicker:callbackHandler];
    }
}
/* 修改cell高度的位置 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
/* 加载列表视图中每一项cell的视图 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //通过代码自定义cell
    UITableViewCell *cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
    return cell;
}
//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    UIFont *font = [UIFont systemFontOfSize:15];    //设置一个字体和文字大小
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc]init];
        label1.font = font;
        label1.tag = 1;
        label1.textColor = [UIColor brownColor];
        [cell.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]init];
        label2.tag = 2;
        label2.font = font;
        [cell.contentView addSubview:label2];
    }
    
    UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
    [label1 setTextColor:[UIColor whiteColor]];
    NSDictionary *dic1 = [_array objectAtIndex:indexPath.row];
    label1.text = [dic1 objectForKey:TIME_STR];
    //根据文字长度和字体计算文本框的长度
    CGSize label1Size = [label1.text sizeWithFont:font];
    [label1 setFrame:CGRectMake(20, (45-label1Size.height)/2, label1Size.width, label1Size.height)];
    
    UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
    [label2 setTextColor:[UIColor whiteColor]];
    NSDictionary *dic2 = [_medicationArr objectAtIndex:indexPath.row];
    label2.text = [dic2 objectForKey:MEDICATION_TIME];
    //根据文字长度和字体计算文本框的长度
    CGSize label2Size = [label2.text sizeWithFont:font];
    [label2 setFrame:CGRectMake(screenWidth-label2Size.width-20, (45-label2Size.height)/2, label2Size.width, label2Size.height)];
    
    return cell;
}

@end
