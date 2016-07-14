//
//  ClockDetailViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/26.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ClockDetailViewController.h"
#import "UIColor+DIY.h"
#import "BaseDB.h"
#import "AlarmClockDB_.h"

@interface ClockDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ClockDetailViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    NSMutableArray *_array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置页面的背景颜色
//    self.view.backgroundColor = [UIColor myBgColor];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    //设置导航栏标题
    [self.navigationItem setTitle:@"闹钟详情"];
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
    screenHeight = rect.size.height;
    // Do any additional setup after loading the view from its nib.
    if(_paramDic!=nil){
        NSLog(@"_dic=%@", _paramDic);
        NSString *clock_id = [_paramDic valueForKey:@"_id"];
        BaseDB *dbDriver = [[BaseDB alloc]init];
        _array = [AlarmClockDB_ queryTimeList:dbDriver clockId:clock_id];
        NSLog(@"_array=%@", _array);
        
        [self initView:_paramDic];
    }else{
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setValue:@"暂无数据" forKey:@"title"];
        [dic setValue:@"暂无数据" forKey:@"content"];
        [dic setValue:@"暂无数据" forKey:@"start_date"];
        [dic setValue:@"暂无数据" forKey:@"expire_dose"];
        [self initView:dic];
        _array = [[NSMutableArray alloc] init];
        for(int i=0;i<2;i++){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"14:28",TIME_STR, nil];
            [_array addObject:dic];
        }
    }
}

-(void)initView:(NSDictionary*)dic{
    
    /*
     UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(129, 30,138,25)];
     label1.backgroundColor = [UIColor clearColor];
     label1.textColor = [UIColor blueColor];
     label1.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
     size:20];
     label1.text = @"闹钟详情";
     
     [self.view addSubview:label1];
     */
    
    UIView *TitleView = [[UIView alloc]initWithFrame:CGRectMake(0,screenHeight/56.8*7.5, screenWidth,screenHeight/56.8*6)];
    TitleView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:TitleView];
    
    
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
    
    
    UILabel *TitlelabelValue = [[UILabel alloc]initWithFrame:CGRectMake(15, screenHeight/56.8*3,screenWidth,screenHeight/56.8*2.5)];
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
    
    UIView *ContentView = [[UIView alloc]initWithFrame:CGRectMake(0,screenHeight/56.8*14.5, screenWidth,screenHeight/56.8*6)];
    ContentView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:ContentView];
    
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
    
    UIView *DateView = [[UIView alloc]initWithFrame:CGRectMake(0,screenHeight/56.8*21.5, screenWidth,screenHeight/56.8*6)];
    DateView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:DateView];
    
    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth/32*0.5, screenHeight/56.8*6)];
    imageview3.image=[UIImage imageNamed:@"xx.png"];
    [DateView addSubview:imageview3];
    
    UILabel *Datelabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*0.8,screenWidth,screenHeight/56.8*2.5)];
    Datelabel.backgroundColor = [UIColor clearColor];
    Datelabel.textColor = [UIColor colorWithRed:244/255.0 green:236/255.0 blue:37/255.0 alpha:1];
    Datelabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                     size:16];
    Datelabel.text = @"起始日期";
    [DateView addSubview:Datelabel];
    
    UILabel * DatelabelValue = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*3,screenWidth,screenHeight/56.8*2.5)];
    DatelabelValue.backgroundColor = [UIColor clearColor];
    DatelabelValue.textColor = [UIColor blackColor];
    DatelabelValue.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    NSString *Datevalue = [dic valueForKey:@"start_date"];
    if(Datevalue==nil){
        DatelabelValue.text=[NSString stringWithFormat:@" "];
    }else{
        DatelabelValue.text=[NSString stringWithFormat:@"%@", Datevalue];
    }
    
    [DateView addSubview: DatelabelValue];
    
    UIView *DoseView = [[UIView alloc]initWithFrame:CGRectMake(0,screenHeight/56.8*28.5, screenWidth,screenHeight/56.8*6)];
    DoseView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:DoseView];
    
    UIImageView *imageview4=[[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, screenWidth/32*0.5, screenHeight/56.8*6)];
    imageview4.image=[UIImage imageNamed:@"red.png"];
    [DoseView addSubview:imageview4];
    
    UILabel *Doselabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*0.8,screenWidth,screenHeight/56.8*2.5)];
    Doselabel.backgroundColor = [UIColor clearColor];
    Doselabel.textColor = [UIColor colorWithRed:241/255.0 green:113/255.0 blue:125/255.0 alpha:1];
    Doselabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                     size:16];
    Doselabel.text = @"剩余剂量";
    [DoseView addSubview:Doselabel];
    
    UILabel * DoselabelValue = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*1.5, screenHeight/56.8*3,screenWidth,screenHeight/56.8*2.5)];
    DoselabelValue.backgroundColor = [UIColor clearColor];
    DoselabelValue.textColor = [UIColor blackColor];
    DoselabelValue.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                          size:14];
    
    NSString *Dosevalue = [dic valueForKey:@"expire_dose"];
    if(Dosevalue==nil){
        DoselabelValue.text=[NSString stringWithFormat:@" "];
    }else{
        DoselabelValue.text=[NSString stringWithFormat:@"%@", Dosevalue];
    }
    
    [DoseView addSubview: DoselabelValue];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32*2, screenHeight/56.8*35.5,screenWidth/32*13.8,screenHeight/56.8*2.5)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                  size:18];
    label2.text = @"响铃时间";
    [self.view addSubview:label2];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenHeight/56.8*39,screenWidth,screenHeight/56.8*10) style:UITableViewStylePlain] ;
    // 设置tableView的数据源
    tableView.dataSource = self;
    // 设置tableView的委托
    tableView.delegate = self;
    
    tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView];
    
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
    NSDictionary *dic = [_array objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
    NSString *titileString = [dic objectForKey:TIME_STR];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:titileString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
/* 修改cell高度的位置 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return screenHeight/56.8*5;
}
/* 加载列表视图中每一项cell的视图 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //通过代码自定义cell
        //        cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
        //设置列表视图的cell为系统默认的布局
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    //    cell.textLabel.text = [_array objectAtIndex:[indexPath row]];
    NSDictionary *dic = [_array objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dic objectForKey:TIME_STR];
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
