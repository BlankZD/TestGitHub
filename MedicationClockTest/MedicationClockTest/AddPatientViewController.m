//
//  AddPatientViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AddPatientViewController.h"

#import "PatientsViewController.h"

#import "UIColor+DIY.h"
#import "HttpUtil.h"

@interface AddPatientViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AddPatientViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    UITextField *_searchField;
    UITableView *_tableView;
    NSMutableArray *_array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor myBgColor];
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
    [self.navigationItem setTitle:@"添加病友"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    // Do any additional setup after loading the view from its nib.
    _array = [[NSMutableArray alloc] init];
    [self initSearchView];
    [self initTable];
}
-(void) clickRightButton{
    NSString *urlStr = [NSString stringWithFormat:@"%@!findFriends.ac", UserActionUrl];
    NSString *search_word = _searchField.text;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *params = [NSString stringWithFormat:@"username=%@&key_word=%@", username, search_word];
    NSLog(@"params=%@", params);
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"载入中" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loadingAlert animated:YES completion:^() {
        [HttpUtil httpPost:urlStr param:params callbackHandler:^(NSData *data, NSError *error) {
            [loadingAlert dismissViewControllerAnimated:YES completion:^() {
                NSString *alertStr;
                if ([data length] > 0 && error == nil) {
                    //解析json格式数据
                    NSError *error;
                    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if(error==nil){       //如果json解析正确
                        [_array setArray:jsonArray];
                        //刷新列表视图控件
                        [_tableView reloadData];
                    }else{
                        //否则显示错误信息
                        NSLog(@"error=%@", error);
                        //读取返回字符串
                        alertStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    }
                }else if ([data length] == 0 && error == nil){
                    NSLog(@"Nothing was downloaded.");
                    alertStr = @"无返回数据";
                }else if (error != nil){
                    NSLog(@"Error happened = %@",error);
                    alertStr = [NSString stringWithFormat:@"Error happened = %@", error];
                }
                if(alertStr!=nil){
                    //弹出对话框 从IOS9.0起这种方法就过时了
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
        }];
    }];
}

-(void)initSearchView{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    imgView.image=[UIImage imageNamed:@"search_bar_icon_normal"];
    _searchField = [[UITextField alloc]initWithFrame:CGRectMake(5, y0+5, screenWidth-10, 35)];
    _searchField.backgroundColor=[UIColor whiteColor];
    _searchField.layer.cornerRadius = 7.0;
    _searchField.leftView=imgView;
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_searchField];
}

-(void)initTable{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, y0+45, screenWidth, screenHeight) style:UITableViewStylePlain];
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //添加列表视图到页面视图
    [self.view addSubview:_tableView];
}

#pragma mark -- 在本类中实现接口中的函数
/* 这个函数是显示tableview章节数section，即列表中的大节点 */
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
/* 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section） */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}
/* 添加cell的点击事件 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [_array objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
    NSString *nickname = [dic objectForKey:@"nickname"];
    NSString *msgStr = [NSString stringWithFormat:@"是否确认让“%@”用户可以查看您的病历", nickname];
    //创建对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加病友" message:msgStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"载入中" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loadingAlert animated:YES completion:^() {
            NSString *user_id = [dic objectForKey:@"user_id"];
            NSString *urlStr = @"http://www.xbrjblkj.com:8124/BlmemServer2.04/medicationClockAction!addPatients.ac";
            NSString *patient_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
            NSString *params = [NSString stringWithFormat:@"user_id=%@&patient_id=%@", user_id, patient_id];
            [HttpUtil httpPost:urlStr param:params callbackHandler:^(NSData *data, NSError *error) {
                [loadingAlert dismissViewControllerAnimated:YES completion:^() {
                    NSString *alertStr;
                    if ([data length] > 0 && error == nil) {
                        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        if([receiveStr isEqualToString:@"true"]){
                            alertStr = @"添加成功";
                            //设置返回上一页面时刷新界面
                            PatientsViewController *backViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
                            backViewController.refresh=YES;
                        }
                    }else if ([data length] == 0 && error == nil){
                        NSLog(@"Nothing was downloaded.");
                        alertStr = @"无返回数据";
                    }else if (error != nil){
                        NSLog(@"Error happened = %@",error);
                        alertStr = [NSString stringWithFormat:@"Error happened = %@", error];
                    }
                    if(alertStr!=nil){
                        //弹出对话框 从IOS9.0起这种方法就过时了
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }];
            }];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}
/* 修改cell高度的位置 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
/* 加载列表视图中每一项cell的视图 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [_tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //通过代码自定义cell
        cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
    }
    //    assert(cell != nil);      //assert断言，即如果为真则不影响程序的运行，如果为假则程序直接退出或抛出异常（暂时我也还没搞清楚）
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
        
        //图片
        CGRect imageRect = CGRectMake(15, 15, 60, 60);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
        imageView.tag = 1;
        
        //为图片添加边框
        CALayer *layer = [imageView layer];
        layer.cornerRadius = 8;
        layer.borderColor = [[UIColor whiteColor]CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = YES;
        [cell.contentView addSubview:imageView];
        
        //用户名
        CGRect userIdRect = CGRectMake(88, 30, 60, 14);
        UILabel *userIdLabel = [[UILabel alloc]initWithFrame:userIdRect];
        userIdLabel.text = @"用户名:";
        userIdLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:userIdLabel];
        
        
        CGRect classRect = CGRectMake(145, 30, 40, 14);
        UILabel *classLabel = [[UILabel alloc]initWithFrame:classRect];
        classLabel.tag = 2;
        classLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:classLabel];
        
        //昵称
        CGRect nickNameTipRect = CGRectMake(88, 50, 40, 15);
        UILabel *nickNameTipLabel = [[UILabel alloc]initWithFrame:nickNameTipRect];
        nickNameTipLabel.text = @"昵称:";
        nickNameTipLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:nickNameTipLabel];
        
        CGRect nickNameRect = CGRectMake(135, 50, 150, 14);
        UILabel *nickNameLabel = [[UILabel alloc]initWithFrame:nickNameRect];
        nickNameLabel.tag = 3;
        nickNameLabel.textColor = [UIColor brownColor];
        nickNameLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [cell.contentView addSubview:nickNameLabel];
    }
    //获得行数
    NSUInteger row = [indexPath row];
    //取得相应行数的数据（NSDictionary类型，包括姓名、班级、学号、图片名称）
    NSDictionary *dic = [_array objectAtIndex:row];
    
    //设置图片
//    NSString *head_img_mark = [dic objectForKey:@"head_img_mark"];
    NSString *head_img = [dic objectForKey:@"head_img"];
    if(![head_img isEqual:[NSNull null]]){
        UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1];
        imageV.image = [UIImage imageNamed:head_img];
    }
    
    //设置用户名
    UILabel *username = (UILabel *)[cell.contentView viewWithTag:2];
    username.text = [dic objectForKey:@"username"];
    
    //设置昵称
    UILabel *nickname = (UILabel *)[cell.contentView viewWithTag:3];
    nickname.text = [dic objectForKey:@"nickname"];
    
    //设置右侧箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
