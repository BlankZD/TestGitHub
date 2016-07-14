//
//  BloodPressureInputViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodPressureInputViewController.h"

#import "DateUtil.h"
#import "UIColor+DIY.h"
#import "CommonUtil.h"

#import "BaseDB.h"
#import "BloodPressureDB.h"
#define SizeScale screenWidth/450

@interface BloodPressureInputViewController () <UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation BloodPressureInputViewController{
    UITextField *_remarkView;
    UIPickerView *_pickerView1;
    UIPickerView *_pickerView2;
    UIPickerView *_pickerView3;
    NSArray *pickerArray;
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"手动录入"];
    self.view.backgroundColor = [UIColor myBgColor];
    dbDriver = [[BaseDB alloc]init];
    //初始化界面控件
    [self initView];
}

- (void)initView{
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
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0, screenWidth,  screenHeight+10)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    
    //时间lable
    UILabel *labelsj = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/4, y0, 400, screenHeight/11)];
    labelsj.backgroundColor = [UIColor clearColor];
    labelsj.textColor = [UIColor whiteColor];
    labelsj.font = [UIFont fontWithName:@"Arial-BoldItalicMT"size:20*SizeScale];
    NSDate *timeNow = [NSDate date];
    NSDateFormatter *dateFormater =[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm"];//得到年月日
    NSString *strDate =[dateFormater stringFromDate:timeNow];
    labelsj.text = [NSString stringWithFormat:@"时间:  %@", strDate];

    [self.view addSubview:labelsj];
    
    //画直线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, y0+screenHeight/11, screenWidth, 2)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    UIFont *font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20*SizeScale];
    CGSize size = CGSizeMake(320,2000);         //设置一个行高上限
    pickerArray= @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    
    //收缩压label
    UILabel *label11 = [[UILabel alloc]init];
    label11.textColor = [UIColor whiteColor];
    NSString *labelStr11 = @"收缩压";
    label11.font = font;
    label11.text = labelStr11;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize11 = [labelStr11 sizeWithFont:font constrainedToSize:size];
    [label11 setFrame:CGRectMake(screenWidth/5, y0+screenHeight*2/9, labelsize11.width, labelsize11.height)];
    [self.view addSubview:label11];
    
    _pickerView1 = [[UIPickerView alloc]initWithFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight*5/27, screenWidth/3, screenHeight/9)];
    CALayer *viewLayer = _pickerView1.layer;
    [viewLayer setFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight/11*2, screenWidth/3, screenHeight/9)];
    [viewLayer setBorderWidth:0];
    _pickerView1.dataSource = self;
    _pickerView1.delegate = self;
    [self.view addSubview:_pickerView1];
    
    UILabel *label12 = [[UILabel alloc]initWithFrame:CGRectMake(_pickerView1.frame.origin.x+screenWidth/3, y0+screenHeight*2/9, 90, 25)];
    label12.textColor = [UIColor whiteColor];
    label12.font = font;
    label12.text = @"mmHg";
    [self.view addSubview:label12];
    
    //舒张压label
    UILabel *label21 = [[UILabel alloc]init];
    label21.textColor = [UIColor whiteColor];
    NSString *labelStr21 = @"舒张压";
    label21.font = font;
    label21.text = labelStr21;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize21 = [labelStr21 sizeWithFont:font constrainedToSize:size];
    [label21 setFrame:CGRectMake(screenWidth/5, y0+screenHeight*3/9, labelsize21.width, labelsize21.height)];
    [self.view addSubview:label21];
    
    _pickerView2 = [[UIPickerView alloc]initWithFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight*8/27, screenWidth/3, screenHeight/9)];
    CALayer *viewLayer2 = _pickerView2.layer;
    [viewLayer2 setFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight*8/27, screenWidth/3, screenHeight/9)];
    [viewLayer2 setBorderWidth:0];
    _pickerView2.dataSource = self;
    _pickerView2.delegate = self;
    [self.view addSubview:_pickerView2];
    
    UILabel *label22 = [[UILabel alloc]initWithFrame:CGRectMake(_pickerView2.frame.origin.x+screenWidth/3, y0+screenHeight*3/9, 90, 25)];
    label22.textColor = [UIColor whiteColor];
    label22.font = font;
    label22.text = @"mmHg";
    [self.view addSubview:label22];
    
    //心率label
    UILabel *label31 = [[UILabel alloc]init];
    label31.textColor = [UIColor whiteColor];
    NSString *labelStr31 = @"  心率";
    label31.font = font;
    label31.text = labelStr31;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize31 = [labelStr31 sizeWithFont:font constrainedToSize:size];
    [label31 setFrame:CGRectMake(screenWidth/5, y0+screenHeight*4/9, labelsize31.width, labelsize31.height)];
    [self.view addSubview:label31];
    
    _pickerView3 = [[UIPickerView alloc]initWithFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight*11/27, screenWidth/3, screenHeight/9)];
    CALayer *viewLayer3= _pickerView3.layer;
    [viewLayer3 setFrame:CGRectMake(screenWidth/5+labelsize11.width, y0+screenHeight*11/27, screenWidth/3, screenHeight/9)];
    [viewLayer3 setBorderWidth:0];
    _pickerView3.dataSource = self;
    _pickerView3.delegate = self;
    [self.view addSubview:_pickerView3];
    
    UILabel *label32 = [[UILabel alloc]initWithFrame:CGRectMake(_pickerView3.frame.origin.x+screenWidth/3, y0+screenHeight*4/9, 90, 25)];
    label32.textColor = [UIColor whiteColor];
    label32.font = font;
    label32.text = @"次／分";
    [self.view addSubview:label32];
    
    //备注label
    UILabel *label41 = [[UILabel alloc]init];
    label41.textColor = [UIColor whiteColor];
    NSString *labelStr41 = @"  备注";
    label41.font = font;
    label41.text = labelStr41;
    //根据文字长度和字体计算文本框的长度
    CGSize labelsize41 = [labelStr41 sizeWithFont:font constrainedToSize:size];
    [label41 setFrame:CGRectMake(screenWidth/5, y0+screenHeight*5/9, labelsize41.width, labelsize41.height)];
    [self.view addSubview:label41];
    
    //文本框
    _remarkView = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/4+labelsize41.width, y0+screenHeight*5/9, screenWidth/3, 25)];
    //设置边框样式，只有设置了才会显示边框样式
    _remarkView.borderStyle = UITextBorderStyleRoundedRect;
    // text.backgroundColor = [UIColor purpleColor];
    _remarkView.layer.borderColor=[[UIColor redColor]CGColor];
    _remarkView.clearsOnBeginEditing = YES;
    _remarkView.layer.borderWidth= 1.0f;
    [_remarkView.layer setCornerRadius:5.0];
    [self.view addSubview:_remarkView];
    
    //保存按钮
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commitBtn.frame = CGRectMake((screenWidth-screenWidth*24/32)/2, y0+screenHeight*13/18, screenWidth*24/32, 35);
    [commitBtn setTitle:@"保存" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置按钮点击事件
    [commitBtn addTarget:self action:@selector(commitClick:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn.layer setCornerRadius:5.0];
    [commitBtn setBackgroundColor:[UIColor btnBlueColor]];
    [self.view addSubview:commitBtn];
}

/** 重写PickerView设置列的函数 **/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 3;
}
/** 重写PickerView每一列有多少个可选行的函数 **/
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component==0){
        return 3;
    }else{
        return pickerArray.count;
    }
}
/** 重写PickerView显示文字的函数 **/
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
//        pickerLabel.minimumFontSize = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
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

- (void)commitClick:(UIButton *)sender{
    NSString *value11=[pickerArray objectAtIndex:[_pickerView1 selectedRowInComponent:0]];
    NSString *value12=[pickerArray objectAtIndex:[_pickerView1 selectedRowInComponent:1]];
    NSString *value13=[pickerArray objectAtIndex:[_pickerView1 selectedRowInComponent:2]];
    int sp = [[NSString stringWithFormat:@"%@%@%@",value11,value12,value13] intValue];
    NSString *systolic_pressure = [NSString stringWithFormat:@"%d",sp];
    NSLog(@"systolic_pressure=%@",systolic_pressure);
    NSString *value21=[pickerArray objectAtIndex:[_pickerView2 selectedRowInComponent:0]];
    NSString *value22=[pickerArray objectAtIndex:[_pickerView2 selectedRowInComponent:1]];
    NSString *value23=[pickerArray objectAtIndex:[_pickerView2 selectedRowInComponent:2]];
    int dp = [[NSString stringWithFormat:@"%@%@%@",value21,value22,value23] intValue];
    NSString *diastolic_pressure = [NSString stringWithFormat:@"%d",dp];
    NSLog(@"diastolic_pressure=%@",diastolic_pressure);
    NSString *value31=[pickerArray objectAtIndex:[_pickerView3 selectedRowInComponent:0]];
    NSString *value32=[pickerArray objectAtIndex:[_pickerView3 selectedRowInComponent:1]];
    NSString *value33=[pickerArray objectAtIndex:[_pickerView3 selectedRowInComponent:2]];
    int hr = [[NSString stringWithFormat:@"%@%@%@",value31,value32,value33] intValue];
    NSString *heart_rate = [NSString stringWithFormat:@"%d",hr];
    NSLog(@"heart_rate=%@",heart_rate);
    if(sp<70 || sp>160){
        [self showAlert:@"收缩压不能低于70，且不能高于160，请重新确认"];
        return;
    }else if(dp<40 || dp >110){
        [self showAlert:@"舒张压不能低于40，且不能高于110，请重新确认"];
        return;
    }else if(hr<60 || hr>160){
        [self showAlert:@"心跳不能低于60，且不能高于160，请重新确认"];
        return;
    }
    NSString *remarks = _remarkView.text;
    
    NSDate *date = [NSDate date];
    NSString *record_date = [DateUtil getStrFromDate:date formatStr:@"yyyy-MM-dd"];
    NSString *record_time = [DateUtil getStrFromDate:date formatStr:@"HH:mm:ss"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setValue:systolic_pressure forKey:SYSTOLIC_PRESSURE];
    [dic setValue:diastolic_pressure forKey:DIASTOLIC_PRESSURE];
    [dic setValue:heart_rate forKey:HEART_RATE];
    [dic setValue:remarks forKey:REMARKS];
    [dic setValue:record_date forKey:RECORD_DATE];
    [dic setValue:record_time forKey:RECORD_TIME];
    NSString *res = [BloodPressureDB insert:dbDriver dic:dic];
    if([res isEqualToString:@"true"]){
        //调用同步的函数
        NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
        [CommonUtil uploadRecord:user_id];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"录入成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [CommonUtil showAlertView:res];
    }
    
}

-(void)showAlert:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
