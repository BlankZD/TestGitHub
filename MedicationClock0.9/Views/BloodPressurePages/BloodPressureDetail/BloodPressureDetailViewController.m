//
//  BloodPressureDetailViewController.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/14.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "BloodPressureDetailViewController.h"
#import "PressureDetailPage1ViewController.h"
#import "PressureDetailPage2ViewController.h"
#import "UIColor+DIY.h"

//页面标签栏的高
#define SegmentedControlHeight 30
//页面标签栏的上边距
#define SegmentedControlMarginTop 15
//子页面的初始y坐标
#define PageY0 (SegmentedControlHeight+SegmentedControlMarginTop*2)

@interface BloodPressureDetailViewController ()
//<UIPageViewControllerDataSource>

@end

@implementation BloodPressureDetailViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    
    UISegmentedControl *segmentedControl;
    UIPageViewController *pageController;
    NSArray *pageContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor segmentedBlueColor];
    //设置导航栏标题
    [self.navigationItem setTitle:@"血压分析"];
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
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化页面窗口
    [self initPageController];
    //初始化SegmentedControl控件
    [self initSegmentedControlView];
}

-(void)initSegmentedControlView{
    NSArray *segmentedData = [[NSArray alloc]initWithObjects:@"近期报告",@"总报告",nil];
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedData];
    segmentedControl.frame = CGRectMake(screenWidth/8, y0+SegmentedControlMarginTop, screenWidth*3/4, SegmentedControlHeight);
    //设置视图样式
    segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;
    //这个是设置按下按钮时的颜色
    segmentedControl.tintColor = [UIColor whiteColor];
    //segmentedControl.tintColor = [UIColor segmentedBlueColor];
    segmentedControl.selectedSegmentIndex = 0;//默认选中的按钮索引
    //设置正常状态时的属性,比如字体的大小和颜色等
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:12],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil, nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];   // NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:12],NSFontAttributeName,[UIColor segmentedBlueColor], NSForegroundColorAttributeName, nil, nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    //设置按下状态时的属性
     NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor segmentedBlueColor] forKey:NSForegroundColorAttributeName];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    //设置分段控件点击相应事件
    [segmentedControl addTarget:self action:@selector(doSomethingInSegment:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}
-(void)doSomethingInSegment:(UISegmentedControl *)Seg{
    NSInteger index = Seg.selectedSegmentIndex;
    if(index==0){
        PageViewController *viewController = pageController.viewControllers[0];
        NSUInteger index = [self indexOfViewController:viewController];
        if (index == NSNotFound || index <= 0) {
            return;
        }
        index--;
        NSArray *viewControllers =[NSArray arrayWithObject:[self viewControllerAtIndex:index]];
        [pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }else{
        PageViewController *viewController = pageController.viewControllers[0];
        NSUInteger index = [self indexOfViewController:viewController];
        if (index == NSNotFound || index>=([pageContent count]-1)) {
            return;
        }
        index++;
        NSArray *viewControllers =[NSArray arrayWithObject:[self viewControllerAtIndex:index]];
        [pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

-(void)initPageController{
    // 初始化页面数据
    [self initContentPages];
    // 设置UIPageViewController的配置项
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]forKey: UIPageViewControllerOptionSpineLocationKey];
    // 实例化UIPageViewController对象，根据给定的属性
    pageController = [[UIPageViewController alloc]
                      initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                      navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                      options: options];
    // 设置UIPageViewController对象的代理
//    pageController.dataSource = self;
    // 定义“这本书”的尺寸
    [[pageController view] setFrame:CGRectMake(0, y0+PageY0, self.view.frame.size.width, self.view.frame.size.height-y0-PageY0)];
    //     让UIPageViewController对象，显示相应的页数据。
    //     UIPageViewController对象要显示的页数据封装成为一个NSArray。
    //     因为我们定义UIPageViewController对象显示样式为显示一页（options参数指定）。
    //     如果要显示2页，NSArray中，应该有2个相应页数据。
    NSArray *viewControllers =[NSArray arrayWithObject:[self viewControllerAtIndex:0]];
    [pageController setViewControllers:viewControllers
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:NO
                            completion:nil];
    
    // 在页面上，显示UIPageViewController对象的View
//    [self addChildViewController:pageController];
    [self.view addSubview:[pageController view]];
}

-(void)initContentPages{
    NSMutableArray *pageStrings = [[NSMutableArray alloc] init];
    for (int i = 1; i < 3; i++){
        NSString *contentString = [[NSString alloc] initWithFormat:@"PressureDetailPage%dViewController", i];
        [pageStrings addObject:contentString];
    }
    pageContent = [[NSArray alloc] initWithArray:pageStrings];
}

// 根据页面索引创建页面对象
- (PageViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([pageContent count] == 0) || (index >= [pageContent count])) {
        return nil;
    }
    // 根据页面名称创建页面对象
    if(index==0){
        PageViewController *viewController = [[PressureDetailPage1ViewController alloc] initWithNibName:[pageContent objectAtIndex:index] bundle:nil];
        viewController.dataObject =[pageContent objectAtIndex:index];
        return viewController;
    }else{
        PageViewController *viewController = [[PressureDetailPage2ViewController alloc] initWithNibName:[pageContent objectAtIndex:index] bundle:nil];
        viewController.dataObject =[pageContent objectAtIndex:index];
        return viewController;
    }
}

- (NSUInteger)indexOfViewController:(PageViewController *)viewController {
    return [pageContent indexOfObject:viewController.dataObject];
}

//#pragma mark - 实现UIPageViewControllerDataSource接口中的函数
///** 返回上一个页面对象 **/
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PageViewController *)viewController{
//    NSUInteger index = [self indexOfViewController:viewController];
//    if (index == NSNotFound || index <= 0) {
//        return nil;
//    }
//    index--;
//    segmentedControl.selectedSegmentIndex = index;
//    return [self viewControllerAtIndex:index];
//}
///** 返回下一个页面对象 **/
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PageViewController *)viewController{
//    NSUInteger index = [self indexOfViewController:viewController];
//    if (index == NSNotFound || index>=([pageContent count]-1)) {
//        return nil;
//    }
//    index++;
//    segmentedControl.selectedSegmentIndex = index;
//    return [self viewControllerAtIndex:index];
//}

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
