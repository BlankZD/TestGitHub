//
//  SearchBluetooth.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/5/7.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SearchBluetooth : UIViewController

@property(nonatomic, retain) CBCentralManager *_centralManager;

@end
