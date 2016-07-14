//
//  BloodSugarBluetoothViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/1.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodSugarBluetoothViewController.h"
#import "DateUtil.h"
#import "UIColor+DIY.h"
#import "SearchBluetooth.h"

#import "BaseDB.h"
#import "BloodSugarDB.h"

@interface BloodSugarBluetoothViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@end

@implementation BloodSugarBluetoothViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    UIAlertController *_loadingAlert;
    UILabel *_titleLabel, *_msgLable, *_messageLabel;
    UIButton *_actionsBtn, *_saveBtn;
    NSMutableDictionary *_bloodSugarDic;
}

- (void)viewDidAppear:(BOOL)animated{
    if(_devicesDic!=nil){
        [_titleLabel setText:@"蓝牙设备"];
        CBPeripheral *peripheral = (CBPeripheral*)[_devicesDic objectForKey:@"peripheral"];
        [_msgLable setText:peripheral.name];
        [_actionsBtn setTitle:@"点击连接蓝牙设备" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"蓝牙录入"];
    //self.view.backgroundColor = [UIColor myBgColor];
    
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
    UIImageView *bgimageview=[[UIImageView  alloc]initWithFrame:CGRectMake(0, rectStatus.size.height, screenWidth,  screenHeight+navHeight)];
    bgimageview.image=[UIImage imageNamed:@"add_online_clock_background.png"];
    [self.view addSubview:bgimageview];
    _loadingAlert = [UIAlertController alertControllerWithTitle:nil message:@"正在连接蓝牙设备" preferredStyle:UIAlertControllerStyleAlert];
    
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
    
    _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight/5.0+screenHeight/50.0*19, screenWidth, screenHeight/50.0*3)];
    _messageLabel.text = @"血糖测量";
//    _messageLabel.textColor = [UIColor whiteColor];
    //设置文字居中
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_messageLabel];
    [_messageLabel setHidden:YES];
    
    //文本框1
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.text = @"暂无连接";
    _titleLabel.textColor = [UIColor whiteColor];
//    _titleLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:17];
    //设置文本框的边框
    _titleLabel.layer.borderColor=[[UIColor whiteColor]CGColor];
    _titleLabel.layer.borderWidth=1.0f;
    //设置文字居中
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    //根据文字长度和字体计算文本框的长度
    CGSize titleLabelSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    [_titleLabel setFrame:CGRectMake(screenWidth/9.0, screenHeight-screenHeight/4.0-screenHeight/100, titleLabelSize.width+15, screenHeight/50.0*3)];
    
    //文本框2
    _msgLable = [[UILabel alloc]init];
    _msgLable.textColor = [UIColor whiteColor];
//    _msgLable.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:17];
    //设置文本框的边框
    _msgLable.layer.borderColor=[[UIColor whiteColor]CGColor];
    _msgLable.layer.borderWidth= 1.0f;
    //设置文字居中
    _msgLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_msgLable];
    [_msgLable setFrame:CGRectMake(_titleLabel.frame.origin.x+_titleLabel.frame.size.width, screenHeight-screenHeight/4.0-screenHeight/100, screenWidth/32.0*29-(_titleLabel.frame.origin.x+_titleLabel.frame.size.width), screenHeight/50.0*3)];
    
    //操作按钮
    _actionsBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _actionsBtn.frame = CGRectMake(screenWidth/8.0, screenHeight-screenHeight/5.0+screenHeight/50.0*2.7, screenWidth/32.0*24, screenHeight/50.0*3.5);
    [_actionsBtn setTitle:@"点击搜索蓝牙设备" forState:UIControlStateNormal];
    [_actionsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_actionsBtn.layer setCornerRadius:5.0];
    [_actionsBtn setBackgroundColor:[UIColor btnBlueColor]];
    //设置按钮点击事件
    [_actionsBtn addTarget:self action:@selector(actionsBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [_actionsBtn addTarget:self action:@selector(actionsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_actionsBtn addTarget:self action:@selector(actionsBtnCancel:) forControlEvents:UIControlEventTouchDragOutside];
    //添加按钮到视图
    [self.view addSubview:_actionsBtn];
    
    //保存按钮
    _saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _saveBtn.frame = CGRectMake(screenWidth/8.0, _actionsBtn.frame.origin.y+_actionsBtn.frame.size.height+screenHeight/25, screenWidth/32.0*24, screenHeight/50.0*3.5);
    [_saveBtn setTitle:@"保存测量数据" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn.layer setCornerRadius:5.0];
    [_saveBtn setBackgroundColor:[UIColor btnBlueColor]];
    //设置按钮点击事件
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [_saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_saveBtn addTarget:self action:@selector(saveBtnCancel:) forControlEvents:UIControlEventTouchDragOutside];
    //添加按钮到视图
    [self.view addSubview:_saveBtn];
    [_saveBtn setHidden:true];
}

-(void)actionsBtnPressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColorPressed];
}
- (void)actionsBtnCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
}
-(void)actionsBtnClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
    if(_devicesDic==nil){
        //跳转到搜索蓝牙设备的界面
        UIViewController *viewController=[[SearchBluetooth alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        //调用连接蓝牙设备的函数
        CBCentralManager *central = (CBCentralManager*)[_devicesDic objectForKey:@"central"];
        CBPeripheral *peripheral = (CBPeripheral*)[_devicesDic objectForKey:@"peripheral"];
        //显示连接中的对话框
        [self presentViewController:_loadingAlert animated:YES completion:^(){
            NSLog(@"central=%@\nperipheral=%@",central,peripheral);
            //连接蓝牙设备
            central.delegate=self;
            [central connectPeripheral:peripheral options:nil];
        }];
    }
}

-(void)saveBtnPressed:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColorPressed];
}
- (void)saveBtnCancel:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
}
-(void)saveBtnClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor btnBlueColor];
    
    NSDate *date = [NSDate date];
    NSString *record_date = [DateUtil getStrFromDate:date formatStr:@"yyyy-MM-dd"];
    NSString *record_time = [DateUtil getStrFromDate:date formatStr:@"HH:mm:ss"];
    [_bloodSugarDic setValue:record_date forKey:RECORD_DATE];
    [_bloodSugarDic setValue:record_time forKey:RECORD_TIME];
    BaseDB *dbDriver = [[BaseDB alloc]init];
    [BloodSugarDB insert:dbDriver dic:_bloodSugarDic];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"录入成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [_bloodSugarDic removeAllObjects];
        [_messageLabel setTextColor:[UIColor blackColor]];
        [sender setHidden:true];
    }];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertView:(NSString*)msg{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
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

/** 返回蓝牙状态的函数 **/
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>蓝牙已经关闭了");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>蓝牙已打开");
            break;
        default:
            break;
    }
}

/** 连接到Peripherals-失败 **/
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //关闭载入中的对话框
    [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
        NSString *msg = [NSString stringWithFormat:@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]];
        NSLog(@"%@",msg);
        [self showAlertView:msg];
    }];
}

/** Peripherals断开连接 **/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [central connectPeripheral:peripheral options:nil];
    //关闭载入中的对话框
    [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
        NSString *msg = [NSString stringWithFormat:@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]];
        NSLog(@"%@",msg);
        [self showAlertView:msg];
    }];
}

/** 连接到Peripherals-成功 **/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    _loadingAlert.message=[NSString stringWithFormat:@"连接到名称为（%@）的设备-成功",peripheral.name];
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];
}


/** 扫描到Services **/
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@">>>扫描到服务：%@",peripheral.services);
    if (error){
        [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
            NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        }];
        return;
    }
    NSString *Myservice=@"00001808-0000-1000-8000-00805f9b34fb";
    NSString *UUID_characteristic=@"00002A18-0000-1000-8000-00805f9b34fb";
    for (CBService *service in peripheral.services) {
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        if([service.UUID isEqual:[CBUUID UUIDWithString:Myservice]]){
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:UUID_characteristic]] forService:service];
            NSLog(@"1.血糖服务1808: %@", service.UUID);
        }else if([peripheral.name isEqual: @"Bluetooth BP"]){
            //如果不是连接到的血糖仪，就打印出里面全部的服务UUID
            [peripheral discoverCharacteristics:nil forService:service];
            NSLog(@"1－血压仪里面的Service ：%@", service.UUID);
        }
    }
}

/** 扫描到Characteristics **/
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error){
        NSLog(@"didDiscoverCharacteristicsForService方法 %@ 有误 %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    
    //搜索Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    
    for (CBCharacteristic *characteristic in service.characteristics){
        //2016-04-28 19:34:39.121 TestBluetooth[2569:455802] service:1802 的 Characteristic: 2A06
        // 2016-04-28 19:34:39.271 TestBluetooth[2569:455802] characteristic uuid:FF01  value:<884d6158 000002a5 00060002 070b0001>
        // if([[characteristic.UUID UUIDString] isEqual:@"FFO1"])
        [peripheral readValueForCharacteristic:characteristic];
        //          NSLog(@"搜索Characteristic的值，调用didUpdateValueForCharacteristic方法",characteristic);
    }
    
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    //血糖仪的服务UUID
    NSString *Mycharacteristic=@"00002A18-0000-1000-8000-00805f9b34fb";
    
    for (CBCharacteristic *characteristic in service.characteristics){
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:Mycharacteristic]]){
            [peripheral discoverDescriptorsForCharacteristic:characteristic]; //读取特征值
            NSLog(@"2.血糖特性2A18: %@", characteristic.UUID);
            NSLog(@"2.搜索Characteristic的值，调用didDiscoverDescriptorsForCharacteristic方法");
        }else{
            
        }
    }
}

/** 搜索到charateristic的值（真正会回调的方法）**/
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        //关闭载入中的对话框
//        [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
//            NSString *msg = [NSString stringWithFormat:@"错误 didUpdateValueForCharacteristic方法有误: %@", [error localizedDescription]];
//            NSLog(@"%@",msg);
//            [self showAlertView:msg];
//        }];
        NSLog(@"错误 didUpdateValueForCharacteristic方法有误: %@", [error localizedDescription]);
        return;
    }
    NSData *data=characteristic.value;//得到NSData返回值
    if(data != nil){//如果值不为空
        [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
            if([peripheral.name isEqualToString:@"Glucose Sensor"]){
                Byte *testByte = (Byte *)[data bytes];//data类型转换成Byte数组
                float byte13= (testByte[13] / 10.0F);//取到数组第13位
                //  Byte *byte0=&(testByte[0]);
                long bytes0=testByte[0];//取到第0位
                NSString *after_meal =  [self isAfterMeal:bytes0];//把数组转成二进制的字符串
                [self showAlertView:@"血糖测量成功"];
                NSString *msg;
                if([after_meal isEqualToString:@"true"]){
                    msg = [NSString stringWithFormat:@"血糖值:%f(饭后)",byte13];
                }else{
                    msg = [NSString stringWithFormat:@"血糖值:%f(饭前)",byte13];
                }
                NSLog(@"血糖测量成功-%@",msg);
                
                _bloodSugarDic = [[NSMutableDictionary alloc]init];
                [_bloodSugarDic setValue:@(byte13) forKey:BLOOD_SUGAR];
                [_bloodSugarDic setValue:after_meal forKey:AFTER_MEAL];
                _messageLabel.text=msg;
                _messageLabel.textColor=[UIColor lightTextColor];
                _messageLabel.hidden=false;
                [_saveBtn setHidden:false];
            }else if([peripheral.name isEqualToString:@"Bluetooth BP"]){
                //如果是血压仪返回的数据
                NSLog(@"血压仪返回的数据 characteristic.UUID =%@",characteristic.UUID);
                Byte *testByte = (Byte *)[data bytes];//data类型转换成Byte数组
                NSLog(@"data= %d",testByte[8]);
            }
        }];
    }
}
//自定义函数，把一个long转成二进制字符串的方法
- (NSString*)isAfterMeal:(long long)element{
    NSMutableString *str = [NSMutableString string];//长度可变的String
    NSInteger numberCopy = element;//int类型的变量
    for(int i = 0; i < 8; i++){//循环8次
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];//从numberCopy第0位开始判断，是不是等于1.如果是就往str里面插入1，如果不是就插0
        numberCopy >>= 1;//做右位移运算，变成二进制
        //        NSLog(@"str is %@",str);
    }
    NSString *ymdString = [str substringToIndex:1];//str字符串最终会变成二进制的字符串，字符串截取：从下标第0位～第1位（不包括第一位）
    if([ymdString isEqualToString:@"1"]){//判断如果截取出来的字符串与1比较相等的话
        return @"true";//返回'餐后‘字符串
    }else{
        return @"false";//返回'餐前‘字符串
    }
}

/** 搜索到Characteristic的Descriptors **/
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
            NSString *msg = [NSString stringWithFormat:@"错误 didDiscoverDescriptorsForCharacteristic方法有误: %@", [error localizedDescription]];
            NSLog(@"%@",msg);
            [self showAlertView:msg];
        }];
        return;
    }else{
        //打印出Characteristic和他的Descriptor
        if([peripheral.name isEqualToString:@"Glucose Sensor"]){
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"监听血糖仪路径。");
            _loadingAlert.message=@"监听血糖仪路径。";
        }else if([peripheral.name isEqualToString:@"Bluetooth BP"]){
            //NSLog(@"往血压仪写入数据。");
            Byte byte[] = {(-3), (-3), -6, 5, 13, 10};
            NSData *adata = [[NSData alloc] initWithBytes:byte length:6];
            [self writeCharacteristic:peripheral characteristic:characteristic value:adata];
        }
    }
}

/** 如果一个特征的值被更新然后周边代理接受（可能是更新通知状态）**/
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        [_loadingAlert dismissViewControllerAnimated:YES completion:^(){
            NSString *msg = [NSString stringWithFormat:@"didUpdateNotificationStateForCharacteristic方法有误 %@", [error localizedDescription]];
            NSLog(@"%@",msg);
            [self showAlertView:msg];
        }];
        return;
    }
    //读取特性值
    [peripheral readValueForCharacteristic:characteristic];
}

/** 获取到Descriptors的值 **/
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前两个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     };
     */
    // NSLog(@"writeCharacteristic方法写数据：%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
//        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    //  [centralManager cancelPeripheralConnection:peripheral];
}

- (void)dealloc{
//    CBCentralManager *central = (CBCentralManager*)[_devicesDic objectForKey:@"central"];
//    [central cl
}

@end
