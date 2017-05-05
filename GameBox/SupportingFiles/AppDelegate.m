//
//  AppDelegate.m
//  GameBox
//
//  Created by 石燚 on 17/4/10.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "AppDelegate.h"
#import "ControllerManager.h"

#import "ChangyanSDK.h"


@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    ControllerManager *manager = [[ControllerManager alloc]init];
    
    self.window.rootViewController = manager.rootViewController;
    
    [ChangyanSDK registerApp:@"cysXjYB6V"
                      appKey:@"f6b34b898c39f5ff7f95828c78126d4f"
                 redirectUrl:nil
        anonymousAccessToken:nil];
    
//    [ChangyanSDK registerApp:@"cysYKUClL" appKey:@"C66A5BAD9ED000011E5A1F685821111F" redirectUrl:nil anonymousAccessToken:nil];
    
    
//    [ChangyanSDK getUserInfo:^(CYStatusCode statusCode, NSString *responseStr) {
//        
//        
//    }];
  
    
//    [ChangyanSDK setLoginViewController:[ControllerManager shareManager].loginViewController];
    

    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [[NSUserDefaults standardUserDefaults] setObject:idfv forKey:@"deviceID"];
    
    
    [self.window makeKeyAndVisible];
    
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
