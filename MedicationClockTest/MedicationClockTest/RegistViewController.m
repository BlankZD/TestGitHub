//
//  RegistViewController.m
//  Learn2
//
//  Created by 歐陽 on 16/3/13.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "RegistViewController.h"

#import "LoginViewController.h"
#import "UIColor+DIY.h"
#import "CommonUtil.h"
#import "HttpUtil.h"

#define SizeScale screenWidth/400

@interface RegistViewController ()

@end

@implementation RegistViewController{
    UITextField *_usernameView;
    UITextField *_passwordView;
    UITextField *_confirmpwdView;
    UITextField *_nicknameView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //显示导航栏
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
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
    [self.navigationItem setTitle:@"注册"];
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
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0, screenWidth,  screenHeight)];
    bgimageview.image=[UIImage imageNamed:@"bg.png"];
    [self.view addSubview:bgimageview];
    
    //添加输入用户名密码的文本框
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 55, 25*SizeScale)];
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label1.text = @" 账号";
    
    UIButton *imgBtn1=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth/5+screenWidth*1/3 ,screenHeight/5, screenHeight*5/120, screenHeight*5/120)];
        imgBtn1.backgroundColor = [UIColor clearColor];
       [imgBtn1 setBackgroundImage:[UIImage imageNamed:@"home_search_quit.png  "] forState:UIControlStateNormal];
     [self.view addSubview:imgBtn1];
    _usernameView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/5, screenHeight/5, screenWidth*2/3, screenHeight*9/120)];
    _usernameView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _usernameView.layer.borderWidth= 1.5f;
    _usernameView.textColor=[UIColor whiteColor];
    _usernameView.clearsOnBeginEditing = YES;
    [_usernameView.layer setCornerRadius:9*SizeScale];
    _usernameView.leftView=label1;
    _usernameView.rightView=imgBtn1;
    _usernameView.leftViewMode = UITextFieldViewModeAlways;
    _usernameView.rightViewMode = UITextFieldViewModeAlways;
    _usernameView.keyboardType = UIKeyboardTypeAlphabet;
    //关闭系统自动联想和首字母大写功能
    [_usernameView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_usernameView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:_usernameView];
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 55, 25*SizeScale)];
    label2.textColor = [UIColor whiteColor];
    label2.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label2.text = @" 密码";
    UIButton *imgBtn2=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth/5+screenWidth*1/3 ,screenHeight/5, screenHeight*5/120, screenHeight*5/120)];
    imgBtn2.backgroundColor = [UIColor clearColor];
    [imgBtn2 setBackgroundImage:[UIImage imageNamed:@"home_search_quit.png  "] forState:UIControlStateNormal];
    _passwordView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/5, screenHeight/5+screenHeight*11/120+5*SizeScale, screenWidth*2/3, screenHeight*9/120)];
    _passwordView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _passwordView.layer.borderWidth= 1.5f;
    _passwordView.textColor=[UIColor whiteColor];
    _passwordView.secureTextEntry = YES;
    _passwordView.clearsOnBeginEditing = YES;
    [_passwordView.layer setCornerRadius:9*SizeScale];
    _passwordView.leftView=label2;
    _passwordView.leftViewMode = UITextFieldViewModeAlways;
    _passwordView.rightView=imgBtn2;
    _passwordView.returnKeyType = UIReturnKeyDone;
    _passwordView.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_passwordView];
    
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 25*SizeScale)];
    label3.textColor = [UIColor whiteColor];
    label3.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label3.text = @" 确认密码";
    UIButton *imgBtn3=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth/5+screenWidth*1/3 ,screenHeight/5, screenHeight*5/120, screenHeight*5/120)];
    imgBtn3.backgroundColor = [UIColor clearColor];
    [imgBtn3 setBackgroundImage:[UIImage imageNamed:@"home_search_quit.png  "] forState:UIControlStateNormal];
    _confirmpwdView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/5, screenHeight/5+screenHeight*11/120+5*SizeScale+screenHeight*11/120+5, screenWidth*2/3, screenHeight*9/120)];
    _confirmpwdView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _confirmpwdView.layer.borderWidth= 1.5f;
    _confirmpwdView.textColor=[UIColor whiteColor];
    _confirmpwdView.secureTextEntry = YES;
    _confirmpwdView.clearsOnBeginEditing = YES;
    [_confirmpwdView.layer setCornerRadius:9*SizeScale];
    _confirmpwdView.leftView=label3;
    _confirmpwdView.leftViewMode = UITextFieldViewModeAlways;
    _confirmpwdView.rightView=imgBtn3;
    _confirmpwdView.rightViewMode = UITextFieldViewModeAlways;
    _confirmpwdView.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_confirmpwdView];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 75, 25*SizeScale)];
    label4.textColor = [UIColor whiteColor];
    label4.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:18*SizeScale];
    label4.text = @" 昵称";
    UIButton *imgBtn4=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth/5+screenWidth*1/3 ,screenHeight/5, screenHeight*5/120, screenHeight*5/120)];
    imgBtn4.backgroundColor = [UIColor clearColor];
    [imgBtn4 setBackgroundImage:[UIImage imageNamed:@"home_search_quit.png  "] forState:UIControlStateNormal];
    _nicknameView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/5, screenHeight/5+screenHeight*11/120+5*SizeScale+screenHeight*11/120+5+screenHeight*11/120+5, screenWidth*2/3, screenHeight*9/120)];
    _nicknameView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _nicknameView.layer.borderWidth= 1.5f;
    _nicknameView.textColor=[UIColor whiteColor];
    _nicknameView.secureTextEntry = YES;
    _nicknameView.clearsOnBeginEditing = YES;
    [_nicknameView.layer setCornerRadius:9*SizeScale];
    _nicknameView.leftView=label4;
    _nicknameView.leftViewMode = UITextFieldViewModeAlways;
    _nicknameView.rightView=imgBtn4;
    _nicknameView.returnKeyType = UIReturnKeyDone;
    _nicknameView.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_nicknameView];
    
    UIButton *registBtn=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth*5/24 ,screenHeight/5*3.5, screenWidth*2/3, screenHeight*9/120)];
    registBtn.backgroundColor = [UIColor btnBlueColor];
    registBtn.layer.cornerRadius = 10;
    registBtn.titleLabel.font  = [UIFont systemFontOfSize: 18];
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [registBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
    [registBtn addTarget:self action:@selector(registPressed:) forControlEvents:UIControlEventTouchDown];
    [registBtn addTarget:self action:@selector(registCancel:) forControlEvents:UIControlEventTouchDragOutside];
    //添加按钮到视图
    [self.view addSubview:registBtn];
}

-(void)registPressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColorPressed];
}
- (void)registCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
}
- (IBAction)registClick:(UIButton *)sender {
    sender.backgroundColor = [UIColor btnBlueColor];
    NSString *usernameText = _usernameView.text;
    NSString *passwordText = _passwordView.text;
    NSString *confirmpwdText = _confirmpwdView.text;
    NSString *nicknameText = _nicknameView.text;
    //设置关闭软键盘
    [self.view endEditing:YES];
    NSString *msg;
    if ([usernameText isEqualToString:@""] || usernameText == NULL) {
        msg = @"用户名不能为空";
    } else if([passwordText isEqualToString:@""] || passwordText == NULL){
        msg = @"用户名不能为空";
    } else if(![passwordText isEqualToString:confirmpwdText]){
        msg = @"两次密码输入不相同";
    } else if([nicknameText isEqualToString:@""] || nicknameText == NULL){
        msg = @"昵称不能为空";
    }
    
    if (msg.length !=0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    NSLog(@"点击了注册按钮，username=%@，password=%@", usernameText, passwordText);
    
    //访问Http连接
    NSString *urlStr = [NSString stringWithFormat:@"%@!userRegist.ac", UserActionUrl];
    NSString *params = [NSString stringWithFormat:@"store_id=1&username=%@&password=%@&nicknameText=%@", usernameText, passwordText, nicknameText];
    NSLog(@"params%@", params);
    void (^callbackHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        NSLog(@"调用回调函数");
        if ([data length] > 0 && error == nil) {
            //输出返回值
            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"receiveStr=%@", receiveStr);
            if([receiveStr isEqualToString:@"true"]){
                //创建对话框
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"注册成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //点击对话框的按钮后返回上一层界面并返回注册的用户名称
                    LoginViewController *backViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
                    backViewController.usernameStr = nil;
                    backViewController.usernameStr = [NSString stringWithString:usernameText];
                    [self.navigationController popToViewController:backViewController animated:true];
                }];
                [alert addAction:confirmAction];
                [self presentViewController:alert animated:YES completion:nil];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:receiveStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }else if (error != nil){
            NSLog(@"Error happened = %@",error);
        }
    };
    [HttpUtil httpPost:urlStr param:params callbackHandler:callbackHandler];
}

@end
