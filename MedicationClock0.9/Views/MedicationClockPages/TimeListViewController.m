//
//  TimeListViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "TimeListViewController.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "AlarmClockDB_.h"

@interface TimeListViewController ()

@end

@implementation TimeListViewController{
    int screenWidth;
    int screenHeight;
    
    UITableView *_tableView;
    NSMutableArray *_array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //设置页面的背景颜色
    //self.view.backgroundColor = [UIColor myBgColor];
        //设置导航栏标题
    [self.navigationItem setTitle:@"闹铃时间"];
    //初始化页面数据
    [self initData];
    //初始化视图控件
    [self initView];
}
-(void)initData{
    //创建操作数据库的对象
    BaseDB *dbDriver = [[BaseDB alloc]init];
    //创建列表视图的数据列表
    _array = [AlarmClockDB_ queryTimeListDistinct:dbDriver];
    if(_array.count==0){
        for(int i=0;i<5;i++){
            //        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"李小龙",@"name",@"讲师",@"type", @"C406", @"office",nil];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:@"08:30" forKey:@"alarm_time"];
            [dic setValue:@"阿莫西林" forKey:@"content"];
            [_array addObject:dic];
        }
    }
}
-(void)initView{
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height;
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth,  screenHeight)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    //创建列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = NO;
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //添加列表视图到页面视图
    [self.view addSubview:_tableView];
}

/* 在本类中实现接口中的函数 */
// 这个函数是显示tableview章节数section，即列表中的大节点
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
// 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}
// 添加cell的点击事件
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // NSDictionary *dic = [_array objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
   // NSString *titileString = [dic objectForKey:@"name"];
   // UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:titileString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //[alert show];
//}
//修改cell高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
//加载列表视图中每一项cell的视图
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
    return cell;
}

//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        cell.backgroundColor = [UIColor clearColor];
        //闹铃时间
        UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(80, 15, screenWidth-80-15, 40)];
        view1.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [view1.layer setCornerRadius:5.0];
        [cell.contentView addSubview:view1];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, view1.frame.size.width-15, 20)];
        label1.tag = 1;
        label1.font = [UIFont boldSystemFontOfSize:18];
        label1.textColor = [UIColor whiteColor];
        [view1 addSubview:label1];
        
        //药品内容
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(80, 65, screenWidth-80-15, 35)];
        view2.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [cell.contentView addSubview:view2];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, view2.frame.size.width-20, 15)];
        label2.tag = 2;
        label2.font = [UIFont boldSystemFontOfSize:18];
        label2.textColor = [UIColor whiteColor];
        [view2 addSubview:label2];
        
        //竖线
        UIView *line1View = [[UIView alloc]initWithFrame:CGRectMake(35, 0, 2, 15)];
        line1View.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:line1View];
        UIView *line2View = [[UIView alloc]initWithFrame:CGRectMake(35, 55, 2, 65)];
        line2View.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:line2View];
        //图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
        imageView.image = [UIImage imageNamed:@"ring"];
        [cell.contentView addSubview:imageView];
    }
    
    NSDictionary *dic  = [_array objectAtIndex:[indexPath row]];
    //显示闹铃时间
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:1];
    label1.text = [dic valueForKey:@"alarm_time"];
    //显示药品内容
    NSString *clockStr = [[NSString alloc]init];
    NSArray *clockArr = [dic objectForKey:@"clockArr"];
    for(int i=0;i<clockArr.count;i++){
        NSDictionary *tempDic = [clockArr objectAtIndex:i];
        NSString *clock_title = [tempDic valueForKey:CLOCK_TITLE];
        if(i==0){
            clockStr = [clockStr stringByAppendingFormat:@"%@",clock_title];
        }else{
            clockStr = [clockStr stringByAppendingFormat:@",%@",clock_title];
        }
    }
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:2];
    label2.text = clockStr;
    
    return cell;
}

@end
