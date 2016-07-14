//
//  ClockOnlineViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/10.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ClockOnlineViewController.h"

#import "ClockSetViewController.h"

#import "UIColor+DIY.h"
#import "HttpUtil.h"

@interface ClockOnlineViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ClockOnlineViewController{
    int screenWidth;
    int screenHeight;
    
    NSArray *_itemDefs;
    UITableView *_tableView;
    UILabel *noDataLabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题栏
    [self setTitle:@"在线闹钟"];
    //设置页面的背景颜色
    self.view.backgroundColor = [UIColor myBgColor];
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height;
    // Do any additional setup after loading the view.
    //初始化界面
    [self initView];
    //下载更新数据
    [self loadData];
}

- (void)initView{
    //初始化列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate =self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    //初始化无数据时显示的文本框
    noDataLabelView = [[UILabel alloc] init];
    [noDataLabelView setTextColor:[UIColor whiteColor]];
    noDataLabelView.text=@"暂无数据";
    //根据文字长度和字体计算文本框的长度
    CGSize noData_labelSize = [noDataLabelView.text sizeWithFont:noDataLabelView.font];
    [noDataLabelView setFrame:CGRectMake((screenWidth-noData_labelSize.width)/2, screenHeight/2, noData_labelSize.width, screenHeight/15)];
    [self.view addSubview:noDataLabelView];
    noDataLabelView.hidden = YES;
}

- (void)loadData{
    //访问Http连接
    NSString *urlStr = [NSString stringWithFormat:@"%@!getMedicationClock.ac", ClockActionUrl];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    NSString *params = [NSString stringWithFormat:@"user_id=%@", user_id];
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
                    _itemDefs = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if(error==nil){       //如果json解析正确
                        if(_itemDefs.count==0){
                            noDataLabelView.hidden=NO;
                            _tableView.hidden=YES;
                        }else{
                            noDataLabelView.hidden=YES;
                            _tableView.hidden=NO;
                            [_tableView reloadData];
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

#pragma mark -- tableView接口中的函数
// 这个函数是显示tableview章节数section，即列表中的大节点
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
// 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section）
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_itemDefs count];
}
// 添加cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *itemDic = [_itemDefs objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
    ClockSetViewController *backViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    backViewController.clockDic = nil;
    backViewController.clockDic = itemDic;
    [self.navigationController popToViewController:backViewController animated:true];
}
//修改cell高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
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
//        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.6];
        
        //图片
        CGRect imageRect = CGRectMake(15, 15, 60, 60);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
        imageView.image = [UIImage imageNamed:@"alarm_clock"];
        //为图片添加边框
        CALayer *layer = [imageView layer];
        layer.cornerRadius = 8;
        layer.borderColor = [[UIColor whiteColor]CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = YES;
        [cell.contentView addSubview:imageView];
        
        //标题
        CGRect titleTipRect = CGRectMake(88, 30, 40, 14);
        UILabel *titleTipLabel = [[UILabel alloc]initWithFrame:titleTipRect];
        titleTipLabel.text = @"标题:";
        titleTipLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:titleTipLabel];
        
        
        CGRect titleRect = CGRectMake(titleTipLabel.frame.origin.x+titleTipLabel.frame.size.width+5, 30, 150, 14);
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleRect];
        titleLabel.tag = 2;
        //        titleLabel.textColor = [UIColor brownColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:titleLabel];
        
        //备注
        CGRect contentTipRect = CGRectMake(88, 50, 40, 15);
        UILabel *contentTipLabel = [[UILabel alloc]initWithFrame:contentTipRect];
        contentTipLabel.text = @"备注:";
        contentTipLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:contentTipLabel];
        
        CGRect contentRect = CGRectMake(titleLabel.frame.origin.x, 50, 150, 14);
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:contentRect];
        contentLabel.tag = 3;
        contentLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:contentLabel];
    }
    
    NSDictionary *itemDic = [_itemDefs objectAtIndex:indexPath.row];
    
    //设置用户名
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
    titleLabel.text = [itemDic objectForKey:@"title"];
    
    //设置昵称
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:3];
    contentLabel.text = [itemDic objectForKey:@"content"];
    
    //设置右侧箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
