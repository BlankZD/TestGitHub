//
//  PatientInfoViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/13.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "PatientInfoViewController.h"

#import "HttpUtil.h"
#import "ImageUtil.h"
#import "CommonUtil.h"

#import "PatientBloodPressureViewController.h"
#import "PatientBloodSugarViewController.h"
#import "PatientMedicationRecordViewController.h"

@interface PatientInfoViewController ()

@end

@implementation PatientInfoViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    UILabel *IDnumberView,*sexView,*birthdayView,*hemotypeView,*marital_statusView,*diseaseView,*medical_expense_paymentView,*work_unitView,*phoneView,*educational_levelView,*occupationView;
    NSMutableArray *yArr;
}

//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blood_pressure = [UIAlertAction actionWithTitle:@"查看血压数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        PatientBloodPressureViewController *viewController = [[PatientBloodPressureViewController alloc] init];
        if(_paramDic!=nil){
            viewController.paramDic=_paramDic;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    UIAlertAction *blood_sugar = [UIAlertAction actionWithTitle:@"查看血糖数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        PatientBloodSugarViewController *viewController = [[PatientBloodSugarViewController alloc] init];
        if(_paramDic!=nil){
            viewController.paramDic=_paramDic;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    UIAlertAction *medication_record = [UIAlertAction actionWithTitle:@"查看服药数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        PatientMedicationRecordViewController *viewController = [[PatientMedicationRecordViewController alloc] init];
        if(_paramDic!=nil){
            viewController.paramDic=_paramDic;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:blood_pressure];
    [alert addAction:blood_sugar];
    [alert addAction:medication_record];
    [alert addAction:cancel];
    //以modal的形式
    [self presentViewController:alert animated:YES completion:^{ }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"病友基本信息"];
    //添加导航栏右边的按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
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
    // Do any additional setup after loading the view from its nib.
    [self initView];
    [self loadData];
}

-(void)initView{
    CGRect imageRect = CGRectMake(screenWidth/22.0, y0+screenWidth/22.0, screenWidth/4, screenWidth/4);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
    imageView.tag = 1;
    //为图片添加边框
    imageView.image=[UIImage imageNamed:@"user_online.png"];
    CALayer *layer = [imageView layer];
    layer.cornerRadius = 8;
    layer.borderColor = [[UIColor grayColor]CGColor];
    layer.borderWidth = 1;
    layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    NSLog(@"_paramDic=%@",_paramDic);
    if(_paramDic!=nil){
        NSString *head_img = _paramDic[@"head_img"];
        if(head_img!=nil){
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@",Image_Res,head_img];
            //下载用户头像
            NSLog(@"下载用户头像");
            [ImageUtil loadImage:urlStr callbackHandler:^(NSData *imageData){
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [imageView setImage:image];
            }];
        }
    }
    
    UILabel *IDnumberLabel = [[UILabel alloc]init];
    IDnumberLabel.text=@"身份证号码：";
    IDnumberLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize IDnumberLabelSize = [IDnumberLabel.text sizeWithFont:IDnumberLabel.font];
    [IDnumberLabel setFrame:CGRectMake(screenWidth/66.0+layer.frame.origin.x+layer.frame.size.width, layer.frame.origin.y, IDnumberLabelSize.width, IDnumberLabelSize.height)];
    [self.view addSubview:IDnumberLabel];
    IDnumberView = [[UILabel alloc]init];
    [self.view addSubview:IDnumberView];
    
    UILabel *sexLabel = [[UILabel alloc]init];
    sexLabel.text=@"性别：";
    sexLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize sexLabelSize = [sexLabel.text sizeWithFont:sexLabel.font];
    [sexLabel setFrame:CGRectMake(screenWidth/66.0+layer.frame.origin.x+layer.frame.size.width, y0+screenWidth/7.1, sexLabelSize.width, sexLabelSize.height)];
    [self.view addSubview:sexLabel];
    sexView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/66.0, y0+screenWidth/7.1, screenWidth/32.0*10, screenWidth/11.0)];
    [self.view addSubview:sexView];
    
    UILabel *birthdayLabel = [[UILabel alloc]init];
    birthdayLabel.text=@"生日：";
    birthdayLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize birthdayLabelSize = [birthdayLabel.text sizeWithFont:birthdayLabel.font];
    [birthdayLabel setFrame:CGRectMake(screenWidth/66.0+layer.frame.origin.x+layer.frame.size.width, y0+80, birthdayLabelSize.width, birthdayLabelSize.height)];
    [self.view addSubview:birthdayLabel];
    birthdayView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/66.0, y0+screenHeight/50.0*10,  screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:birthdayView];
    
    UIImageView *imageview1=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*11,  screenWidth/32.0, screenWidth/11.0)];
    imageview1.image=[UIImage imageNamed:@"green2.png"];
    [self.view addSubview:imageview1];
    
    UILabel *hemotypeLabel = [[UILabel alloc]init];
    hemotypeLabel.text=@"血型：";
    hemotypeLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize hemotypeLabelSize = [hemotypeLabel.text sizeWithFont:hemotypeLabel.font];
    [hemotypeLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*12, hemotypeLabelSize.width, hemotypeLabelSize.height)];
    [self.view addSubview:hemotypeLabel];
    hemotypeView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*12,  screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:hemotypeView];
    
    UIImageView *imageview2=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*15, screenWidth/32.0, screenWidth/11.0)];
    imageview2.image=[UIImage imageNamed:@"a.png"];
    [self.view addSubview:imageview2];
    
    UILabel *marital_statusLabel = [[UILabel alloc]init];
    marital_statusLabel.text=@"婚姻状况：";
    marital_statusLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize marital_statusLabelSize = [marital_statusLabel.text sizeWithFont:marital_statusLabel.font];
    [marital_statusLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*16, marital_statusLabelSize.width, marital_statusLabelSize.height)];
    [self.view addSubview:marital_statusLabel];
    marital_statusView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*16, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:marital_statusView];

    UIImageView *imageview3=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*19, screenWidth/32.0, screenWidth/11.0)];
    imageview3.image=[UIImage imageNamed:@"bb.png"];
    [self.view addSubview:imageview3];
    
    
    UILabel *diseaseLabel = [[UILabel alloc]init];
    diseaseLabel.text=@"疾病：";
    diseaseLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize diseaseLabelSize = [diseaseLabel.text sizeWithFont:diseaseLabel.font];
    [diseaseLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*20, diseaseLabelSize.width, diseaseLabelSize.height)];
    [self.view addSubview:diseaseLabel];
    diseaseView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16.0, y0+screenHeight/50.0*20, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:diseaseView];
    
    UIImageView *imageview4=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*23, screenWidth/32.0, screenWidth/11.0)];
    imageview4.image=[UIImage imageNamed:@"cc.png"];
    [self.view addSubview:imageview4];
    
    UILabel *work_unitLabel = [[UILabel alloc]init];
    work_unitLabel.text=@"职业：";
    work_unitLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize work_unitLabelSize = [work_unitLabel.text sizeWithFont:work_unitLabel.font];
    [work_unitLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*24, work_unitLabelSize.width, work_unitLabelSize.height)];
    [self.view addSubview:work_unitLabel];
    work_unitView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*24, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:work_unitView];
    
    UIImageView *imageview5=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*27, screenWidth/32.0, screenWidth/11.0)];
    imageview5.image=[UIImage imageNamed:@"dd.png"];
    [self.view addSubview:imageview5];
    
    
    UILabel *educational_levelLabel = [[UILabel alloc]init];
    educational_levelLabel.text=@"学历：";
    educational_levelLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize educational_levelLabelSize = [educational_levelLabel.text sizeWithFont:educational_levelLabel.font];
    [educational_levelLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*28, educational_levelLabelSize.width, educational_levelLabelSize.height)];
    [self.view addSubview:educational_levelLabel];
    educational_levelView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*32, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:educational_levelView];
    
    UIImageView *imageview6=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*31, screenWidth/32.0, screenWidth/11.0)];
    imageview6.image=[UIImage imageNamed:@"blue.png"];
    [self.view addSubview:imageview6];
    
    UILabel *phoneLabel = [[UILabel alloc]init];
    phoneLabel.text=@"电话：";
    phoneLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize phoneLabelSize = [phoneLabel.text sizeWithFont:phoneLabel.font];
    [phoneLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*32, phoneLabelSize.width, phoneLabelSize.height)];
    [self.view addSubview:phoneLabel];
    phoneView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*28, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:phoneView];

    UIImageView *imageview7=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*35, screenWidth/32.0, screenWidth/11.0)];
    imageview7.image=[UIImage imageNamed:@"gg.png"];
    [self.view addSubview:imageview7];
    
    UILabel *occupationLabel = [[UILabel alloc]init];
    occupationLabel.text=@"工作单位：";
    occupationLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize occupationLabelSize = [occupationLabel.text sizeWithFont:occupationLabel.font];
    [occupationLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*36, occupationLabelSize.width, occupationLabelSize.height)];
    [self.view addSubview:occupationLabel];
    occupationView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*36, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:occupationView];
    
    UIImageView *imageview8=[[UIImageView  alloc]initWithFrame:CGRectMake(0, y0+screenHeight/50.0*39, screenWidth/32.0, screenWidth/11.0)];
    imageview8.image=[UIImage imageNamed:@"a.png"];
    [self.view addSubview:imageview8];
  
    UILabel *paymentLabel = [[UILabel alloc]init];
    paymentLabel.text=@"医疗支付方式：";
    paymentLabel.font=[UIFont systemFontOfSize:13];
    //根据文字长度和字体计算文本框的长度
    CGSize paywayLabelSize = [paymentLabel.text sizeWithFont:paymentLabel.font];
    [paymentLabel setFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*40, paywayLabelSize.width, paywayLabelSize.height)];
    [self.view addSubview:paymentLabel];
    medical_expense_paymentView = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/16, y0+screenHeight/50.0*40, screenWidth/32.0*20, screenWidth/11.0)];
    [self.view addSubview:medical_expense_paymentView];
   
}

-(void)loadData{
    //访问Http连接
    NSString *urlStr = [NSString stringWithFormat:@"%@!getPatientInfo.ac", ClockActionUrl];
    NSString *params = [NSString stringWithFormat:@"user_id=%@", [_paramDic objectForKey:@"user_id"]];
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
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if(error==nil){       //如果json解析正确
                        NSLog(@"jsonDictionary=%@", jsonDictionary);
                        NSString *IDnumber = [jsonDictionary objectForKey:@"IDnumber"];
                        IDnumberView.text=IDnumber;
                        IDnumberView.font=[UIFont systemFontOfSize:12];
                        CGSize IDnumberViewSize = [IDnumberView.text sizeWithFont:IDnumberView.font];
                        [IDnumberView setFrame:CGRectMake(screenWidth-IDnumberViewSize.width-screenWidth/22.0, y0+15, IDnumberViewSize.width, IDnumberViewSize.height)];
                        
                        NSString *sex = [jsonDictionary objectForKey:@"sex"];
                        sexView.text=sex;
                        sexView.font=[UIFont systemFontOfSize:13];
                        CGSize sexViewSize = [sexView.text sizeWithFont:sexView.font];
                        [sexView setFrame:CGRectMake(screenWidth-sexViewSize.width-screenWidth/22.0, y0+screenWidth/7.1, sexViewSize.width, sexViewSize.height)];
                        
                        NSString *birthday = [jsonDictionary objectForKey:@"birthday"];
                        birthdayView.text=birthday;
                        birthdayView.font=[UIFont systemFontOfSize:13];
                        CGSize birthdayViewSize = [birthdayView.text sizeWithFont:birthdayView.font];
                        [birthdayView setFrame:CGRectMake(screenWidth-birthdayViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*8, birthdayViewSize.width, birthdayViewSize.height)];
                        
                        NSString *hemotype = [jsonDictionary objectForKey:@"hemotype"];
                        hemotypeView.text=hemotype;
                        hemotypeView.font=[UIFont systemFontOfSize:13];
                        CGSize hemotypeViewSize = [hemotypeView.text sizeWithFont:hemotypeView.font];
                        [hemotypeView setFrame:CGRectMake(screenWidth-hemotypeViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*12, hemotypeViewSize.width, hemotypeViewSize.height)];
                        
                        NSString *marital_status = [jsonDictionary objectForKey:@"marital_status"];
                        marital_statusView.text=marital_status;
                        marital_statusView.font=[UIFont systemFontOfSize:13];
                        CGSize marital_statusViewSize = [marital_statusView.text sizeWithFont:marital_statusView.font];
                        [marital_statusView setFrame:CGRectMake(screenWidth-marital_statusViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*16, marital_statusViewSize.width, marital_statusViewSize.height)];
                        
                        NSString *disease = [jsonDictionary objectForKey:@"disease"];
                        diseaseView.text=disease;
                        diseaseView.font=[UIFont systemFontOfSize:13];
                        CGSize diseaseViewSize = [diseaseView.text sizeWithFont:diseaseView.font];
                        [diseaseView setFrame:CGRectMake(screenWidth-diseaseViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*20, diseaseViewSize.width, diseaseViewSize.height)];
                        
                        NSString *medical_expense_payment = [jsonDictionary objectForKey:@"medical_expense_payment"];
                        medical_expense_paymentView.text=medical_expense_payment;
                        medical_expense_paymentView.font=[UIFont systemFontOfSize:13];
                        CGSize medical_expense_paymentViewSize = [medical_expense_paymentView.text sizeWithFont:medical_expense_paymentView.font];
                        [medical_expense_paymentView setFrame:CGRectMake(screenWidth-medical_expense_paymentViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*40, medical_expense_paymentViewSize.width, medical_expense_paymentViewSize.height)];
                        
                        NSString *work_unit = [jsonDictionary objectForKey:@"work_unit"];
                        work_unitView.text=work_unit;
                        work_unitView.font=[UIFont systemFontOfSize:13];
                        CGSize work_unitViewSize = [work_unitView.text sizeWithFont:work_unitView.font];
                        [work_unitView setFrame:CGRectMake(screenWidth-work_unitViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*36, work_unitViewSize.width, work_unitViewSize.height)];
                        
                        NSString *phone = [jsonDictionary objectForKey:@"phone"];
                        phoneView.text=phone;
                        phoneView.font=[UIFont systemFontOfSize:13];
                        CGSize phoneSize = [phoneView.text sizeWithFont:phoneView.font];
                        [phoneView setFrame:CGRectMake(screenWidth-phoneSize.width-screenWidth/66.0, y0+screenHeight/50.0*32, phoneSize.width, phoneSize.height)];
                        
                        NSString *educational_level = [jsonDictionary objectForKey:@"educational_level"];
                        educational_levelView.text=educational_level;
                        educational_levelView.font=[UIFont systemFontOfSize:13];
                        CGSize educational_levelSize = [educational_levelView.text sizeWithFont:educational_levelView.font];
                        [educational_levelView setFrame:CGRectMake(screenWidth-educational_levelSize.width-screenWidth/22.0, y0+screenHeight/50.0*28, educational_levelSize.width, educational_levelSize.height)];
                        
                        NSString *occupation = [jsonDictionary objectForKey:@"occupation"];
                        occupationView.text=occupation;
                        occupationView.font=[UIFont systemFontOfSize:12];
                        CGSize occupationViewSize = [occupationView.text sizeWithFont:occupationView.font];
                        [occupationView setFrame:CGRectMake(screenWidth-occupationViewSize.width-screenWidth/22.0, y0+screenHeight/50.0*24, occupationViewSize.width, occupationViewSize.height)];
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

@end
