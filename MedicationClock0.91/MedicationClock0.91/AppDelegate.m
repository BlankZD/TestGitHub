//
//  AppDelegate.m
//  Learn2
//
//  Created by 歐陽 on 16/3/12.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "AlarmViewController.h"

#import "CommonUtil.h"
#import "HttpUtil.h"
#import "Utils.h"//20160324 jjw 添加runBk的头文件
#import "NotificationUtil.h"
#import "MyUncaughtExceptionHandler.h"

#import "BaseDB.h"
#import "MedicationRecordDB_.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //配置捕捉异常的函数
    [MyUncaughtExceptionHandler setDefaultHandler];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif){
        //如果是点击通知打开的程序
        NSLog(@"Recieved Notification %@",localNotif);
        NSDictionary* infoDic = localNotif.userInfo;
        NSLog(@"infoDic=%@",infoDic);
        NSLog(@"userInfo description=%@",[infoDic description]);
        [self toAlarmPage:infoDic];
    }else{
        //判断应用是否注册了通知权限
        if([[UIApplication sharedApplication]currentUserNotificationSettings].types==UIUserNotificationTypeNone){
            //如果没有注册，调用注册通知的函数
            [self registNotificationIOS8];
        }
        
        //调用自动登录的函数
        //    [self autologin];
        //跳转到登录界面
        UIViewController *viewController = [[LoginViewController alloc] init];
        [self toPage:viewController];
    }
    
    return YES;
}
//自定义的自动登录函数
- (void)autologin{
    //从本地读取已保存的账号信息（待完善）
    NSString *username = @"";
    NSString *password = @"";
    
    //访问http实现自动登录的功能
    NSString *urlStr = @"http://www.xbrjblkj.com:8124/BlmemServer2.04/appUserAction!userLogin.ac";
    NSString *params = [NSString stringWithFormat:@"store_id=1&username=%@&password=%@", username, password];
    void (^callbackHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            //输出返回值
            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"receiveStr=%@", receiveStr);
            //解析json格式数据
            NSError *error;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if(error == nil){       //如果json解析正确
                NSString *user_id = [jsonDictionary objectForKey:@"user_id"];
                NSString *username = [jsonDictionary objectForKey:@"username"];
                NSString *nickname = [jsonDictionary objectForKey:@"nickname"];
                NSString *member_card_id = [jsonDictionary objectForKey:@"member_card_id"];
                NSString *login_id = [jsonDictionary objectForKey:@"login_id"];
                NSString *last_login_time = [jsonDictionary objectForKey:@"last_login_time"];
                NSString *head_img_mark = [jsonDictionary objectForKey:@"head_img_mark"];
                
                //实现页面跳转
                //页面跳转传值的相关知识：http://www.cnblogs.com/heri/archive/2013/03/18/2965815.html
                //通过委托类传递对象到下一页面
                
                //跳转到主界面
                UIViewController *viewController = [[MainViewController alloc] init];
                [self toPage:viewController];
            }else{
                //否则跳转到登录界面
                UIViewController *viewController = [[LoginViewController alloc] init];
                [self toPage:viewController];
            }
        }else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
            //否则跳转到登录界面
            UIViewController *viewController = [[LoginViewController alloc] init];
            [self toPage:viewController];
        }else if (error != nil){
            NSLog(@"Error happened = %@",error);
            //否则跳转到登录界面
            UIViewController *viewController = [[LoginViewController alloc] init];
            [self toPage:viewController];
        }
        
    };
    [HttpUtil httpPost:urlStr param:params callbackHandler:callbackHandler];
}
//通过导航栏控制器加载页面视图
- (void)toPage:(UIViewController*)viewController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //创建导航栏控制器
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewController];
    //设置导航栏标题的字体和颜色
//    [nc.navigationBar setTitleTextAttributes:
//    @{NSFontAttributeName:[UIFont systemFontOfSize:19],
//      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //设置导航栏的背景颜色
//    [nc.navigationBar setBarTintColor:[UIColor blueColor]];
    //设置导航栏上按钮的文字颜色
//    [nc.navigationBar setTintColor:[UIColor whiteColor]];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
}

//自定义跳转到闹钟闹铃界面的函数
- (void)toAlarmPage:(NSDictionary*)infoDict{
    //创建window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //创建ViewController实例
    AlarmViewController *viewController = [[AlarmViewController alloc] initWithNibName:@"AlarmViewController" bundle:nil];
    viewController.infoDict = infoDict;
    viewController.isRootView=true;
    //设置window根视图控制器
    self.window.rootViewController = viewController;
    //    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}
- (void)toAlarm:(NSDictionary*)infoDict{
    AlarmViewController *viewController= [[AlarmViewController alloc]initWithNibName:@"AlarmViewController" bundle:[NSBundle mainBundle]];
    viewController.infoDict = infoDict;
    viewController.isRootView=false;
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

//自定义打开闹钟闹铃对话框的函数
- (void)alarmAlertView:(UILocalNotification *)notification{
    NSString *title = NSLocalizedString(@"提醒", nil);
    NSString *message = NSLocalizedString(notification.alertBody, nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"稍后服药", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"马上服药", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了稍后服药");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了马上服药");
        BaseDB *dbDriver = [[BaseDB alloc]init];
        //        [MedicationRecordDB_ insertByDate:dbDriver];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

/** 点击通知栏的快捷回复按钮后调用的方法 **/
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    //在非本App界面时收到本地消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮，notification为消息内容
    NSLog(@"identifier=%@---notification=%@",identifier,notification);
    if([identifier isEqualToString:@"action"]){
        NSDictionary *infoDict = notification.userInfo;
        [self toAlarm:infoDict];
    }else if([identifier isEqualToString:@"action2"]){
        
    }
    completionHandler();//处理完消息，最后一定要调用这个代码块
}

/** 收到本地推送消息后调用的方法 **/
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //一般需要应用程序后台运行时才会显示提示，前台运行时一般不显示提示。如果想要当应用程序前台应行时也显示提示，则可以通过将下面函数加到appDelegate中实现
    UIApplicationState state = application.applicationState;
    application.applicationIconBadgeNumber = 0;     //设置图标上的红圈数字为0
    NSDictionary *infoDict = notification.userInfo;
    if (state == UIApplicationStateActive) {
        NSLog(@"收到本地通知");
//        [self alarmAlertView:notification];
        [self toAlarm:infoDict];
    }else{
        [self toAlarm:infoDict];
    }
    //添加加时闹钟
    [NotificationUtil setExtraNotificationWithTimeStr:[infoDict valueForKey:@"alarm_time"]];
}

-(void)registNotificationIOS8{
    if(IOS8){
        //1.创建消息上面要添加的动作(按钮的形式显示出来)
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = @"action";//按钮的标示
        action.title=@"Accept";//按钮的标题
        action.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        //    action.authenticationRequired = YES;
        //    action.destructive = YES;
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        action2.identifier = @"action2";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action.destructive = YES;
        
        //2.创建动作(按钮)的类别集合
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"alert";//这组动作的唯一标示,推送通知的时候也是根据这个来区分
        [categorys setActions:@[action,action2] forContext:(UIUserNotificationActionContextMinimal)];
        
        //3.创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:type categories:[NSSet setWithObjects:categorys, nil, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
    }else{
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: type];
    }
}

/** 注册registerUserNotificationSettings:后，回调的方法 **/
-(void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    if(notificationSettings.types!=UIUserNotificationTypeNone){
        NSLog(@"注册通知成功");
    }else{
        NSLog(@"注册通知失败");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //20160324 jjw 这段代码让程序可以在后台运行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[RunInBackground sharedBg] startRunInbackGround];
        [[NSRunLoop currentRunLoop] run];
        //self.thread = [NSThread currentThread];
        //NSLog(@"applicationDidEnterBackground");
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[RunInBackground sharedBg] stopAudioPlay];//20160324 jjw 进入前台的时候关闭后台运行
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // 应用从后台显示到前台时调用的函数
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/** 禁止横屏的函数 **/
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
