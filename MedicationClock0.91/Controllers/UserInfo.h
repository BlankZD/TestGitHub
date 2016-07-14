//
//  UserInfo.h
//  MedicationClockTest
//
//  Created by jam on 16/3/31.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property  NSString *user_id ;
@property  NSString *username ;
@property  NSString *nickname ;
@property  NSString *member_card_id ;
@property  NSString *login_id ;
@property  NSString *last_login_time ;
@property  NSString *head_img_mark ;


+(UserInfo *)userInfo:(BOOL)create;



+(void)setUserInfo:(NSString *) userid login_id:(NSString *)login_id username:(NSString *)username nickname:(NSString *)nickname;

+(UserInfo *)getUserInfo;


@end
