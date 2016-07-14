//
//  PatientsViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/7.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "PatientsViewController.h"

#import "AddPatientViewController.h"
#import "PatientInfoViewController.h"

#import "CommonUtil.h"
#import "UIColor+DIY.h"
#import "HttpUtil.h"
#import "ImageUtil.h"

#define TOP_TAG_HEIGHT 40

@interface PatientsViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation PatientsViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    UIView *_lineView;
    NSInteger _currentIndex;
    UIScrollView *_scrollView;
    NSMutableArray *_tableViewArray;
    NSMutableArray *_dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"病友圈"];
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
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    // Do any additional setup after loading the view from its nib.
    
    NSMutableArray *cateNameArray = [[NSMutableArray alloc]init];
    [cateNameArray addObject:@"关注"];
    [cateNameArray addObject:@"粉丝"];
    [self initTagView:cateNameArray];
    
    [self initSrollView];
    [self initTableViews];
    [self uploadData];
}
-(void) clickRightButton{
    UIViewController *viewController = [[AddPatientViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    if(_refresh==YES){
        [self uploadData];
        _refresh = NO;
    }
}

// 初始化表格的数据源
-(void)uploadData{
    _dataArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i = 1; i <= 2; i++) {
        NSMutableArray *tempArray  = [[NSMutableArray alloc] init];
        [_dataArray addObject:tempArray];
    }
    //访问Http连接
    NSString *urlStr = [NSString stringWithFormat:@"%@!getPatients.ac", ClockActionUrl];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    NSString *params = [NSString stringWithFormat:@"user_id=%@", user_id];
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
                        NSArray *jsonArrayLooked = [jsonDictionary objectForKey:@"jsonArrayLooked"];
                        NSArray *jsonArrayLook = [jsonDictionary objectForKey:@"jsonArrayLook"];
                        [_dataArray removeAllObjects];
                        [_dataArray addObject:jsonArrayLooked];
                        [_dataArray addObject:jsonArrayLook];
                        for(int i=0;i<2;i++){
                            UITableView *tableView = _tableViewArray[i];
                            [tableView reloadData];         //刷新列表视图控件中的数据;
                        }
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

-(void)initTagView:(NSArray*)cateNameArray{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y0, screenWidth, TOP_TAG_HEIGHT)];
    //    view.backgroundColor=[UIColor blueColor];
    [self.view addSubview:view];
    
    float btnWidth = screenWidth/cateNameArray.count;
    for (int i = 0; i < cateNameArray.count; i++) {
        UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nameBtn.frame = CGRectMake(btnWidth*i, 0, btnWidth, TOP_TAG_HEIGHT);
        nameBtn.tag = 10+i;
        nameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [nameBtn setTitle:cateNameArray[i] forState:UIControlStateNormal];
        [nameBtn setTitleColor:[UIColor navigationBarColor] forState:UIControlStateSelected];
        [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nameBtn addTarget:self action:@selector(onTagViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:nameBtn];
        if (i == 0) {
            //                            nameBtn.selected = YES;
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(nameBtn.frame.origin.x, 38, btnWidth, 2)];
            _lineView.backgroundColor = [UIColor navigationBarColor];
            [view addSubview:_lineView];
        }
    }
}
-(void)onTagViewClick:(UIButton *)sender{
    NSInteger index = sender.tag - 10;
    if (index == _currentIndex) {
        return;
    }
    _currentIndex = index;
    //    [UIView animateWithDuration:0.5 animations:^{
    //        _lineView.center = CGPointMake(sender.center.x, 39);
    //    }];
    
    //    _cateid = _cateIDArray[index];
    //    _page = 1;
    //刷新数据
    //    [self.tableView.gifHeader beginRefreshing];
    
    [_scrollView setContentOffset:CGPointMake(index*screenWidth, 0) animated:YES];
}

-(void)initSrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y0+TOP_TAG_HEIGHT, screenWidth, screenHeight - TOP_TAG_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(screenWidth*2, screenHeight-TOP_TAG_HEIGHT);
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

// 初始化TableView
-(void) initTableViews{
    _tableViewArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i = 0; i < 2; i ++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*screenWidth, 0, screenWidth, screenHeight - TOP_TAG_HEIGHT)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = 20+i;
        
        [_tableViewArray addObject:tableView];
        [_scrollView addSubview:tableView];
    }
}

#pragma mark -- scrollView接口中的函数
/** **/
-(void) modifyTopScrollViewPositiong: (UIScrollView *) scrollView{
}
//滑动调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //[self modifyTopScrollViewPositiong:scrollView];
    if ([_scrollView isEqual:scrollView]) {
//        NSLog(@"scrollViewDidEndDragging");
    }
}
/** 拖拽调用的方法 **/
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //    [self scrollViewDidEndDecelerating:scrollView];
    if ([_scrollView isEqual:scrollView]) {
//        NSLog(@"scrollViewDidEndScrollingAnimation");
    }
}
/** 实现滑动的方法 **/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self modifyTopScrollViewPositiong:scrollView];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_scrollView isEqual:scrollView]) {
        CGRect frame = _lineView.frame;
        frame.origin.x = _scrollView.contentOffset.x/2;
        _lineView.frame = frame;
    }
}

#pragma mark -- tableView接口中的函数
// 这个函数是显示tableview章节数section，即列表中的大节点
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}
// 这个函数是指定显示多少cell，即列表中的小节点，类似Android中ListView列表的item，而Android的ListView中没有大节点（即section）
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    long tag = tableView.tag-20;
    if(tag==0){
        NSMutableArray *tempArray = _dataArray[0];
        return [tempArray count];
    }else{
        NSMutableArray *tempArray = _dataArray[1];
        return [tempArray count];
    }
}
// 添加cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *tempArray = _dataArray[_currentIndex];
    NSDictionary *dic = [tempArray objectAtIndex:[indexPath row]];  //这个表示选中的那个cell上的数据
//    NSString *user_id = [dic objectForKey:@"user_id"];
//    NSString *username = [dic objectForKey:@"username"];
    NSString *nickname = [dic objectForKey:@"nickname"];
    
    long tag = tableView.tag-20;
    if(tag==0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:nickname delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        PatientInfoViewController *viewController = [[PatientInfoViewController alloc] init];
//        viewController.paramDic=[NSDictionary dictionaryWithObjectsAndKeys:user_id, @"user_id", username, @"username", nil];
        viewController.paramDic=dic;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
//修改cell高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
//加载列表视图中每一项cell的视图
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        //通过代码自定义cell
        cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
        cell.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.9];
    }
    //    assert(cell != nil);      //assert断言，即如果为真则不影响程序的运行，如果为假则程序直接退出或抛出异常（暂时我也还没搞清楚）
    return cell;
}

//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    //定义标识符
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    
    //定义新的cell
    if(cell == nil){
        //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        
        //图片
        CGRect imageRect = CGRectMake(15, 15, 60, 60);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
        imageView.tag = 1;
        
        //为图片添加边框
        CALayer *layer = [imageView layer];
        layer.cornerRadius = 8;
        layer.borderColor = [[UIColor whiteColor]CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = YES;
        [cell.contentView addSubview:imageView];
        
        //用户名
        CGRect userNameTipRect = CGRectMake(88, 30, 60, 14);
        UILabel *userNameTipLabel = [[UILabel alloc]initWithFrame:userNameTipRect];
        userNameTipLabel.text = @"用户名:";
        userNameTipLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:userNameTipLabel];
        
        
        CGRect userNameRect = CGRectMake(145, 30, 40, 14);
        UILabel *userNameLabel = [[UILabel alloc]initWithFrame:userNameRect];
        userNameLabel.tag = 2;
        userNameLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:userNameLabel];
        
        //昵称
        CGRect nickNameTipRect = CGRectMake(88, 50, 40, 15);
        UILabel *nickNameTipLabel = [[UILabel alloc]initWithFrame:nickNameTipRect];
        nickNameTipLabel.text = @"昵称:";
        nickNameTipLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:nickNameTipLabel];
        
        CGRect nickNameRect = CGRectMake(135, 50, 150, 14);
        UILabel *nickNameLabel = [[UILabel alloc]initWithFrame:nickNameRect];
        nickNameLabel.tag = 3;
        nickNameLabel.textColor = [UIColor brownColor];
        nickNameLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:nickNameLabel];
    }
    //获得行数
    NSUInteger row = [indexPath row];
    long tableTag = tableView.tag-20;
    NSMutableArray *tempArray = _dataArray[tableTag];
    //取得相应行数的数据（NSDictionary类型，包括姓名、班级、学号、图片名称）
    NSDictionary *dic = [tempArray objectAtIndex:row];
    
    //设置图片
    UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1];
    //    NSString *head_img_mark = [dic objectForKey:@"head_img_mark"];
    NSString *head_img = [dic objectForKey:@"head_img"];
    if(head_img!=nil){
        NSData *imageData = [self.imageCache objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
        if(imageData!=nil){
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            imageV.image=image;
        }else{
            imageV.image=[UIImage imageNamed:@"user_online"];
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@",Image_Res,head_img];
            [ImageUtil loadImage:urlStr callbackHandler:^(NSData *imgData){
                [self.imageCache setObject:imgData forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                UIImage *image = [[UIImage alloc] initWithData:imgData];
                imageV.image=image;
            }];
        }
    }else{
        imageV.image=[UIImage imageNamed:@"user_online"];
    }
    
    //设置用户名
    UILabel *username = (UILabel *)[cell.contentView viewWithTag:2];
    username.text = [dic objectForKey:@"username"];
    
    //设置昵称
    UILabel *nickname = (UILabel *)[cell.contentView viewWithTag:3];
    nickname.text = [dic objectForKey:@"nickname"];
    
    //设置右侧箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
