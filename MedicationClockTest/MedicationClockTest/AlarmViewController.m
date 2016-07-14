//
//  AlarmViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/2.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AlarmViewController.h"

#import "BaseDB.h"
#import "AlarmClockDB_.h"
#import "MedicationRecordDB_.h"

#import "DateUtil.h"
#import "NotificationUtil.h"
#import "CommonUtil.h"

@interface AlarmViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AlarmViewController{
    int screenWidth;
    int screenHeight;
    CGFloat scale_screen;
    
    BaseDB *dbDriver;
    NSString *_alarm_time;
    UILabel *_alarmTimeLabel;
    UITableView *_tableView;
    NSMutableArray *_array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"_infoDict=%@", _infoDict);
    
    //获取闹钟闹铃的理论时间
    _alarm_time = [_infoDict valueForKey:@"alarm_time"];
    //初始化数据库操作对象
    dbDriver = [[BaseDB alloc]init];
    //读取这个时间服用的药品列表
    _array = [AlarmClockDB_ query:dbDriver byAlarmTime:_alarm_time];
    
    [self initView];
}

- (void)initView{
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    screenWidth = rect.size.width;
    screenHeight = rect.size.height;
    //获取屏幕分辨率
    scale_screen = [UIScreen mainScreen].scale;
    NSLog(@"scale_screen=%f",scale_screen);
    /************** 分割线 **************/
    //中间图片
    UIImageView *imageview=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/6, screenHeight/11, screenWidth*2/3, screenWidth*2/3)];
    //设置图片
    imageview.image=[UIImage imageNamed:@"arc_progress.png"];
    //设置高亮图片
    [self.view addSubview:imageview];
    
    //显示血糖值的Label
    _alarmTimeLabel = [[UILabel alloc]init];
    _alarmTimeLabel.backgroundColor = [UIColor clearColor];
    _alarmTimeLabel.textColor = [UIColor whiteColor];
    _alarmTimeLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*scale_screen];
    _alarmTimeLabel.text = _alarm_time;
    //根据文字长度和字体计算文本框的长度
    CGSize bsLabelSize = [_alarmTimeLabel.text sizeWithFont:_alarmTimeLabel.font];
    [_alarmTimeLabel setFrame:CGRectMake((screenWidth-bsLabelSize.width)/2, imageview.frame.origin.y+imageview.frame.size.height/3, bsLabelSize.width, bsLabelSize.height)];
    [self.view addSubview:_alarmTimeLabel];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(screenWidth/6, imageview.frame.origin.y+imageview.frame.size.height+5, screenWidth*2/3, screenHeight/4) style:UITableViewStylePlain];
    //设置列表视图控件底部背景颜色透明度
    _tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    //设置列表视图的数据适配在本类中适配，本类需实现<UITableViewDataSource,UITableViewDelegate>接口
    _tableView.delegate =self;
    _tableView.dataSource=self;
    //添加列表视图到页面视图
    [self.view addSubview:_tableView];
    
    UIButton *nowBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nowBtn.frame = CGRectMake(screenWidth/4, _tableView.frame.origin.y+_tableView.frame.size.height+30, screenWidth/2, 35);
    [nowBtn setTitle:@"马上服药" forState:UIControlStateNormal];
    [nowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [nowBtn addTarget:self action:@selector(medicate_now:) forControlEvents:UIControlEventTouchUpInside];
    [nowBtn.layer setCornerRadius:5.0];
    [nowBtn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    [self.view addSubview:nowBtn];
    
    UIButton *latterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    latterBtn.frame = CGRectMake(screenWidth/4, nowBtn.frame.origin.y+nowBtn.frame.size.height+15, screenWidth/2, 35);
    [latterBtn setTitle:@"稍后服药" forState:UIControlStateNormal];
    [latterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [latterBtn addTarget:self action:@selector(medicate_later:) forControlEvents:UIControlEventTouchUpInside];
    [latterBtn.layer setCornerRadius:5.0];
    [latterBtn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    [self.view addSubview:latterBtn];
}
- (void)medicate_now:(UIButton *)sender{
    NSString *msg = [[NSString alloc]init];
    //如果点击了马上服药
    for(NSDictionary *tempDic in _array){
        NSString *clock_id = [tempDic valueForKey:CLOCK_ID];
        NSString *title = [tempDic valueForKey:TITLE];
        //根据服药闹钟插入一条服药记录
        NSString *now_time = [DateUtil getStrFromDate:[NSDate date] formatStr:@"HH时mm分ss秒"];
        NSString *record_date = [DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyy-MM-dd"];
        NSString *alarm_times = [AlarmClockDB_ queryClockTimeCount:dbDriver byClockId:clock_id];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:clock_id forKey:CLOCK_ID];
        [dic setValue:title forKey:TITLE];
        [dic setValue:alarm_times forKey:ALARM_TIMES];
        [dic setValue:record_date forKey:RECORD_DATE];
        [dic setValue:now_time forKey:MEDICATION_TIME];
        NSString *res = [MedicationRecordDB_ insertByDate:dbDriver dic:dic];
        if([res isEqualToString:@"true"]){
            //调用同步的函数
            NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
            [CommonUtil uploadRecord:user_id];
            //设置药品剩余剂量减1，返回药品剩余药量
            NSString *expire_dose = [AlarmClockDB_ reduceClockExpireDose:dbDriver clockId:clock_id];
            //如果该药品剩余药量小于或等于0
            if([expire_dose intValue]<=0){
                //设置该闹铃及闹钟所属下的所有闹铃过期
                [AlarmClockDB_ setClockExpire:dbDriver clockId:clock_id];
            }
        }else{
            msg = [msg stringByAppendingFormat:@"%@ %@\n", title, res];
        }
    }
    //如果闹铃时间下没有有效药品
    BOOL flag = [AlarmClockDB_ queryExistsByAlarmTime:dbDriver alarmTime:_alarm_time];
    if(flag){
        //注销该时间的闹铃
        [NotificationUtil cancelNotificationByAlarmTime:_alarm_time];
    }
    if([msg isEqualToString:@""]){
        [self showAlert:@"添加服药记录成功" handler:^(UIAlertAction *action) {
            if(_isRootView){
                [self exitAppliction];
            }else{
                [self dismissViewControllerAnimated:true completion: (nil)];
            }
        }];
    }else{
        [self showAlert:msg handler:^(UIAlertAction *action) {
            if(_isRootView){
                [self exitAppliction];
            }else{
                [self dismissViewControllerAnimated:true completion: (nil)];
            }
        }];
    }
    //注销加时闹钟
    [NotificationUtil cancelExtraNotification];
}
- (void)medicate_later:(UIButton *)sender{
    //如果点击了稍后服药
    if(_isRootView){
        [self exitAppliction];
    }else{
        [self dismissViewControllerAnimated:true completion: (nil)];
    }
}

-(void)exitAppliction{
    [UIView beginAnimations:@"exitAppliction" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view.window cache:NO];
    
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.view.window.bounds=CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}
-(void)animationFinished:(NSString *)animationID finished:(NSNumber * )finished context:(void *)context{
    if([animationID compare:@"exitAppliction"] == 0){
        exit(0);
    }
}

-(void)showAlert:(NSString*)msg handler:(void (^)(UIAlertAction *action))handler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [alert addAction:cancelAction];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    NSString *titileString = [dic objectForKey:@"name"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:titileString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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
    UIFont *font = [UIFont systemFontOfSize:17];    //设置一个字体和文字大小
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
    NSDictionary *dic = [_array objectAtIndex:indexPath.row];
    if(dic!=nil){
        UILabel *label1 = ((UILabel *)[cell.contentView viewWithTag:1]);
        [label1 setTextColor:[UIColor whiteColor]];
        label1.text = [dic objectForKey:CLOCK_TITLE];
        //根据文字长度和字体计算文本框的长度
        CGSize label1Size = [label1.text sizeWithFont:font];
        [label1 setFrame:CGRectMake(20, (45-label1Size.height)/2, label1Size.width, label1Size.height)];
        
        UILabel *label2 = ((UILabel *)[cell.contentView viewWithTag:2]);
        [label2 setTextColor:[UIColor whiteColor]];
        label2.text = [[NSString alloc] initWithFormat:@"%@", [dic objectForKey:CLOCK_CONTENT]];
        //根据文字长度和字体计算文本框的长度
        CGSize label2Size = [label2.text sizeWithFont:font];
        [label2 setFrame:CGRectMake(_tableView.frame.size.width-label2Size.width-20, (45-label1Size.height)/2, label2Size.width, label2Size.height)];
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
