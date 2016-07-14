//
//  BloodSugarViewController.m
//  Learn2
//
//  Created by 歐陽 on 16/3/16.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodSugarViewController.h"
#import "AddBloodSugarViewController.h"
#import "MyCalendarView.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "BloodSugarDB.h"

@interface BloodSugarViewController() <MyCalendarViewDelegate, UITableViewDataSource,UITableViewDelegate>

@end

@implementation BloodSugarViewController{
    NSMutableArray *_table_array;      //列表视图控件中要显示的数据的列表
    UITableView *_tableView;     //列表视图控件
    UILabel *_dateLabelView;
    UILabel *noDataLabelView;
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置页面的背景颜色
    self.view.backgroundColor = [UIColor myBgColor];
    //设置导航栏标题
    [self.navigationItem setTitle:@"血糖记录日历"];
    //创建一个导航栏右边的按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    //把导航栏按钮添加到导航栏中去
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    
    //创建列表视图的数据
    _table_array = [[NSMutableArray alloc] init];
    
    //初始化界面控件
    [self initView];
    
    //初始化默认选中当前日期
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSString *dstr = [fmt stringFromDate:[NSDate date]];
    [self selectDate:dstr];
}
//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    UIViewController *viewController= [[AddBloodSugarViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)initView{
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
    
    //创建日历视图控件
    MyCalendarView *calendarView = [[MyCalendarView alloc] initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight*7/15)];
    calendarView.delegate = self;       //日历视图控件的函数接口在本类中实现
    [self.view addSubview:calendarView];    //把日历视图控件添加到本类的布局视图中
    
    //创建要标记的日期的数据列表
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM"];
    NSMutableSet *calendarMarkDayArr = [BloodSugarDB queryState:dbDriver byYearMonthStr:[fmt stringFromDate:[NSDate date]]];
    //把要标记的日期的列表设置到日历视图控件中去
    [calendarView setMarkDay:calendarMarkDayArr];
    
    //初始化显示日期的文本框
    _dateLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0 ,y0+screenHeight*7/15, 100, screenHeight/15)];
    [_dateLabelView setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_dateLabelView];
    
    //创建列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, y0+screenHeight*8/15, screenWidth, screenHeight*7/15) style:UITableViewStylePlain];
    //设置列表视图控件底部背景颜色透明度
    _tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //添加列表视图到页面视图
    [self.view addSubview:_tableView];
    
    //初始化无数据时显示的文本框
    noDataLabelView = [[UILabel alloc] init];
    [noDataLabelView setTextColor:[UIColor whiteColor]];
    noDataLabelView.text=@"暂无数据";
    //根据文字长度和字体计算文本框的长度
    CGSize noData_labelSize = [noDataLabelView.text sizeWithFont:noDataLabelView.font];
    [noDataLabelView setFrame:CGRectMake((screenWidth-noData_labelSize.width)/2, y0+screenHeight*21/30, noData_labelSize.width, screenHeight/15)];
    [self.view addSubview:noDataLabelView];
    noDataLabelView.hidden = YES;
}

/** 重写MyCalendarViewDelegate接口中选择日期的函数 **/
-(void)MyCalendarView:(MyCalendarView *)view dateSelected:(NSDate *)date{
    //获取日期的字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSString *dstr = [fmt stringFromDate:date];
    NSLog(@"选择日期的函数%@",dstr);
    [self selectDate:dstr];
}
/** 重写MyCalendarViewDelegate接口中改变显示月份的函数 **/
-(void)MyCalendarView:(MyCalendarView *)view monthChanged:(NSString *)strYearMonth{
    NSLog(@"月份改变函数a%@", strYearMonth);
    //创建要标记的日期的数据列表
    NSMutableSet *calendarMarkDayArr = [BloodSugarDB queryState:dbDriver byYearMonthStr:strYearMonth];
    //把要标记的日期的列表设置到日历视图控件中去
    [view setMarkDay:calendarMarkDayArr];
}

//封装选中一个日期时的函数
-(void)selectDate:(NSString*)dateStr{
    //设置显示日期的文本框
    [_dateLabelView setText:dateStr];
    
    //刷新列表视图控件
    [_table_array removeAllObjects];       //清空列表数据
    _table_array = [BloodSugarDB query:dbDriver byDateStr:dateStr];
    [_tableView reloadData];         //刷新列表视图控件中的数据
    
    //如果没有数据，显示无数据时的文本框
    if([_table_array count]>0){
        noDataLabelView.hidden = YES;
    }else{
        noDataLabelView.hidden = NO;
    }
}

/** 这个函数是显示tableview章节数section，即列表中的大节点 **/
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
/** 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点section **/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_table_array count];
}
/** 添加cell的点击事件 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [_table_array objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
    NSString *titileString = [dic objectForKey:@"record_time"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:titileString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
/** 修改cell高度的位置 **/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
/** 加载列表视图中每一项cell的视图 **/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //通过nib自定义cell
    UITableViewCell *cell = [self customCellByXib:tableView withIndexPath:indexPath];
    //设置cell每一项的视图底部背景透明
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

// 通过nib文件自定义cell
-(UITableViewCell *)customCellByXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    static NSString *customXibCellIdentifier = @"CustomXibCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customXibCellIdentifier];
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"BloodSugarTableViewCell" owner:self options:nil];//加载nib文件
        if([nib count]>0){
            cell = _tableCellView;
        }else{
            assert(NO);//读取文件失败
        }
    }
    NSUInteger row = [indexPath row];
    NSDictionary *dic  = [_table_array objectAtIndex:row];
    
    UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
    [label1 setTextColor:[UIColor whiteColor]];
    label1.text = [dic objectForKey:@"record_time"];
    
    UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
    [label2 setTextColor:[UIColor whiteColor]];
    label2.text = [dic objectForKey:@"blood_sugar"];
    
    UILabel *label3 = ((UILabel *)[cell.contentView viewWithTag:3]);
    [label3 setTextColor:[UIColor whiteColor]];
    NSString * after_meal = [dic objectForKey:@"after_meal"];
    if([after_meal isEqual:@"false"]){
        label3.text = @"(饭前)";
    }else if([after_meal isEqual:@"true"]){
        label3.text = @"(饭后)";
    }else{
        label3.text = @"";
    }
    
    return cell;
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
