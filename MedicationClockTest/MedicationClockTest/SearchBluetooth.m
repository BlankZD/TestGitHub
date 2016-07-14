//
//  SearchBluetooth.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/7.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "SearchBluetooth.h"
#import "BloodSugarBluetoothViewController.h"

@interface SearchBluetooth ()<CBCentralManagerDelegate, UITableViewDataSource,UITableViewDelegate>{
    int y0;
    
    //系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    CBCentralManager *_central;
    //用于保存被发现设备
    NSMutableArray  *_devicesNameArr,*_devicesArr;
    UITableView *_tableView;
    //用于保存被发现设备
    NSMutableArray *discoverPeripheralsArray;
}

@end

@implementation SearchBluetooth

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取状态栏的宽高
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    int statusHeight = rectStatus.size.height;
    //获取导航栏的宽高
    CGRect rectNav = self.navigationController.navigationBar.frame;
    int navHeight = rectNav.size.height;
    y0 = statusHeight+navHeight;
    //获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    int screenWidth = rect.size.width;
    int screenHeight = rect.size.height;
    // Do any additional setup after loading the view.
    
    //初始化并设置委托和线程队列，最好一个线程的参数可以为nil，默认会就main线程
    _central = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    //初始化保存搜索到设备的列表
    _devicesNameArr = [[NSMutableArray alloc]init];
    _devicesArr = [[NSMutableArray alloc] init];
    discoverPeripheralsArray = [[NSMutableArray alloc] init];
    //初始化列表视图控件
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
}

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
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            //调用启动扫描的函数
            [central scanForPeripheralsWithServices:nil options:nil];
            
            break;
        default:
            break;
    }
}
/** 扫描到蓝牙设备时触发的函数 **/
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if(peripheral.name==nil){
        return;
    }
    NSLog(@"当扫描到设备:%@\n%@",central,peripheral);
    //接下连接我们的测试设备，如果你没有设备，可以下载一个app叫lightbule的app去模拟一个设备
    //这里自己去设置下连接规则，我设置的是P开头的设备
    //    if ([peripheral.name hasPrefix:@"P"]){
    /*
     一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
     - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
     - (void)centra`lManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
     - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
     */
    //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
    [discoverPeripheralsArray addObject:peripheral];
    //搜索到的设备名称保存到列表数据
    if([_devicesNameArr indexOfObject:peripheral.name]==NSNotFound){
        [_devicesNameArr addObject:peripheral.name];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];//Map
        [dictionary setObject:central forKey:@"central"];//放值
        [dictionary setObject:peripheral forKey:@"peripheral"];
        [_devicesArr addObject:dictionary];
    }
    
    //刷新列表视图显示的数据
    [_tableView reloadData];
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
    NSLog(@"dealloc,停止扫描");
    //停止扫描
    [_central stopScan];
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

#pragma mark -- 在本类中实现tableView接口中的函数
/**  这个函数是显示tableview章节数section，即列表中的大节点 **/
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
/**  这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section）**/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_devicesNameArr count];
}
/** 添加cell的点击事件 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //从Array中取得Map
    NSDictionary *devicesDic=[_devicesArr objectAtIndex:[indexPath row]];
    
    //点击搜索到的蓝牙设备列表时返回上一层界面并返回选择的设备
    BloodSugarBluetoothViewController *backViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    backViewController.devicesDic = nil;
    backViewController.devicesDic = devicesDic;
    [self.navigationController popToViewController:backViewController animated:true];
}
/** 加载列表视图中每一项cell的视图 **/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [_tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //设置列表视图的cell为系统默认的布局
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    //设置列表的值到列表视图的每一项的textLabel（IOS中默认每一项有文本框和图片框等，当然也可以自定义每一项的界面布局，Android中只能自定义每一项的界面，没有默认的界面布局）
    cell.textLabel.text = [_devicesNameArr objectAtIndex:[indexPath row]];  //通过 [indexPath row] 遍历数组
    return cell;
}

@end
