//
//  TxtViewController.m
//  TestLoadImage
//
//  Created by 歐陽 on 16/5/11.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "TxtViewController.h"

#import "VerticallyAlignedLabel.h"
#import "FileUtil.h"

@interface TxtViewController ()

@end

@implementation TxtViewController{
    int y0;
    int screenWidth;
    int screenHeight;
    BOOL editable;
    
    VerticallyAlignedLabel *_textLabel;
    UITextView *_textView;
    UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
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
    screenHeight = rect.size.height;
    //添加导航栏右边的按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    // Do any additional setup after loading the view.
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.view addSubview:_scrollView];
    
    _textLabel = [[VerticallyAlignedLabel alloc]init];
    [_textLabel setVerticalAlignment:VerticalAlignmentTop];
    _textLabel.numberOfLines=0;
    [_scrollView addSubview:_textLabel];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, y0, screenWidth, screenHeight-y0)];
//    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [self.view addSubview:_textView];
    [_textView setHidden:true];
    
    if(_fileDic!=nil){
        NSString *fileName = _fileDic[@"fileName"];
        NSString *filePath = _fileDic[@"filePath"];
        [self setTitle:fileName];
        
        NSString *txtContent = [FileUtil readTxtFile:filePath];
//        txtContent = [txtContent stringByReplacingOccurrencesOfString:@"" withString:@"\\n"];
        [_textLabel setText:txtContent];
        CGSize textLabelSize = [txtContent sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(screenWidth, 1000)  lineBreakMode:UILineBreakModeWordWrap];
        _textLabel.frame = CGRectMake(0, 0, screenWidth, textLabelSize.height);
        _scrollView.contentSize = _textLabel.frame.size;
    }else{
        [self setTitle:@"NULL"];
    }
    
}

//点击导航栏右边按钮的触发函数
-(void) clickRightButton{
    if(_fileDic!=nil){
        if(editable){
            NSString *filePath = _fileDic[@"filePath"];
            NSString *txtEdit = _textView.text;
            BOOL res = [FileUtil saveTxtFile:txtEdit path:filePath];
            if(res){
                NSString *txtContent = [FileUtil readTxtFile:filePath];
//                txtContent = [txtContent stringByReplacingOccurrencesOfString:@"" withString:@"\\n"];
                [_textLabel setText:txtContent];
                CGSize textLabelSize = [txtContent sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(screenWidth, 1000)  lineBreakMode:UILineBreakModeWordWrap];
                _textLabel.frame = CGRectMake(0, 0, screenWidth, textLabelSize.height);
                _scrollView.contentSize = _textLabel.frame.size;
                [_textView setHidden:true];
                [_scrollView setHidden:false];
                UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
                [self.navigationItem setRightBarButtonItem:rightButton];
                editable = false;
            }else{
                NSLog(@"编辑报错");
            }
        }else{
            NSString *filePath = _fileDic[@"filePath"];
            NSString *txtContent = [FileUtil readTxtFile:filePath];
            [_textView setText:txtContent];
            
            [_scrollView setHidden:true];
            [_textView setHidden:false];
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
            [self.navigationItem setRightBarButtonItem:rightButton];
            editable = true;
        }
    }else{
        [self setTitle:@"NULL"];
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
