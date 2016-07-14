//
//  ArcMenuBtn.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BtnMoveDelegate;

@interface ArcMenuBtn : UIButton

@property (assign, nonatomic) CGPoint beginpoint;
@property(nonatomic,assign)id<BtnMoveDelegate> delegate;

@end

@protocol BtnMoveDelegate <NSObject>
//接口中的方法
- (void)mTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)mTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
@end