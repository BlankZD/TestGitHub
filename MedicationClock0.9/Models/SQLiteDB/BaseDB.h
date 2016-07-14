//
//  BaseDB.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/4/6.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface BaseDB : NSObject

- (sqlite3*)getDatabase;
- (void)execSQl:(NSString*)sqlStr;

-(void)beginTransaction;
-(void)endTransaction;
-(void)rallback;

@end
