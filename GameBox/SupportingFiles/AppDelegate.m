//
//  AppDelegate.m
//  GameBox
//
//  Created by 石燚 on 17/4/10.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "AppDelegate.h"
#import "ControllerManager.h"
#import "RequestUtils.h"

#import "ChangyanSDK.h"


@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [ControllerManager shareManager].rootViewController;
    
    [self.window makeKeyAndVisible];
    
    [ChangyanSDK registerApp:@"cysYKUClL"
                      appKey:@"6c88968800e8b236e5c69b8634db704d"
                 redirectUrl:nil
        anonymousAccessToken:nil];
    
    [ChangyanSDK setAllowSelfLogin:YES];
    
    [ChangyanSDK setAllowAnonymous:NO];
    [ChangyanSDK setAllowRate:NO];
    [ChangyanSDK setAllowUpload:YES];
    [ChangyanSDK setAllowWeiboLogin:NO];
    [ChangyanSDK setAllowQQLogin:NO];
    [ChangyanSDK setAllowSohuLogin:NO];
    
    
    
    //请求数据总借口
    [RequestUtils postRequestWithURL:URLMAP params:nil completion:^(NSDictionary *content, BOOL success) {
        if (success && !((NSString *)content[@"status"]).boolValue) {
            NSDictionary *dict = content[@"data"];
            syLog(@"%@",dict);
            NSArray *keys = [dict allKeys];
            [keys enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SAVEOBJECT_AT_USERDEFAULTS(dict[obj], obj);
            }];
            SAVEOBJECT_AT_USERDEFAULTS(keys, @"MAP");
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
//    NSArray *arry = OBJECT_FOR_USERDEFAULTS(@"MAP");
//    [arry enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        syLog(@"%@",obj);
//    }];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
