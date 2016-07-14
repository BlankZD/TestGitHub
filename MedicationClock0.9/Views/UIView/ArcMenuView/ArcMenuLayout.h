//
//  ArcMenuLayout.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcMenuBtn.h"

@protocol ArcMenuViewDelegate;

@interface ArcMenuLayout : UIView

- (instancetype)initWithFrame:(CGRect)frame;
- (void)addMenuItemWithUIImage:(UIImage *)image;
- (void)addMenuItemsWithUIImages:(NSArray<UIImage *> *)images;

@property (weak, nonatomic) id<ArcMenuViewDelegate> delegate;

// 开关按钮中心距屏幕边缘的距离
@property (assign, nonatomic) CGFloat layoutMargin;
// 开关按钮的宽和高
@property (assign, nonatomic) CGFloat buttonSwitchWidth;
@property (assign, nonatomic) CGFloat buttonSwitchHeight;
// 菜单项按钮的宽和高
@property (assign, nonatomic) CGFloat buttonItemWidth;
@property (assign, nonatomic) CGFloat buttonItemHeight;
// 默认菜单半径
@property (assign, nonatomic) CGFloat menuRadius;
// 默认菜单展开动画时长
@property (assign, nonatomic) CGFloat menuExpandInterval;
// 默认菜单展开动画延迟
@property (assign, nonatomic) CGFloat menuExpandDelay;
// 默认按钮点击动画时长
@property (assign, nonatomic) CGFloat buttonClickInterval;
// 默认按钮点击动画缩放比例
@property (assign, nonatomic) CGFloat buttonClickScale;

@property (assign, nonatomic)BOOL isExpand;
@property (strong, nonatomic)ArcMenuBtn *btnSwitch;
@property (assign, nonatomic)CGPoint btnSwitchPoint;
@property (strong, nonatomic)NSMutableArray<UIButton *> *btnItems;
@property (strong, nonatomic)NSMutableArray<NSValue *> *btnItemPoints;
@property (assign, nonatomic) CGPoint beginpoint;

//折叠菜单的函数
- (void)arcMenuUnExpand;

@end

@protocol ArcMenuViewDelegate <NSObject>

@optional
- (void)ArcMenuWillExpand:(ArcMenuLayout *)menu;
- (void)ArcMenuWillUnExpand:(ArcMenuLayout *)menu;
- (void)ArcMenuView:(ArcMenuLayout *)menu didSelectedForIndex:(NSInteger)index;

@end