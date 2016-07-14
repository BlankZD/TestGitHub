//
//  UIViewController+BackButtonHandler.h
//  MedicationClock0.9
//
//  Created by 歐陽 on 16/5/19.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController(BackButtonHandler) <BackButtonHandlerProtocol>

@end
