//
//  MedicationClockViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/25.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "MedicationClockViewController.h"
#import "MedicationDetailViewController.h"
#import "ClockDetailViewController.h"
#import "ClockSetViewController.h"
#import "TimeListViewController.h"
#import "ClockListViewController.h"
#import "MyCalendarView.h"
#import "ArcMenuView.h"
#import "UIColor+DIY.h"
#import "NotificationUtil.h"

#import "AlarmClockDB_.h"
#import "MedicationRecordDB_.h"
#import "BaseDB.h"

@interface MedicationClockViewController() <ArcMenuViewDelegate,MyCalendarViewDelegate, UITableViewDataSource,UITableViewDelegate>

@end

@implementation MedicationClockViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    int dateState;
    NSMutableArray *_table_array1;      //列表视图控件中要显示的数据的列表
    NSMutableArray *_table_array2;
    UITableView *_tableView;     //列表视图控件
    UILabel *_nowDay_label;
    UILabel *noDataLabelView;
    MyCalendarView *_calendarView;
    
    //创建操作数据库的对象
    BaseDB *dbDriver;
}

//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openClock = [UIAlertAction actionWithTitle:@"打开闹钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了打开闹钟");
        //创建列表视图的数据列表
        NSArray *timeArr = [AlarmClockDB_ getNotificationTime:dbDriver];
        NSLog(@"timeArr=%@",timeArr);
        for(NSString *timeStr in timeArr){
            [NotificationUtil setNotificationWithTimeStr:timeStr];
        }
    }];
    UIAlertAction *closeClock = [UIAlertAction actionWithTitle:@"关闭闹钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了关闭闹钟");
        [NotificationUtil cancelAllNotification];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:openClock];
    [alert addAction:closeClock];
    [alert addAction:cancel];
    //以modal的形式
    [self presentViewController:alert animated:YES completion:^{ }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置页面的背景颜色
    self.view.backgroundColor = [UIColor myBgColor];
    //设置导航栏标题
    [self.navigationItem setTitle:@"服药记录日历"];
    //添加导航栏右边的按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
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
    
    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    //创建列表视图的数据
    _table_array1 = [[NSMutableArray alloc] init];
    _table_array2 = [[NSMutableArray alloc] init];
    _table_array2 = [AlarmClockDB_ query:dbDriver byState:1];
    
    //初始化界面控件
    [self initView];
    
    //初始化默认选中当前日期
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSString *dstr = [fmt stringFromDate:[NSDate date]];
    [self selectDate:dstr];
    
    //注册notification的监听函数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"medication" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    if(_refresh==YES){
        _table_array2 = [AlarmClockDB_ query:dbDriver byState:1];
        [_calendarView refresh];
        _refresh = NO;
    }
}
//notification传值 自定义接收信息和处理的方法
- (void) notificationHandler:(NSNotification *) notification{
    _table_array2 = [AlarmClockDB_ query:dbDriver byState:1];
    [_calendarView refresh];
    NSLog(@"notificationHandler");
}

-(void)initView{
    //创建日历视图控件
    _calendarView = [[MyCalendarView alloc] initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight*7/15)];
    _calendarView.delegate = self;       //日历视图控件的函数接口在本类中实现
    [self.view addSubview:_calendarView];    //把日历视图控件添加到本类的布局视图中
    
    //创建要标记的日期的数据列表
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM"];
    NSMutableSet *calendarMarkDayArr = [MedicationRecordDB_ queryState:dbDriver byYearMonthStr:[fmt stringFromDate:[NSDate date]]];
    //把要标记的日期的列表设置到日历视图控件中去
    [_calendarView setMarkDay:calendarMarkDayArr];
    
    
    
    //初始化显示日期的文本框
    _nowDay_label = [[UILabel alloc] initWithFrame:CGRectMake(0 ,y0+screenHeight*6.6/15, 100, screenHeight/15)];
    [_nowDay_label setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_nowDay_label];
    
    //创建列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, y0+screenHeight*7.4/15, screenWidth, screenHeight*8/15) style:UITableViewStylePlain];
    //设置列表视图控件底部背景颜色透明度
    _tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //去掉分割线
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    //添加列表视图到页面视图
    [self.view addSubview:_tableView];
    
    //初始化无数据时显示的文本框
    noDataLabelView = [[UILabel alloc] init];
    [noDataLabelView setTextColor:[UIColor blackColor]];
    noDataLabelView.text=@"暂无服药纪录";
    //根据文字长度和字体计算文本框的长度
    CGSize noData_labelSize = [noDataLabelView.text sizeWithFont:noDataLabelView.font];
    [noDataLabelView setFrame:CGRectMake((screenWidth-noData_labelSize.width)/2, y0+screenHeight*21/30, noData_labelSize.width, screenHeight/15)];
    [self.view addSubview:noDataLabelView];
    noDataLabelView.hidden = YES;
    
    //添加卫星菜单
    ArcMenuView *arcMenuView = [[ArcMenuView alloc] initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight)];
    arcMenuView.delegate = self;
    [self.view addSubview:arcMenuView];
}

/** 实现卫星菜单展开时的接口函数 **/
- (void)ArcMenuWillExpand:(ArcMenuLayout *)menu {
}
/** 实现卫星菜单折叠时的接口函数 **/
- (void)ArcMenuWillUnExpand:(ArcMenuLayout *)menu {
}
/** 实现卫星菜单点击时的接口函数 **/
- (void)ArcMenuView:(ArcMenuLayout *)menu didSelectedForIndex:(NSInteger)index {
    if(index==0){
        ClockListViewController *viewController = [[ClockListViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if(index==1){
        TimeListViewController *viewController = [[TimeListViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if(index==2){
        ClockSetViewController *viewController = [[ClockSetViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

/** 重写MyCalendarViewDelegate接口中选择日期的函数 **/
-(void)MyCalendarView:(MyCalendarView *)view dateSelected:(NSDate *)date{
    //获取日期的字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSString *dstr = [fmt stringFromDate:date];
    NSString *nowDateStr = [fmt stringFromDate:[NSDate date]];
    NSComparisonResult result = [dstr compare:nowDateStr];
    switch (result) {
        case NSOrderedAscending:
            NSLog(@"str1<str2");
            dateState = -1;
            break;
        case NSOrderedSame:
            NSLog(@"str1=str2");
            dateState = 0;
            break;
        case NSOrderedDescending:
            NSLog(@"str1>str2");
            dateState = 1;
            break;
        default:
            break;
    }
    [self selectDate:dstr];
}
/** 重写MyCalendarViewDelegate接口中改变显示月份的函数 **/
-(void)MyCalendarView:(MyCalendarView *)view monthChanged:(NSString *)strYearMonth{
    NSLog(@"月份改变函数%@", strYearMonth);
    //创建要标记的日期的数据列表
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM"];
    NSMutableSet *calendarMarkDayArr = [MedicationRecordDB_ queryState:dbDriver byYearMonthStr:strYearMonth];
    [calendarMarkDayArr addObject:@"2016-03-03"];   //测试数据
    //把要标记的日期的列表设置到日历视图控件中去
    [view setMarkDay:calendarMarkDayArr];
}

//封装选中一个日期时的函数
-(void)selectDate:(NSString*)dateStr{
    //设置显示日期的文本框
    [_nowDay_label setText:dateStr];
    
    //刷新列表视图控件
    [_table_array1 removeAllObjects];       //清空列表数据
    _table_array1 = [MedicationRecordDB_ queryRecordByDate:dbDriver dateStr:dateStr];
    [_tableView reloadData];         //刷新列表视图控件中的数据
    //如果没有数据，显示无数据时的文本框
    if(dateState==-1 && [_table_array1 count]==0){
        noDataLabelView.hidden = NO;
    }else{
        noDataLabelView.hidden = YES;
    }
}

/** 这个函数是显示tableview章节数section，即列表中的大节点 **/
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    if(dateState==0){
        return 2;
    }else{
        return 1;
    }
}
/** 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点section **/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (dateState) {
        case -1:
            return [_table_array1 count];
            break;
        case 1:
            return [_table_array2 count];
            break;
        default:
            if(section==0){
                return [_table_array1 count];
            }else{
                return [_table_array2 count];
            }
            break;
    }
}
/* 返回每组头标题名称 */
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (dateState) {
        case -1:
            return @"服药记录";
            break;
        case 1:
            return @"服药闹钟";
            break;
        default:
            if(section==0){
                return @"服药记录";
            }else{
                return @"服药闹钟";
            }
            break;
    }
}
/** 添加cell的点击事件 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int type;
    switch (dateState) {
        case -1:
            type=1;
            break;
        case 1:
            type=2;
            break;
        default:
            if(indexPath.section==0){
                type=1;
            }else{
                type=2;
            }
            break;
    }
    
    if(type==1){
        //获取点击的列表数据
        NSDictionary *dic = [_table_array1 objectAtIndex:[indexPath row]];
        //创建服药明细的页面
        MedicationDetailViewController *viewController = [[MedicationDetailViewController alloc] init];
        //将点击的项的数据传入要跳转的页面
        viewController.paramDic = [NSDictionary dictionaryWithDictionary:dic];
        //执行页面跳转
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        //获取点击的列表数据
        NSDictionary *dic = [_table_array2 objectAtIndex:[indexPath row]];
        //创建服药明细的页面
        ClockDetailViewController *viewController = [[ClockDetailViewController alloc] init];
        //将点击的项的数据传入要跳转的页面
        viewController.paramDic = [NSDictionary dictionaryWithDictionary:dic];
        //执行页面跳转
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
/** 修改cell高度的位置 **/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
/** 加载列表视图中每一项cell的视图 **/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    switch (dateState) {
        case -1:
            //通过nib自定义cell
            cell = [self customCellWithOutXib1:tableView withIndexPath:indexPath];
            break;
        case 1:
            //通过通过代码生成自定义cell
            cell = [self customCellWithOutXib2:tableView withIndexPath:indexPath];
            break;
        default:
            if(indexPath.section==0){
                //通过nib自定义cell
                cell = [self customCellWithOutXib1:tableView withIndexPath:indexPath];
            }else{
                //通过通过代码生成自定义cell
                cell = [self customCellWithOutXib2:tableView withIndexPath:indexPath];
            }
            break;
    }
    return cell;
}
//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib1:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    UIFont *font = [UIFont systemFontOfSize:15];    //设置一个字体和文字大小
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        //设置cell每一项的视图底部背景透明
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
    //取得相应行数的数据
    NSDictionary *dic = [_table_array1 objectAtIndex:indexPath.row];  //这个表示选中的那个cell上的数据
    if(dic!=nil){
        
        UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
        [label1 setTextColor:[UIColor whiteColor]];
        label1.text = [dic objectForKey:CLOCK_TITLE];
        //根据文字长度和字体计算文本框的长度
        CGSize label1Size = [label1.text sizeWithFont:font];
        [label1 setFrame:CGRectMake(20, (45-label1Size.height)/2, label1Size.width, label1Size.height)];
        
        UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
        [label2 setTextColor:[UIColor whiteColor]];
        label2.text = [[NSString alloc] initWithFormat:@"当日服药情况：%@/%@", [dic objectForKey:@"medication_state"], [dic objectForKey:@"alarm_times"]];
        //根据文字长度和字体计算文本框的长度
        CGSize label2Size = [label2.text sizeWithFont:font];
        [label2 setFrame:CGRectMake(screenWidth-label2Size.width-20, (45-label1Size.height)/2, label2Size.width, label2Size.height)];
        
    }
    return cell;
}
-(UITableViewCell *)customCellWithOutXib2:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    UIFont *font = [UIFont systemFontOfSize:15];    //设置一个字体和文字大小
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        //设置cell每一项的视图底部背景透明
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
    //取得相应行数的数据
    NSDictionary *dic = [_table_array2 objectAtIndex:indexPath.row];  //这个表示选中的那个cell上的数据
    if(dic!=nil){
        
        UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
        [label1 setTextColor:[UIColor whiteColor]];
        label1.text = [dic objectForKey:CLOCK_TITLE];
        //根据文字长度和字体计算文本框的长度
        CGSize label1Size = [label1.text sizeWithFont:font];
        [label1 setFrame:CGRectMake(20, (45-label1Size.height)/2, label1Size.width, label1Size.height)];
        
        UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
        [label2 setTextColor:[UIColor whiteColor]];
        label2.text = [[NSString alloc] initWithFormat:@"剩余剂量：%@", [dic objectForKey:EXPIRE_DOSE]];
        //根据文字长度和字体计算文本框的长度
        CGSize label2Size = [label2.text sizeWithFont:font];
        [label2 setFrame:CGRectMake(screenWidth-label2Size.width-20, (45-label1Size.height)/2, label2Size.width, label2Size.height)];
        
    }
    return cell;
}

@end
