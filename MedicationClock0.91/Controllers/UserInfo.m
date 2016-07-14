//
//  UserInfo.m
//  MedicationClockTest
//
//  Created by jam on 16/3/31.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+(UserInfo *)userInfo:(BOOL)create{
    static UserInfo * user;
    if(create){
        user= [[UserInfo alloc] init];
    }else{
        if(user==nil){
            user= [[UserInfo alloc] init];
        }
    }
    return user;
}

+(void)setUserInfo:(NSString *) user_id login_id:(NSString *)login_id username:(NSString *)username nickname:(NSString *)nickname{
    UserInfo * user =[UserInfo userInfo:NO];
    
    [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
    user.user_id=user_id;
    [[NSUserDefaults standardUserDefaults] setValue:login_id forKey:@"login_id"];
     user.login_id=login_id;
    [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
     user.username=username;
    [[NSUserDefaults standardUserDefaults] setValue:nickname forKey:@"nickname"];
     user.nickname=nickname;
}

+(UserInfo *)getUserInfo{
    UserInfo * user =[UserInfo userInfo:NO];
    
    user.user_id =[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    user.login_id =[[NSUserDefaults standardUserDefaults] valueForKey:@"login_id"];
    user.username =[[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    user.nickname =[[NSUserDefaults standardUserDefaults] valueForKey:@"nickname"];
    
    return user;
}

@end
