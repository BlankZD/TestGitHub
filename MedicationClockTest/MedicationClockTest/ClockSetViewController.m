//
//  ClockSetViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ClockSetViewController.h"

#import "MedicationClockViewController.h"
#import "ClockOnlineViewController.h"

#import "UnderlineTextfield.h"
#import "UIColor+DIY.h"
#import "CommonUtil.h"
#import "HttpUtil.h"
#import "DateUtil.h"
#import "NotificationUtil.h"

#import "BaseDB.h"
#import "AlarmClockDB_.h"

#define IOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0

@interface ClockSetViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation ClockSetViewController{
    UITextField *_titleTextField;
    UITextField *_contentTextField;
    UITextField *_doseTextField;
    UITextField *_quantityTextField;
    NSMutableArray *_array;
    UITableView *_tableView;
    
    BaseDB * dbDriver;
    NSString *mc_id;
}

- (void)viewDidAppear:(BOOL)animated{
    if(_clockDic!=nil){
        NSLog(@"_clockDic=%@",_clockDic);
        _titleTextField.text=_clockDic[@"title"];
        _titleTextField.userInteractionEnabled = NO;
        _contentTextField.text=_clockDic[@"content"];
        _contentTextField.userInteractionEnabled = NO;
        NSString *dose = _clockDic[@"total_dose"];
        _doseTextField.text=[NSString stringWithFormat:@"%@",dose];
        _doseTextField.userInteractionEnabled = NO;
        NSString *alarm_time=_clockDic[@"alarm_time"];
        NSArray *time_arry=[alarm_time componentsSeparatedByString:@","];
        _quantityTextField.text=[NSString stringWithFormat:@"%ld",time_arry.count];
        _quantityTextField.userInteractionEnabled = NO;

        [_array setArray:time_arry];
        [_tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //添加导航栏右边的按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"在线闹钟" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    //设置页面的背景颜色
    self.view.backgroundColor = [UIColor myBgColor];
    //设置导航栏标题
    [self.navigationItem setTitle:@"添加闹钟"];
    //初始化操作数据库的对象
    dbDriver = [[BaseDB alloc]init];
    //初始化视图控件
    [self initView];
}

//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    ClockOnlineViewController *viewController = [[ClockOnlineViewController alloc]init];
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
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height;
    int y0 = statusHeight+navHeight;
    
    UIView *rootView = [[UIView alloc]initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight)];
    rootView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self.view addSubview:rootView];
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:15];    //设置一个字体和文字大小
    CGSize maxSize = CGSizeMake(320,2000);         //设置一个行高上限
    
    
     UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight/56.8*4, screenWidth, 2)];
    lineView.backgroundColor = [UIColor whiteColor];
    [rootView addSubview:lineView];
     
    
    UILabel *titleLabel = [[UILabel alloc]init];
    NSString *titleStr = @"标题";
    titleLabel.text = titleStr;
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font = font;
    CGSize title_labelsize = [titleStr sizeWithFont:font constrainedToSize:maxSize];
    [titleLabel setFrame:CGRectMake(0, screenHeight/56.8*7, title_labelsize.width, title_labelsize.height)];
    [rootView addSubview:titleLabel];
    
    _titleTextField = [[UnderlineTextfield alloc]initWithFrame:CGRectMake(title_labelsize.width*1.5, titleLabel.frame.origin.y-10, screenWidth-title_labelsize.width*2.5, 30)];
    _titleTextField.textColor=[UIColor whiteColor];
    [rootView addSubview:_titleTextField];
    
    
    UILabel *contentLabel = [[UILabel alloc]init];
    NSString *contentStr = @"备注";
    contentLabel.text = contentStr;
    contentLabel.textColor=[UIColor whiteColor];
    contentLabel.font = font;
    CGSize content_labelsize = [contentStr sizeWithFont:font constrainedToSize:maxSize];
    [contentLabel setFrame:CGRectMake(0, titleLabel.frame.origin.y+ screenHeight/56.8*4.5, content_labelsize.width, content_labelsize.height)];
    [rootView addSubview:contentLabel];
    
    _contentTextField = [[UnderlineTextfield alloc]initWithFrame:CGRectMake(content_labelsize.width*1.5, contentLabel.frame.origin.y-10, screenWidth-content_labelsize.width*2.5, 30)];
    _contentTextField.textColor=[UIColor whiteColor];
    [rootView addSubview:_contentTextField];
    
    
    UILabel *doseLabel = [[UILabel alloc]init];
    NSString *doseStr = @"服药次数:";
    doseLabel.textColor=[UIColor whiteColor];
    doseLabel.text = doseStr;
    doseLabel.font = font;
    CGSize dose_labelsize = [doseStr sizeWithFont:font constrainedToSize:maxSize];
    [doseLabel setFrame:CGRectMake(0, contentLabel.frame.origin.y+screenHeight/56.8*4.5, dose_labelsize.width, dose_labelsize.height)];
    [rootView addSubview:doseLabel];
    
    _doseTextField = [[UnderlineTextfield alloc]initWithFrame:CGRectMake(dose_labelsize.width*1.3, doseLabel.frame.origin.y-10, dose_labelsize.width*0.7, 30)];
    _doseTextField.textColor=[UIColor whiteColor];
    _doseTextField.keyboardType = UIKeyboardTypeNumberPad;
    [rootView addSubview:_doseTextField];
    
    
    UILabel *predayLabel = [[UILabel alloc]init];
    NSString *predayStr = @"预计时间:";
    predayLabel.textColor=[UIColor whiteColor];
    predayLabel.text = predayStr;
    predayLabel.font = font;
    CGSize predaysize = [doseStr sizeWithFont:font constrainedToSize:maxSize];
    [predayLabel setFrame:CGRectMake(screenWidth/2.0, contentLabel.frame.origin.y+screenHeight/56.8*4.5, predaysize.width, predaysize.height)];
    [rootView addSubview:predayLabel];
    
    UILabel *quantityLabel = [[UILabel alloc]init];
    NSString *quantityStr = @"频率/天";
    quantityLabel.text = quantityStr;
    quantityLabel.textColor=[UIColor whiteColor];
    quantityLabel.font = font;
    CGSize quantity_labelsize = [quantityStr sizeWithFont:font constrainedToSize:maxSize];
    [quantityLabel setFrame:CGRectMake(0, doseLabel.frame.origin.y+screenHeight/56.8*4.5, quantity_labelsize.width, quantity_labelsize.height)];
    [rootView addSubview:quantityLabel];
    
    UIButton *reduceBtn = [[UIButton alloc]initWithFrame:CGRectMake(_doseTextField.frame.origin.x, quantityLabel.frame.origin.y-5, 30, 30)];
    [reduceBtn setBackgroundImage:[UIImage imageNamed:@"number_reduce"] forState:UIControlStateNormal];
    [reduceBtn addTarget:self action:@selector(reduceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:reduceBtn];
    
    UIButton *increaseBtn = [[UIButton alloc]initWithFrame:CGRectMake(_doseTextField.frame.origin.x+100, quantityLabel.frame.origin.y-5, 30, 30)];
    [increaseBtn setBackgroundImage:[UIImage imageNamed:@"number_increase"] forState:UIControlStateNormal];
    [increaseBtn addTarget:self action:@selector(increaseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:increaseBtn];
    
    _quantityTextField = [[UITextField alloc]initWithFrame:CGRectMake(reduceBtn.frame.origin.x+reduceBtn.frame.size.width+10, reduceBtn.frame.origin.y, 50, 30)];
    _quantityTextField.backgroundColor = [UIColor whiteColor];
    _quantityTextField.text = @"1";
    _quantityTextField.textAlignment = NSTextAlignmentCenter;
    _quantityTextField.userInteractionEnabled = NO;
    //    _quantityTextField.borderStyle = UITextBorderStyleNone;
    [rootView addSubview:_quantityTextField];
    
    
    
    //创建列表视图的数据列表
    _array = [[NSMutableArray alloc] init];
    NSString *str = [NSString stringWithFormat:@"点击设置闹铃时间"];
    [_array addObject:str];
    //创建列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, quantityLabel.frame.origin.y+screenHeight/56.8*4.5, screenWidth/32*20,screenHeight/56.8*11) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //添加列表视图到页面视图
    [rootView addSubview:_tableView];
    
    
    UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-screenWidth/32*24)/2, screenHeight/56.8*41, screenWidth/32*24, screenHeight/56.8*4.5)];
    commitBtn.layer.borderColor=[[UIColor whiteColor]CGColor];
    commitBtn.layer.borderWidth= 3.0f;
    [commitBtn.layer setCornerRadius:20.0];
    [commitBtn setTitle:@"设置闹钟" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [commitBtn addTarget:self action:@selector(commitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:commitBtn];
}
-(void)reduceBtnClick:(UIButton *)sender{
    NSString *str = _quantityTextField.text;
    int quatity = [str intValue];
    if(quatity>1){
        quatity = quatity - 1;
        [self refreshTable:quatity];
        _quantityTextField.text = [[NSString alloc]initWithFormat:@"%d", quatity];
    }
}
-(void)increaseBtnClick:(UIButton *)sender{
    NSString *str = _quantityTextField.text;
    int quatity = [str intValue];
    if(quatity<3){
        quatity = quatity + 1;
        [self refreshTable:quatity];
        _quantityTextField.text = [[NSString alloc]initWithFormat:@"%d", quatity];
    }
}
-(void)commitBtnClick:(UIButton *)sender{
    NSString *titleStr = _titleTextField.text;
    NSString *contentStr = _contentTextField.text;
    NSString *doseStr = _doseTextField.text;
    
    if(titleStr.length==0){
        [CommonUtil showAlertView:@"请输入标题"];
        return;
    }else if(doseStr.length==0){
        [CommonUtil showAlertView:@"请输入可服药次数"];
        return;
    }else if([doseStr intValue]<=0){
        [CommonUtil showAlertView:@"可服药次数必须为数字且大于0次"];
        return;
    }else{
        //检查是否设置了闹铃时间
        NSMutableSet *set = [[NSMutableSet alloc]init];
        for(NSString *timeStr in _array){
            NSString *re = @"^\\d+:\\d+$";
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
            if(![pre evaluateWithObject:timeStr]){
                [CommonUtil showAlertView:@"请设置闹铃时间"];
                return;
            }
            
            if([set containsObject:timeStr]){
                [CommonUtil showAlertView:[NSString stringWithFormat:@"闹铃时间重复(%@)",timeStr]];
                return;
            }else{
                [set addObject:timeStr];
            }
        }
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:titleStr forKey:CLOCK_TITLE];
    [dic setValue:contentStr forKey:CLOCK_CONTENT];
    [dic setValue:doseStr forKey:EXPIRE_DOSE];
    [dic setValue:[DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyy-MM-dd"] forKey:START_DATE];
    //判断是否是在线闹钟
    if(_clockDic==nil){
        //如果不是在线闹钟，直接生成本地闹钟
        int random = arc4random()%100;
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        NSString *clock_id = [NSString stringWithFormat:@"%@%@%d",[DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyyMMddHHmmssSSS"],username,random];
        [dic setValue:clock_id forKey:@"_id"];
        [dic setValue:@"0" forKey:UPLOAD_STATE];
        [self setAlarmClock:dic];
    }else{
        //如果是在线闹钟，先同步在线闹钟的已读状态
        [dic setValue:mc_id forKey:@"mc_id"];
        [dic setValue:mc_id forKey:@"_id"];
        [dic setValue:@"1" forKey:UPLOAD_STATE];
        NSString *urlStr = [NSString stringWithFormat:@"%@!setClockRead.ac",ClockActionUrl];
        UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"同步在线闹钟" preferredStyle:UIAlertControllerStyleAlert];
        void (^callbackHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
            void (^completion)(void) = ^() {
                NSString *msg;
                if ([data length] > 0 && error == nil) {
                    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    if([receiveStr isEqualToString:@"true"]){
                        //如果在线闹钟同步成功，调用生成本地闹钟的函数
                        [self setAlarmClock:dic];
                    }
                }else if ([data length] == 0 && error == nil){
                    msg = @"无返回数据";
                }else if (error != nil){
                    msg = [NSString stringWithFormat:@"Error happened = %@", error];
                }
                NSLog(@"更新在线闹钟：%@",msg);
            };
            //关闭载入中的对话框
            [loadingAlert dismissViewControllerAnimated:YES completion:completion];
        };
        
        [self presentViewController:loadingAlert animated:YES completion:^(){
            [HttpUtil httpPost:urlStr paramDic:dic callbackHandler:callbackHandler];
        }];

    }
}
-(void)setAlarmClock:(NSDictionary*)dic{
    NSLog(@"dic=%@",dic);
    NSString *res = [AlarmClockDB_ insert:dbDriver clockDic:dic timeArr:_array];
    if([res isEqualToString:@"true"]){
        for(NSString *alarm_time in _array){
            [NotificationUtil setNotificationWithTimeStr:alarm_time];
        }
        [self showAlert:@"设置闹钟成功" handler:^(UIAlertAction *action) {
            //点击对话框的按钮后返回上一层界面
            MedicationClockViewController *backViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            backViewController.refresh = true;
            [self.navigationController popToViewController:backViewController animated:true];
        }];
    }else{
        [CommonUtil errorAlertView:res];
    }
    
}
-(void)showAlert:(NSString*)msg handler:(void (^)(UIAlertAction *action))handler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
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

//封装刷新列表视图的函数
-(void)refreshTable:(int)count{
    //刷新列表视图控件
    [_array removeAllObjects];       //清空列表数据
    for(int i=0;i<count;i++){
        NSString *str = [NSString stringWithFormat:@"点击设置闹铃时间"];
        [_array addObject:str];
    }
    [_tableView reloadData];         //刷新列表视图控件显示的数据
}

#pragma mark - 在本类中实现接口中的函数
/** 添加cell的点击事件 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (IOS8) {
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
            [_array replaceObjectAtIndex:[indexPath row] withObject:dateString];
            [_tableView reloadData];         //刷新列表视图控件显示的数据
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:ok];//添加按钮
        [alert addAction:cancel];//添加按钮
        //以modal的形式
        [self presentViewController:alert animated:YES completion:^{ }];
    }else{
        //当在ios7上面运行的时候
    }

}
/** 这个函数是显示tableview章节数section，即列表中的大节点 **/
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
/** 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section）**/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}
/** 修改cell高度的位置**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}
/** 加载列表视图中每一项cell的视图**/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [_tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //设置列表视图的cell为系统默认的布局
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    //设置列表的值到列表视图的每一项的textLabel（IOS中默认每一项有文本框和图片框等，当然也可以自定义每一项的界面布局，Android中只能自定义每一项的界面，没有默认的界面布局）
    cell.textLabel.text = [_array objectAtIndex:[indexPath row]];  //通过 [indexPath row] 遍历数组
    cell.textLabel.font =[UIFont fontWithName:@"Arial" size:15];
    cell.textColor=[UIColor whiteColor];
    return cell;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
