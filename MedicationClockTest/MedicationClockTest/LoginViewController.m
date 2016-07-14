//
//  ViewController.m
//  Learn2
//
//  Created by 歐陽 on 16/3/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "LoginViewController.h"

#import "MainViewController.h"
#import "RegistViewController.h"

#import "LoadingAlertController.h"
#import "HttpUtil.h"
#import "UIColor+DIY.h"
#import "CommonUtil.h"

#import "BloodSugarRecordDB.h"
#import "JSONUtil.h"
#import "UserInfo.h"

#import "TestViewController.h"

#define SizeScale screenWidth/400

@interface LoginViewController ()

@end

@implementation LoginViewController{
    UITextField *_usernameView;
    UITextField *_passwordView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}
- (void)viewDidAppear:(BOOL)animated{
    if(_usernameStr!=nil){
        _usernameView.text = _usernameStr;
        _usernameStr = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏标题
    [self.navigationItem setTitle:@"登录"];
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
    //UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0, screenWidth,  screenHeight)];
    //bgimageview.image=[UIImage imageNamed:@"hub2_bg.png"];
    //[self.view addSubview:bgimageview];
    //添加输入用户名密码的文本框
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 55, 36*SizeScale)];
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label1.text = @"  账号";
    _usernameView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/6, screenHeight/3, screenWidth*2/3, screenHeight*11/120)];
    _usernameView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _usernameView.layer.borderWidth= 1.5f;
    _usernameView.textColor=[UIColor whiteColor];
    _usernameView.clearsOnBeginEditing = YES;
    [_usernameView.layer setCornerRadius:9*SizeScale];
    _usernameView.leftView=label1;
    _usernameView.leftViewMode = UITextFieldViewModeAlways;
    _usernameView.keyboardType = UIKeyboardTypeAlphabet;
    //关闭系统自动联想和首字母大写功能
    [_usernameView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_usernameView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:_usernameView];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 55, 36*SizeScale)];
    label2.textColor = [UIColor whiteColor];
    label2.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label2.text = @"  密码";
    _passwordView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/6, screenHeight/3+screenHeight*11/120+5*SizeScale, screenWidth*2/3, screenHeight*11/120)];
    _passwordView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _passwordView.layer.borderWidth= 1.5f;
    _passwordView.textColor=[UIColor whiteColor];
    _passwordView.secureTextEntry = YES;
    _passwordView.clearsOnBeginEditing = YES;
    [_passwordView.layer setCornerRadius:9*SizeScale];
    _passwordView.leftView=label2;
    _passwordView.leftViewMode = UITextFieldViewModeAlways;
    _passwordView.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_passwordView];
    
    //添加注册登录的按钮
    UIButton *loginBtn=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth*5/24 ,_passwordView.frame.origin.y+_passwordView.frame.size.height+35*SizeScale, screenWidth*7/12, 40)];
    loginBtn.backgroundColor = [UIColor btnBlueColor];
    loginBtn.layer.cornerRadius = 10;
    loginBtn.titleLabel.font  = [UIFont systemFontOfSize: 18];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [loginBtn addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchDown];
    [loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn addTarget:self action:@selector(loginCancel:) forControlEvents:UIControlEventTouchDragOutside];
    //添加按钮到视图
    [self.view addSubview:loginBtn];
    
    UIButton *registBtn=[[UIButton alloc] init];
    registBtn.layer.cornerRadius = 10;
    registBtn.titleLabel.font    = [UIFont systemFontOfSize: 14];
    [registBtn setTitle:@"注册用户" forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor btnBlueColor] forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    //设置按钮点击事件
    [registBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
    //根据文字长度和字体计算文本框的长度
    CGSize registBtn_labelSize = [registBtn.titleLabel.text sizeWithFont:registBtn.titleLabel.font];
    [registBtn setFrame:CGRectMake(screenWidth*19/24-registBtn_labelSize.width, loginBtn.frame.origin.y+loginBtn.frame.size.height+7*SizeScale, registBtn_labelSize.width, registBtn_labelSize.height)];
    //添加按钮到视图
    [self.view addSubview:registBtn];
    
    //读取程序记住的用户名和密码
//    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    if(username!=nil){
        _usernameView.text = username;
    }
    
    [self testBtn];
}
-(void)testBtn{
    CGRect rect = [[UIScreen mainScreen] bounds];
//    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height;
    UIButton *testBtn=[[UIButton alloc] initWithFrame:CGRectMake(0 ,screenHeight-120, 100, 20)];
    testBtn.titleLabel.font    = [UIFont systemFontOfSize: 15];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    //设置按钮点击事件
    [testBtn addTarget:self action:@selector(testClick:) forControlEvents:UIControlEventTouchUpInside];
    //添加按钮到视图
    [self.view addSubview:testBtn];
}
-(void)testClick:(UIButton *)sender{
    UIViewController *viewController=[[TestViewController alloc] init];
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showAlert:(NSString*)msg{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)loginPressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColorPressed];
}
- (void)loginCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
}
-(void)loginClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
    //读取文本框
    NSString *usernameText = _usernameView.text;
    NSString *passwordText = _passwordView.text;
    //设置文本框关闭软键盘
    //    [_usernameView resignFirstResponder];
    //    [_passwordView resignFirstResponder];
    //如果文本框都在self.view里面，也可以用下面这种方法关闭软键盘
    [self.view endEditing:YES];
    
    //判断用户名密码是否为空
    if ([usernameText isEqualToString:@""] || usernameText == NULL) {
        [self showAlert:@"用户名不能为空"];
        return;
    } else if([passwordText isEqualToString:@""] || passwordText == NULL){
        [self showAlert:@"密码不能为空"];
        return;
    }
    
    //访问Http连接
    NSString *urlStr = [NSString stringWithFormat:@"%@!userLogin.ac", UserActionUrl];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc]init];
    [paramsDic setValue:@"1" forKey:@"store_id"];
    [paramsDic setValue:usernameText forKey:@"username"];
    [paramsDic setValue:passwordText forKey:@"password"];
    //打开载入中对话框，从IOS9.0起推荐使用这种方法创建对话框
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"载入中" preferredStyle:UIAlertControllerStyleAlert];
    void (^callbackHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        void (^completion)(void) = ^() {
            NSString *receiveStr;
            if ([data length] > 0 && error == nil) {
                //解析json格式数据
                NSError *error;
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if(error == nil){       //如果json解析正确
                    NSString *user_id = [jsonDictionary objectForKey:@"user_id"];
                    NSString *username = [jsonDictionary objectForKey:@"username"];
                    NSString *nickname = [jsonDictionary objectForKey:@"nickname"];
                    NSString *member_card_id = [jsonDictionary objectForKey:@"member_card_id"];
                    NSString *login_id = [jsonDictionary objectForKey:@"login_id"];
                    NSString *last_login_time = [jsonDictionary objectForKey:@"last_login_time"];
                    NSString *head_img_mark = [jsonDictionary objectForKey:@"head_img_mark"];
                    
                    //这里写保存用户名和密码的代码
                    //[[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                    //20160331 jjw
                    [UserInfo setUserInfo:user_id login_id:login_id username:username nickname:nickname];
                    
                    //实现页面跳转
                    //页面跳转传值的相关知识：http://www.cnblogs.com/heri/archive/2013/03/18/2965815.html
                    //通过委托类传递对象到下一页面
                    
                    //查询服务端是否有数据
                    NSString *urlStr =[NSString stringWithFormat: @"%@!uploadCheck.ac?user_id=%@",ClockActionUrl,user_id];
                    
                    [HttpUtil httpGet:urlStr callbackHandler:^(NSData *data, NSError *error) {
                        if(error == nil){
                            //实现页面跳转
                            MainViewController *viewController= [[MainViewController alloc] init];
                            //20160331 jjw 传参数到主界面
                            viewController.uploadCheck =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            [self.navigationController pushViewController:viewController animated:YES];
                            
                        }
                    }];
                    
                    
                    
                }else{
                    //否则显示错误信息
                    NSLog(@"error=%@", error);
                    receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                }
            }else if ([data length] == 0 && error == nil){
                NSLog(@"Nothing was downloaded.");
                receiveStr = @"无返回数据";
            }else if (error != nil){
                NSLog(@"Error happened = %@",error);
                receiveStr = [NSString stringWithFormat:@"Error happened = %@", error];
            }
            if(receiveStr!=nil){
                //弹出对话框 从IOS9.0起这种方法就过时了
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:receiveStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        };
        //关闭载入中的对话框
        [loadingAlert dismissViewControllerAnimated:YES completion:completion];
    };
    
    [self presentViewController:loadingAlert animated:YES completion:^(){
        [HttpUtil httpPost:urlStr paramDic:paramsDic callbackHandler:callbackHandler];
    }];
}
-(void)registClick:(UIButton *)sender{
    //实现页面跳转
    RegistViewController *viewController= [[RegistViewController alloc] init];
    //    viewController.view.backgroundColor=[UIColor purpleColor];
    [self.navigationController pushViewController:viewController animated:YES];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



@end
