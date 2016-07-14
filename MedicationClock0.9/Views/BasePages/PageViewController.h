//
//  PageViewController.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/14.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController

@property (nonatomic, retain) id dataObject;
@property(nonatomic, retain) NSDictionary *paramDic;
@property(nonatomic, retain) UIViewController *parentPage;

@end
