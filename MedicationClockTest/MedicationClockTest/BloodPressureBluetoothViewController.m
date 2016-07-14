//
//  BloodPressureBluetoothViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodPressureBluetoothViewController.h"
#import "UIColor+DIY.h"

@interface BloodPressureBluetoothViewController ()

@end

@implementation BloodPressureBluetoothViewController{
    int y0;
    int screenWidth;
    int screenHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"蓝牙录入"];
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
    
    //中间图片
    UIView *a = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/4.0+screenWidth/50.0*2.4, screenHeight/5.0+screenWidth/50.0*3.7, screenWidth/32.0*14, screenWidth/32.0*14)];
    a.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.5];
    a.layer.cornerRadius = screenHeight/50.0*7;
    [self.view addSubview:a];
    UIImageView *imageview1=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/3.0+screenWidth/32.0*2.5, screenHeight/4.0+screenHeight/50.0*3.3, screenHeight/50.0*5.7, screenHeight/50.0*5.7)];
    imageview1.image=[UIImage imageNamed:@"bluetooth_icon.png"];
    [self.view addSubview:imageview1];
    UIImageView *imageview2=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/4.0, screenHeight/5.0+screenHeight/50.0, screenHeight/50.0*16.7,  screenHeight/50.0*16.7)];
    imageview2.image=[UIImage imageNamed:@"circle_ring.png"];
    [self.view addSubview:imageview2];
    
    //中间图片
    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(0, screenHeight/50.0*33, screenWidth, screenHeight/50.0*25)];
    imageview3.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.5];
    [self.view addSubview:imageview3];
    
    //蓝牙设备label
    UILabel *labelly = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/8.0, screenHeight-screenHeight/3.0, screenWidth/32.0*13.8, screenHeight/50.0*3)];
    labelly.backgroundColor = [UIColor clearColor];
    labelly.textColor = [UIColor whiteColor];
    labelly.font = [UIFont fontWithName:@"Arial-BoldItalicMT"
                                   size:17];
    labelly.text = @"蓝牙设备";
    [self.view addSubview:labelly];
    //文本框1
    UITextField *text1 = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/8.0, screenHeight-screenHeight/4.0-screenHeight/100, screenWidth/32.0*10, screenHeight/50.0*3)];
    
    //设置边框样式，只有设置了才会显示边框样式
    text1.borderStyle = UITextBorderStyleBezel;
    
    // text.backgroundColor = [UIColor purpleColor];
    text1.layer.borderColor=[[UIColor whiteColor]CGColor];
    text1.layer.borderWidth= 1.0f;
    text1.clearsOnBeginEditing = YES;
    [self.view addSubview:text1];
    
    //文本框2
    UITextField *text2 = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/8.0+screenWidth/32.0*10, screenHeight-screenHeight/4.0-screenHeight/100, screenWidth/32.0*13, screenHeight/50.0*3)];
    
    //设置边框样式，只有设置了才会显示边框样式
    text2.borderStyle = UITextBorderStyleBezel;
    
    // text.backgroundColor = [UIColor purpleColor];
    text2.layer.borderColor=[[UIColor whiteColor]CGColor];
    text2.layer.borderWidth= 1.0f;
    text2.clearsOnBeginEditing = YES;
    [self.view addSubview:text2];
    
    //保存按钮
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn1.frame = CGRectMake(screenWidth/8.0, screenHeight-screenHeight/5.0+screenHeight/50.0*2.7, screenWidth/32.0*24, screenHeight/50.0*3.5);
    [btn1 setTitle:@"自动测量" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1.layer setCornerRadius:5.0];
    [btn1 setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:btn1];
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
