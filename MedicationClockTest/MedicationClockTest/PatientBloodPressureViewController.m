//
//  PatientBloodPressureViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/13.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "PatientBloodPressureViewController.h"
#import "MyCalendarView.h"
#import "UIColor+DIY.h"
#import "AppConfig.h"
#import "HttpUtil.h"

@interface PatientBloodPressureViewController ()<MyCalendarViewDelegate, UITableViewDataSource,UITableViewDelegate>

@end

@implementation PatientBloodPressureViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    NSMutableArray *_table_array;      //列表视图控件中要显示的数据的列表
    UITableView *_tableView;     //列表视图控件
    UILabel *_dateLabelView;
    UILabel *noDataLabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置页面的背景颜色
    self.view.backgroundColor = [UIColor myBgColor];
    //设置导航栏标题
    [self.navigationItem setTitle:@"血压记录日历"];
    // Do any additional setup after loading the view from its nib.
    //创建列表视图的数据列表
    _table_array = [[NSMutableArray alloc] init];
    //初始化界面控件
    [self initView];
}
-(void)initView{
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
    
    //创建日历视图控件
    MyCalendarView *calendarView = [[MyCalendarView alloc] initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight*7/15)];
    calendarView.delegate = self;       //日历视图控件的函数接口在本类中实现
    [self.view addSubview:calendarView];    //把日历视图控件添加到本类的布局视图中
    
    //启动读取标记的日期的数据列表的线程
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM"];
    [self getMarkDate:[fmt stringFromDate:[NSDate date]] calendarView:calendarView];
    
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
-(void)getMarkDate:(NSString*)yearAndMonth calendarView:(MyCalendarView*)calendarView{
    NSString *urlStr = [NSString stringWithFormat:@"%@!selectPressureState.ac", ClockActionUrl];
    NSString *params = [NSString stringWithFormat:@"user_id=%@&record_date=%@", [_paramDic objectForKey:@"user_id"], yearAndMonth];
    
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"载入中" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loadingAlert animated:YES completion:^() {
        //打开对话框完成时打开访问网络的函数
        [HttpUtil httpPost:urlStr param:params callbackHandler:^(NSData *data, NSError *error) {
            //访问网络的回调函数中调用关闭载入中对话框
            [loadingAlert dismissViewControllerAnimated:YES completion:^() {
                //关闭对话框完成的回调函数
                if ([data length] > 0 && error == nil) {
                    //解析json格式数据
                    NSError *error;
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if(error==nil){       //如果json解析正确
                        NSArray *jsonArrMonth = [jsonDictionary valueForKey:@"monthRecordArray"];
                        NSMutableSet *calendarMarkDayArr = [[NSMutableSet alloc]init];
                        for(NSDictionary *dic in jsonArrMonth){
                            NSString *systolic_pressure = [dic valueForKey:@"systolic_pressure"];
                            NSString *diastolic_pressure = [dic valueForKey:@"diastolic_pressure"];
                            NSString *heart_rate = [dic valueForKey:@"heart_rate"];
                            NSString *record_date = [dic valueForKey:@"record_date"];
                            if([AppConfig isSystolicPressureRegular:systolic_pressure]
                               && [AppConfig isDiastolicPressureRegular:diastolic_pressure]
                               && [AppConfig isHeartRateRegular:heart_rate]){
                                //如果收缩压舒张压和心率都正常，则表示数据状态为正常
                            }else{
                                //否则不正常
                                [calendarMarkDayArr addObject:record_date];
                            }
                        }
                        //把要标记的日期的列表设置到日历视图控件中去
                        [calendarView setMarkDay:calendarMarkDayArr];
                        
                        NSArray *jsonArrDay = [jsonDictionary valueForKey:@"dateRecordArray"];
                        [_table_array setArray:jsonArrDay];
                        //刷新列表视图控件中的数据
                        [_tableView reloadData];
                        //如果没有数据，显示无数据时的文本框
                        if([_table_array count]>0){
                            noDataLabelView.hidden = YES;
                        }else{
                            noDataLabelView.hidden = NO;
                        }
                    }else{
                        //否则显示错误信息
                        NSLog(@"error=%@", error);
                        //读取返回字符串
                        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        //弹出对话框 从IOS9.0起这种方法就过时了
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:receiveStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }else if ([data length] == 0 && error == nil){
                    NSLog(@"Nothing was downloaded.");
                }else if (error != nil){
                    NSLog(@"Error happened = %@",error);
                }
            }];
        }];
    }];
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
    NSLog(@"月份改变函数%@", strYearMonth);
    //创建要标记的日期的数据列表
    [self getMarkDate:strYearMonth calendarView:view];
}

//封装选中一个日期时的函数
-(void)selectDate:(NSString*)dateStr{
    //设置显示日期的文本框
    [_dateLabelView setText:dateStr];
    
    //刷新列表视图控件
    [_table_array removeAllObjects];       //清空列表数据
    NSString *urlStr = [NSString stringWithFormat:@"%@!selectPressureByDate.ac", ClockActionUrl];
    NSString *params = [NSString stringWithFormat:@"user_id=%@&record_date=%@", [_paramDic objectForKey:@"user_id"], dateStr];
    
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"载入中" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loadingAlert animated:YES completion:^() {
        //打开对话框完成时打开访问网络的函数
        [HttpUtil httpPost:urlStr param:params callbackHandler:^(NSData *data, NSError *error) {
            //访问网络的回调函数中调用关闭载入中对话框
            [loadingAlert dismissViewControllerAnimated:YES completion:^() {
                //关闭对话框完成的回调函数
                if ([data length] > 0 && error == nil) {
                    //解析json格式数据
                    NSError *error;
                    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if(error==nil){       //如果json解析正确
                        [_table_array setArray:jsonArr];
                        //刷新列表视图控件中的数据
                        [_tableView reloadData];
                        //如果没有数据，显示无数据时的文本框
                        if([_table_array count]>0){
                            noDataLabelView.hidden = YES;
                        }else{
                            noDataLabelView.hidden = NO;
                        }
                    }else{
                        //否则显示错误信息
                        NSLog(@"error=%@", error);
                        //读取返回字符串
                        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        //弹出对话框 从IOS9.0起这种方法就过时了
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:receiveStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }else if ([data length] == 0 && error == nil){
                    NSLog(@"Nothing was downloaded.");
                }else if (error != nil){
                    NSLog(@"Error happened = %@",error);
                }
            }];
        }];
    }];
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
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [_tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //通过代码自定义cell
        cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
        //设置cell每一项的视图底部背景透明
        cell.backgroundColor = [UIColor clearColor];
    }
    //    assert(cell != nil);      //assert断言，即如果为真则不影响程序的运行，如果为假则程序直接退出或抛出异常（暂时我也还没搞清楚）
    return cell;
}

//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    UIFont *font = [UIFont systemFontOfSize:17];    //设置一个字体和文字大小
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        
        UILabel *label1 = [[UILabel alloc]init];
        label1.font = font;
        label1.tag = 1;
        label1.textColor = [UIColor brownColor];
        [cell.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]init];
        label2.tag = 2;
        label2.font = font;
        [cell.contentView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]init];
        label3.tag = 3;
        label3.font = font;
        [cell.contentView addSubview:label3];
        
        UILabel *label4 = [[UILabel alloc]init];
        label4.tag = 4;
        label4.font = font;
        [cell.contentView addSubview:label4];
    }
    NSUInteger row = [indexPath row];
    NSDictionary *dic  = [_table_array objectAtIndex:row];
    
    UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
    [label1 setTextColor:[UIColor whiteColor]];
    label1.text = [dic objectForKey:@"record_time"];
    //根据文字长度和字体计算文本框的长度
    CGSize label1Size = [label1.text sizeWithFont:font];
    [label1 setFrame:CGRectMake(20, (45-label1Size.height)/2, label1Size.width, label1Size.height)];
    
    NSString *diastolic_pressure = [dic objectForKey:@"diastolic_pressure"];
    UILabel *label3 = ((UILabel *)[cell.contentView viewWithTag:3]);
    if([AppConfig isDiastolicPressureRegular:diastolic_pressure]){
        [label3 setTextColor:[UIColor whiteColor]];
    }else{
        [label3 setTextColor:[UIColor redColor]];
    }
    label3.text = [[NSString alloc] initWithFormat:@"舒张压：%@", diastolic_pressure];
    //根据文字长度和字体计算文本框的长度
    CGSize label3Size = [label3.text sizeWithFont:font];
    [label3 setFrame:CGRectMake(screenWidth-label3Size.width-20, 45/2-label3Size.height, label3Size.width, label3Size.height)];
    
    NSString *systolic_pressure = [dic objectForKey:@"systolic_pressure"];
    UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
    if([AppConfig isSystolicPressureRegular:systolic_pressure]){
        [label2 setTextColor:[UIColor whiteColor]];
    }else{
        [label2 setTextColor:[UIColor redColor]];
    }
    label2.text = [[NSString alloc] initWithFormat:@"收缩压：%@", systolic_pressure];
    //根据文字长度和字体计算文本框的长度
    CGSize label2Size = [label2.text sizeWithFont:font];
    [label2 setFrame:CGRectMake(label3.frame.origin.x-label2Size.width-10, 45/2-label2Size.height, label2Size.width, label2Size.height)];
    
    NSString *heart_rate = [dic objectForKey:@"heart_rate"];
    UILabel *label4 = ((UILabel *)[cell.contentView viewWithTag:4]);
    if([AppConfig isHeartRateRegular:heart_rate]){
        [label4 setTextColor:[UIColor whiteColor]];
    }else{
        [label4 setTextColor:[UIColor redColor]];
    }
    label4.text = [[NSString alloc] initWithFormat:@"心率：%@", heart_rate];
    //根据文字长度和字体计算文本框的长度
    CGSize label4Size = [label4.text sizeWithFont:font];
     [label4 setFrame:CGRectMake(screenWidth-label4Size.width-20, 45/2, label4Size.width, label4Size.height)];
    
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
