//
//  ArcMenuView.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/30.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcMenuLayout.h"

@interface ArcMenuView : UIView <ArcMenuViewDelegate>

@property (weak, nonatomic) id<ArcMenuViewDelegate> delegate;

@end
