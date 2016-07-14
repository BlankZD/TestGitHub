//
//  MyCalendarView.h
//  MedicationClockTest
//
//  Created by 歐陽 on 16/3/23.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

//声明内部类（或内部接口）
@protocol MyCalendarViewDelegate;

@interface MyCalendarView : UIView{
    NSSet *_markDay;
}
-(void)setMarkDay:(NSSet *)markDay;
-(void)refresh;

//当前显示的月份
@property(nonatomic,retain)NSDate *currDate;
//选中的日期
@property(nonatomic,retain)NSDate *secDate;
//当前的高度
@property(nonatomic,getter=getCalendarHeight) float calendarHeight;

@property(nonatomic,assign)id<MyCalendarViewDelegate> delegate;

@end

//定义内部类（或内部接口）
@protocol MyCalendarViewDelegate <NSObject>
//接口中的方法
@required
-(void)MyCalendarView:(MyCalendarView *)view monthChanged:(NSString *)strYearMonth;
@optional
-(void)MyCalendarView:(MyCalendarView *)view dateSelected:(NSDate *)date;
-(void)MyCalendarView:(MyCalendarView *)view dateSelected:(NSDate *)date state:(int)state;
@end
