//
//  MainViewController.m
//  Learn2
//
//  Created by 歐陽 on 16/3/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "MainViewController.h"

#import "BloodSugarViewController.h"
#import "BloodPressureViewController.h"
#import "MedicationClockViewController.h"
#import "PatientsViewController.h"
#import "FileFloderList.h"

#import "UIColor+DIY.h"
#import "UserInfo.h"
#import "HttpUtil.h"
#import "CommonUtil.h"
#import "DateUtil.h"

#import "MedicationRecordDB.h"
#import "AlarmClockDB.h"

#import "BaseDB.h"
#import "BloodSugarDB.h"
#import "BloodPressureDB.h"
#import "MedicationRecordDB_.h"
#import "AlarmClockDB_.h"

#import "JSONUtil.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //显示导航栏
   [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
}
/*
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置页面的背景颜色
   // self.view.backgroundColor = [UIColor bgColor];
    //设置导航栏标题
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor btnBlueColor];
    [self.navigationItem setTitle:@"主界面"];
    //设置主标题的颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //获取状态栏的宽高
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent ;
    int statusHeight = rectStatus.size.height;
    //获取导航栏的宽高
    CGRect rectNav = self.navigationController.navigationBar.frame;
    int navHeight = rectNav.size.height;
    //获取屏幕的宽高
    int y0 = statusHeight+navHeight;
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height-y0;
    //状态栏底部颜色
    UIView *status = [[UILabel alloc]initWithFrame:CGRectMake(0, -statusHeight, screenWidth, statusHeight)];
    status.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar addSubview:status];
    //背景图
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, rectStatus.size.height, screenWidth,  screenHeight+navHeight)];
    bgimageview.image=[UIImage imageNamed:@"hub2_bg.png"];
    [self.view addSubview:bgimageview];
    //初始化界面
    [self initView];
    //初始化数据
    [self initDatabase];
    
}
-(void)initDatabase{
    BaseDB *dbDriver = [[BaseDB alloc]init];
    [BloodSugarDB createTable:dbDriver];
    [BloodPressureDB createTable:dbDriver];
    [MedicationRecordDB_ createTable:dbDriver];
    [AlarmClockDB_ createTable:dbDriver];
    
    //与服务器同步数据
    [self updateData:[UserInfo userInfo:NO].user_id];
}


//点击导航栏左边按钮的触发函数
- (void) clickLeftButton{
    //创建对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定关闭程序？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //点击对话框的按钮后调用关闭程序的函数
        [self exitAppliction];
    }];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blood_pressure = [UIAlertAction actionWithTitle:@"查看崩溃日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIViewController *viewController = [[FileFloderList alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:blood_pressure];
    [alert addAction:cancel];
    //以modal的形式
    [self presentViewController:alert animated:YES completion:^{ }];
}
-(void)initView{
    //隐藏左边的返回按钮
    //    [self.navigationItem setHidesBackButton:YES];
    //如果添加的自定义的左边按钮，会自动隐藏返回按钮
    //添加导航栏左边的按钮
   // UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, rectStatus.size.height, screenWidth,  screenHeight+navHeight)];
   // bgimageview.image=[UIImage imageNamed:@"hub2_bg.png"];
    //[self.view addSubview:bgimageview];
    //添加输入用户名密码的文本框

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftButton)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
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
    int y0 = statusHeight+navHeight;
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height-y0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight-y0)];
    view.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:view];
    
    UIButton *bpBtn=[[UIButton alloc] init];
    bpBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [bpBtn setImage:[UIImage imageNamed:@"hub2_bp_normal"] forState:UIControlStateNormal];
    [bpBtn addTarget:self action:@selector(bloodPressureClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:bpBtn];
    
    UIButton *bsBtn=[[UIButton alloc] init];
    bsBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [bsBtn setImage:[UIImage imageNamed:@"hub2_bs_normal"] forState:UIControlStateNormal];
    [bsBtn addTarget:self action:@selector(bloodSugarClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:bsBtn];
    
    UIButton *ckBtn=[[UIButton alloc] init];
    ckBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [ckBtn setImage:[UIImage imageNamed:@"hub2_ck_normal"] forState:UIControlStateNormal];
    [ckBtn addTarget:self action:@selector(medicationAlarmClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:ckBtn];
    
    
    
    /** 添加控件的约束 **/
    
    if(IOS9){
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-maginTop-[view(height)]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:@{@"maginTop":@(screenWidth/3), @"height":@(screenWidth*sqrt(3)/3)}
                                   views:@{@"superview":self.view, @"view":view}]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[superview]-[view]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:nil
                                   views:@{@"superview":self.view, @"view":view}]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[view(width)]-[bpBtn]"
                                   options:NSLayoutFormatAlignAllTop
                                   metrics:@{@"width":@(screenWidth*17/24)}
                                   views:NSDictionaryOfVariableBindings(view,bpBtn)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[view]-[bpBtn(height)]"
                                   options:NSLayoutFormatAlignAllLeft
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(view,bpBtn)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[view]-[bsBtn(height)]"
                                   options:NSLayoutFormatAlignAllRight
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(view,bsBtn)]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[bpBtn(width)]-[bsBtn(width)]"
                                   options:NSLayoutFormatAlignAllTop
                                   metrics:@{@"width":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(bpBtn,bsBtn)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[view]-[ckBtn(width)]"
                                   options:NSLayoutFormatAlignAllBottom
                                   metrics:@{@"width":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(view,ckBtn)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[view]-[ckBtn(height)]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(view,ckBtn)]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-maginTop-[view(height)]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:@{@"maginTop":@(screenWidth/3), @"height":@(screenWidth*sqrt(3)/3)}
                                   views:@{@"superview":self.view, @"view":view}]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:view
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1
                                   constant:0]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[view(width)]"
                                   options:0
                                   metrics:@{@"width":@(screenWidth*17/24)}
                                   views:NSDictionaryOfVariableBindings(view)]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:bpBtn
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:view
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1
                                   constant:0]];
        
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[bpBtn(height)]"
                                   options:0
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(bpBtn)]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:bpBtn
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:view
                                   attribute:NSLayoutAttributeLeft
                                   multiplier:1
                                   constant:0]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[bsBtn(height)]"
                                   options:0
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(bsBtn)]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:bsBtn
                                   attribute:NSLayoutAttributeRight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:view
                                   attribute:NSLayoutAttributeRight
                                   multiplier:1
                                   constant:0]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[bpBtn(width)]-[bsBtn(width)]"
                                   options:NSLayoutFormatAlignAllTop
                                   metrics:@{@"width":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(bpBtn,bsBtn)]];
//        [self.view addConstraint: [NSLayoutConstraint
//                                   constraintWithItem:bsBtn
//                                   attribute:NSLayoutAttributeTop
//                                   relatedBy:NSLayoutRelationEqual
//                                   toItem:bpBtn
//                                   attribute:NSLayoutAttributeTop
//                                   multiplier:1
//                                   constant:0]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[ckBtn(width)]"
                                   options:0
                                   metrics:@{@"width":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(ckBtn)]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:ckBtn
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:view
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1
                                   constant:0]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[ckBtn(height)]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:@{@"height":@(screenWidth*7/21)}
                                   views:NSDictionaryOfVariableBindings(ckBtn)]];
        [self.view addConstraint: [NSLayoutConstraint
                                   constraintWithItem:ckBtn
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:view
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1
                                   constant:0]];
    }
    
    //添加病友圈的按钮
    UIButton *sufferersCircleBtn=[[UIButton alloc] init];
    sufferersCircleBtn.translatesAutoresizingMaskIntoConstraints=NO;
    sufferersCircleBtn.backgroundColor = [UIColor btnBlueColor];
    sufferersCircleBtn.layer.cornerRadius = 10;
    sufferersCircleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [sufferersCircleBtn setTitle:@"病友圈" forState:UIControlStateNormal];
    [sufferersCircleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [sufferersCircleBtn addTarget:self action:@selector(sufferersCirclePressed:) forControlEvents:UIControlEventTouchDown];
    [sufferersCircleBtn addTarget:self action:@selector(sufferersCircleCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [sufferersCircleBtn addTarget:self action:@selector(sufferersCircleClick:) forControlEvents:UIControlEventTouchUpInside];
    //添加按钮到视图
    [self.view addSubview:sufferersCircleBtn];
    @try {
        //添加提交按钮的约束
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[sufferersCircleBtn(width)]"
                                   options:0
                                   metrics:@{@"width":@(screenWidth*9/12)}
                                   views:NSDictionaryOfVariableBindings(sufferersCircleBtn)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:[view]-magin-[sufferersCircleBtn(height)]"
                                   options:NSLayoutFormatAlignAllCenterX
                                   metrics:@{@"magin":@(screenWidth/6),@"height":@(screenHeight/56.8*4)}
                                   views:NSDictionaryOfVariableBindings(view,sufferersCircleBtn)]];
    } @catch (NSException *exception) {
        [CommonUtil errorAlertView:[exception description]];
    } @finally {
        
    }
}
- (void) sufferersCirclePressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColorPressed];
}
- (void) sufferersCircleCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
}
- (void) sufferersCircleClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
    UIViewController *viewController = [[PatientsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) bloodPressureClick{
    UIViewController *viewController = [[BloodPressureViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void) bloodSugarClick{
    UIViewController *viewController = [[BloodSugarViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void) medicationAlarmClick{
    UIViewController *viewController = [[MedicationClockViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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




-(void)updateData:(NSString *)user_id{
//    if([@"true" isEqualToString:self.uploadCheck]){
    if(false){
        BaseDB *dbDriver = [[BaseDB alloc]init];
        //测试用
        //[[BloodSugarRecordDB getInstance] deleteAll];
        //[[BloodPressureRecordDB getInstance] deleteAll];
        //[[MedicationRecordDB getInstance] deleteAll];
        
        int bloodSugarCount = [BloodSugarDB getCount:dbDriver];
        NSLog(@"bloodSugarCount=%d", bloodSugarCount);
        int bloodPressureCount = [BloodPressureDB getCount:dbDriver];
        NSLog(@"bloodPressureCount=%d", bloodPressureCount);
//        long medicationRecordCount = [[MedicationRecordDB getInstance ]getRecordCount];
//        NSLog(@"medicationRecordCount=%ld", medicationRecordCount);
//        long medicationDetailCount = [[MedicationRecordDB getInstance] getDetailCount];
//        NSLog(@"medicationDetailCount=%ld", medicationDetailCount);
        int medicationRecordCount = [MedicationRecordDB_ getRecordCount:dbDriver];
        NSLog(@"medicationRecordCount=%d", medicationRecordCount);
        int medicationDetailCount = [MedicationRecordDB_ getDetailCount:dbDriver];
        NSLog(@"medicationDetailCount=%d", medicationDetailCount);
        long count = bloodSugarCount+bloodPressureCount+medicationRecordCount+medicationDetailCount;
        
        if(count==0){
            //如果本地没有数据，从服务器下载数据
            [self uploadData:dbDriver user_id:user_id];
        }else{
            //否则查询本地没有同步到服务器的数据并上传到服务器
            [CommonUtil uploadRecord:user_id];
        }
    }
}

//根据用户id下载数据 20160330 jjw
-(void)uploadData:(BaseDB*)dbDriver user_id:(NSString*)user_id{
    NSString *url = [NSString stringWithFormat:@"%@!updateSugarRecord.ac", ClockActionUrl];
    
    //下载血糖数据20160330 jjw
    [HttpUtil httpPost:url param:[NSString stringWithFormat:@"user_id=%@",user_id] callbackHandler:^(NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            //输出返回值
//            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //解析json格式数据
            NSMutableArray *jsonArray =[JSONUtil getJSONArray:data];
            if(jsonArray!=nil && jsonArray.count >0){
                //                        [[BloodSugarRecordDB getInstance] insert_list:jsonArray];
                [BloodSugarDB insert:dbDriver arr:jsonArray];
            }
        }
        //下载血压记录
        NSString *url = [NSString stringWithFormat:@"%@!updatePressureRecord.ac", ClockActionUrl];
        [HttpUtil httpPost:url param:[NSString stringWithFormat:@"user_id=%@",user_id] callbackHandler:^(NSData *data, NSError *error) {
            if ([data length] > 0 && error == nil) {
                //输出返回值
//                NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                //解析json格式数据
                NSMutableArray *jsonArray =[JSONUtil getJSONArray:data];
                if(jsonArray!=nil && jsonArray.count >0){
                    //                                [[BloodPressureRecordDB getInstance] insert_list:jsonArray];
                    [BloodPressureDB insert:dbDriver arr:jsonArray];
                }
            }
            //下载服药闹钟
            NSString * url = [NSString stringWithFormat:@"%@!updateAlarmClock.ac",ClockActionUrl];
            [HttpUtil httpPost:url param:[NSString stringWithFormat:@"user_id=%@",user_id] callbackHandler:^(NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    //输出返回值
//                    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    //解析json格式数据
                    NSMutableArray *jsonArray =[JSONUtil getJSONArray:data];
                    NSMutableArray *clockList =[[NSMutableArray alloc] init];
                    //                    NSMutableArray *clock_online =[[NSMutableArray alloc] init];
                    if(jsonArray.count >0){
                        for(int i=0;i<jsonArray.count;i++){
                            NSMutableDictionary *jsonObject = jsonArray[i];
                            NSMutableDictionary *temp=[[NSMutableDictionary alloc] init];
                            [temp setObject:[jsonObject objectForKey:CLOCK_TITLE] forKey:CLOCK_TITLE];
                            [temp setObject:[jsonObject objectForKey:CLOCK_CONTENT] forKey:CLOCK_CONTENT];
                            [temp setObject:[jsonObject objectForKey:START_DATE] forKey:START_DATE];
                            [temp setObject:[jsonObject objectForKey:@"total_dose"] forKey:EXPIRE_DOSE];
                            [temp setObject:[jsonObject objectForKey:@"alarm_time"] forKey:@"alarm_time"];
                            [temp setObject:[jsonObject objectForKey:STATE] forKey:STATE];
                            [temp setObject:@"1" forKey:UPLOAD_STATE];
                            NSString *_id = [jsonObject objectForKey:@"mc_id"];
                            if(![_id isEqual:[NSNull null]] && _id!=nil && _id.length!=0){
                                [temp setObject:_id forKey:@"_id"];
                                [clockList addObject:temp];
                            }else{
                                int random = arc4random()%100;
                                NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                NSString *clock_id = [NSString stringWithFormat:@"%@%@%d",[DateUtil getStrFromDate:[NSDate date] formatStr:@"yyyyMMddHHmmssSSS"],username,random];
                                [temp setObject:clock_id forKey:@"_id"];
                                [clockList addObject:temp];
                            }
                        }
//                        @try {
//                            //                            [[AlarmClockDB getInstance] insertClock:clockList];
//                            //                            [[AlarmClockDB getInstance] insertOnlineClock:clock_online];
//                            [AlarmClockDB_ insert:dbDriver clockArr:clockList];
//                        } @catch (NSException *exception) {
//                            [CommonUtil errorAlertView:[exception description]];
//                        } @finally {
//                            @try {
//                                //                                [dbDriver rallback];
//                                [dbDriver endTransaction];
//                            } @catch (NSException *exception) {
//                                NSLog(@"exception=%@",[exception description]);
//                            }
//                        }
                    }
                }
                //下载服药记录概要表数据
                NSString *url = [NSString stringWithFormat:@"%@!updateMedicationRecord.ac",ClockActionUrl];
                [HttpUtil httpPost:url param:[NSString stringWithFormat:@"user_id=%@",user_id] callbackHandler:^(NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        //输出返回值
                        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"updatePressureRecord.ac=%@", receiveStr);
                        //解析json格式数据
                        NSArray *jsonArray =[JSONUtil getJSONArray:data];
                        if(jsonArray.count >0){
                            [MedicationRecordDB_ insertRecordArray:dbDriver arr:jsonArray];
                        }
                    }
                    //下载服药记详情要表数据
                    NSString *url = [NSString stringWithFormat:@"%@!updateMedicationDetail.ac", ClockActionUrl];
                    [HttpUtil httpPost:url param:[NSString stringWithFormat:@"user_id=%@",user_id] callbackHandler:^(NSData *data, NSError *error) {
                        if ([data length] > 0 && error == nil) {
                            //输出返回值
                            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                            NSLog(@"updatePressureRecord.ac=%@", receiveStr);
                            //解析json格式数据
                            NSArray *jsonArray =[JSONUtil getJSONArray:data];
                            if(jsonArray.count >0){
                                [MedicationRecordDB_ insertDetailArray:dbDriver arr:jsonArray];
                            }
                        }
                    }];
                }];
            }];
        }];
    }];
}

@end
