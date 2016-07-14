//
//  ArcMenuView.m
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "ArcMenuView.h"

@implementation ArcMenuView{
    ArcMenuLayout *arcMenuLayout;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect layoutFrame = CGRectMake(frame.size.width-200, frame.size.height-200, 200, 200);
        arcMenuLayout = [[ArcMenuLayout alloc] initWithFrame:layoutFrame];
        arcMenuLayout.delegate = self;
        [self addSubview:arcMenuLayout];
        
        NSArray<UIImage *> *menuImageArray = @[ [UIImage imageNamed:@"blood_pressure.png"], [UIImage imageNamed:@"blood_suger.png"],[UIImage imageNamed:@"add_clock_img.png"]];
        
        [arcMenuLayout addMenuItemsWithUIImages:menuImageArray];
    }
    return self;
}

// 将要展开菜单
- (void)ArcMenuWillExpand:(ArcMenuLayout *)menu {
    // 设置视图控件底部背景颜色
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.delegate ArcMenuWillExpand:menu];
}
// 将要折叠菜单
- (void)ArcMenuWillUnExpand:(ArcMenuLayout *)menu {
    // 设置视图控件底部背景颜色
    self.backgroundColor = [UIColor clearColor];
    [self.delegate ArcMenuWillUnExpand:menu];
}

- (void)ArcMenuView:(ArcMenuLayout *)menu didSelectedForIndex:(NSInteger)index {
    [self.delegate ArcMenuView:menu didSelectedForIndex:index];
}

#pragma mark - 重写UIView抬起事件的函数
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [arcMenuLayout arcMenuUnExpand];
}

#pragma mark - 重写UIView的方法，保证没有按钮的地方事件可以穿透
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(arcMenuLayout.isExpand){
        return YES;
    }else{
        if ([self pointInside:point withUIView:arcMenuLayout.btnSwitch]) {
            return YES;
        }
        for (UIButton *btn in arcMenuLayout.btnItems) {
            if ([self pointInside:point withUIView:btn]){
                return YES;
            }
        }
        return NO;
    }
}
//自定义函数判断点是否在控件内
- (BOOL)pointInside:(CGPoint)point withUIView:(UIView *)view {
    if (point.x >= view.frame.origin.x+arcMenuLayout.frame.origin.x && point.x <= view.frame.origin.x+arcMenuLayout.frame.origin.x+view.frame.size.width && point.y >= view.frame.origin.y+arcMenuLayout.frame.origin.y && point.y <= view.frame.origin.y+arcMenuLayout.frame.origin.y+view.frame.size.height) {
        return YES;
    }
    return NO;
}

@end
