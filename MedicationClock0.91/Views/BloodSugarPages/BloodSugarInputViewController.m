//
//  BloodSugarInputViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/1.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodSugarInputViewController.h"

#import "UIColor+DIY.h"
#import "ZYRadioButton.h"
#import "DateUtil.h"
#import "CommonUtil.h"

#import "BloodSugarDB.h"
#import "BaseDB.h"

#define SizeScale screenWidth/450

@interface BloodSugarInputViewController () <UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation BloodSugarInputViewController{
    UIPickerView *_pickerView;
    NSArray *pickerArray;
    UILabel *_bloodSugarLabel;
    NSString *after_meal;
    BaseDB *dbDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"数据输入"];
    //self.view.backgroundColor = [UIColor myBgColor];
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
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, rectStatus.size.height, screenWidth,  screenHeight+navHeight)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    //时间lable
    UILabel *labelsj = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/4, y0, 400, screenHeight/11)];
    labelsj.backgroundColor = [UIColor clearColor];
    labelsj.textColor = [UIColor whiteColor];
    labelsj.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20*SizeScale];
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
    
    //中间图片
    UIImageView *imageview=[[UIImageView  alloc]initWithFrame:CGRectMake(screenWidth/6, y0+screenHeight/10, screenWidth*2/3, screenWidth*2/3)];
    //设置图片
    imageview.image=[UIImage imageNamed:@"arc_progress.png"];
    //设置高亮图片
    [self.view addSubview:imageview];
    
    UIFont *bloodSugarLabelFont = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20*SizeScale];
    
    //血糖label
    UILabel *labelxt = [[UILabel alloc]init];
    labelxt.backgroundColor = [UIColor clearColor];
    labelxt.textColor = [UIColor whiteColor];
    labelxt.font = bloodSugarLabelFont;
    labelxt.text = @"血 糖";
    //根据文字长度和字体计算文本框的长度
    CGSize labelxtSize = [labelxt.text sizeWithFont:labelxt.font];
    [labelxt setFrame:CGRectMake((screenWidth-labelxtSize.width)/2, y0+screenHeight/5, labelxtSize.width, labelxtSize.height)];
    [self.view addSubview:labelxt];
    
    //显示血糖值的Label
    _bloodSugarLabel = [[UILabel alloc]init];
    _bloodSugarLabel.backgroundColor = [UIColor clearColor];
    _bloodSugarLabel.textColor = [UIColor whiteColor];
    _bloodSugarLabel.font = bloodSugarLabelFont;
    _bloodSugarLabel.text = @"0.0";
    //根据文字长度和字体计算文本框的长度
    CGSize bsLabelSize = [_bloodSugarLabel.text sizeWithFont:_bloodSugarLabel.font];
    [_bloodSugarLabel setFrame:CGRectMake((screenWidth-bsLabelSize.width)/2, y0+screenHeight/5+screenWidth/7, bsLabelSize.width, bsLabelSize.height)];
    [self.view addSubview:_bloodSugarLabel];
    
    //血糖单位label
    UILabel *labeldw = [[UILabel alloc]init];
    labeldw.backgroundColor = [UIColor clearColor];
    labeldw.textColor = [UIColor whiteColor];
    labeldw.font = bloodSugarLabelFont;
    labeldw.text = @"mmol/L";
    //根据文字长度和字体计算文本框的长度
    CGSize labeldwSize = [labeldw.text sizeWithFont:labeldw.font];
    [labeldw setFrame:CGRectMake((screenWidth-labeldwSize.width)/2, y0+screenHeight/5+screenWidth/4, labeldwSize.width, labeldwSize.height)];
    [self.view addSubview:labeldw];
    
    pickerArray= @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(screenWidth/4, y0+screenHeight/11+screenWidth*11/18, screenWidth/2, screenHeight/9)];
    CALayer *viewLayer = _pickerView.layer;
    [viewLayer setFrame:CGRectMake(screenWidth/4, y0+screenHeight/11+screenWidth*11/18, screenWidth/2, screenHeight/9)];
    [viewLayer setBorderWidth:0];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [self.view addSubview:_pickerView];

    //单选框制作
    //初始化视图容器
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-screenWidth/32.0*22)/2, y0+screenHeight/11+screenWidth*7/9, screenWidth/32.0*22, screenHeight/56.8*4.5)];
    container.backgroundColor = [UIColor clearColor];
    [self.view addSubview:container];
    //初始化单选按钮控件
    ZYRadioButton *rb1 = [[ZYRadioButton alloc] initWithGroupId:@"after_meal" index:0];
    ZYRadioButton *rb2 = [[ZYRadioButton alloc] initWithGroupId:@"after_meal" index:1];
    rb1.frame = CGRectMake(10,15,35,35);
    rb2.frame = CGRectMake(screenWidth/32.0*14,15,35,35);
    //添加到视图容器
    [container addSubview:rb1];
    [container addSubview:rb2];
    //餐前label
    UILabel *labelcq =[[UILabel alloc] initWithFrame:CGRectMake(screenWidth/32.0*4, 15, 60, 20)];
    labelcq.backgroundColor = [UIColor clearColor];
    labelcq.text = @"餐前";
    labelcq.textColor = [UIColor whiteColor];
    labelcq.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20*SizeScale];
    [container addSubview:labelcq];
    //餐后label
    UILabel *labelch =[[UILabel alloc] initWithFrame:CGRectMake(screenWidth/32.0*17, 15, 60, 20)];
    labelch.backgroundColor = [UIColor clearColor];
    labelch.text = @"餐后 ";
    labelch.textColor = [UIColor whiteColor];
    labelch.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20*SizeScale];
    [container addSubview:labelch];
    [ZYRadioButton addObserverForGroupId:@"after_meal" observer:self];
    
    //健康小贴士
    UILabel *labelts1 = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/6, y0+screenHeight*3.4/5, screenWidth*2/3, screenHeight/56.8*6.5)];
    labelts1.backgroundColor = [UIColor clearColor];
        labelts1.layer.borderColor = [[UIColor whiteColor]CGColor];
    [labelts1.layer setCornerRadius:10.0];
    labelts1.layer.borderWidth = 0.5f;
    //labelts.layer.masksToBounds = YES;
    [self.view addSubview:labelts1];
    
    
    UILabel *labelts = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/32, screenHeight/56.8*0.8, screenWidth*2/3*0.9, screenHeight/56.8*5.5)];
    labelts.backgroundColor = [UIColor clearColor];
    labelts.textColor = [UIColor whiteColor];
    labelts.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:15*SizeScale];
    labelts.text = @"健康小贴士：测量血糖时的饭后是指距离上一次进食两小时之内";
//    labelts.lineBreakMode=UILineBreakModeWordWrap;
    labelts.numberOfLines=0;    //设置自动换行
        //labelts.layer.masksToBounds = YES;
    [labelts1 addSubview:labelts];
    
    //保存按钮
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commitBtn.frame = CGRectMake((screenWidth-screenWidth/32*24)/2, y0+screenHeight*4.2/5, screenWidth/32*24, screenHeight/56.8*4);
    [commitBtn setTitle:@"保存" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn.layer setCornerRadius:5.0];
    [commitBtn setBackgroundColor:[UIColor btnBlueColor]];
    [commitBtn addTarget:self action:@selector(commitClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
}

- (void)commitClick{
    NSString *bloodSugar = _bloodSugarLabel.text;
    if([after_meal isEqual:@"true"]){
        if([bloodSugar intValue]<4){
            [self showAlert:@"饭后血糖不能低于4.0"];
            return;
        }
    }else if([after_meal isEqual:@"false"]){
        if([bloodSugar intValue]<1){
            [self showAlert:@"饭前血糖不能低于1.0"];
            return;
        }
    }else{
        [self showAlert:@"请选择饭前/饭后"];
        return;
    }
    NSDate *date = [NSDate date];
    NSString *record_date = [DateUtil getStrFromDate:date formatStr:@"yyyy-MM-dd"];
    NSString *record_time = [DateUtil getStrFromDate:date formatStr:@"HH:mm:ss"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:bloodSugar forKey:BLOOD_SUGAR];
    [dic setValue:after_meal forKey:AFTER_MEAL];
    [dic setValue:record_date forKey:RECORD_DATE];
    [dic setValue:record_time forKey:RECORD_TIME];
    NSString *res = [BloodSugarDB insert:dbDriver dic:dic];
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

/** 重写RadioButton的函数 **/
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    if([groupId isEqual:@"after_meal"]){
        if(index==0){
            after_meal=@"false";
        }else{
            after_meal=@"true";
        }
    }
    
}

/** 重写PickerView设置列的函数 **/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 2;
}
/** 重写PickerView每一列有多少个可选行的函数 **/
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component==0){
        return pickerArray.count;
    }else{
        return pickerArray.count;
    }
}
/** 重写PickerView显示文字的函数 **/
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}
/** 重写PickerView滑轮改变事件 **/
-(void)pickerView:(UIPickerView *)pickerViewt didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerViewt==_pickerView){
        NSString *value1=[pickerArray objectAtIndex:[_pickerView selectedRowInComponent:0]];
        NSString *value2=[pickerArray objectAtIndex:[_pickerView selectedRowInComponent:1]];
        NSString *bloodSugar=[NSString stringWithFormat:@"%@.%@",value1,value2];
        [_bloodSugarLabel setText:bloodSugar];
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

@end
