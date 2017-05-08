//
//  ControllerManager.h
//  GameBox
//
//  Created by 石燚 on 2017/4/11.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MainTabBarController.h"
#import "MyGiftBagViewController.h"
#import "DetailViewController.h"
#import "WebViewController.h"
#import "LoginViewController.h"
#import "SearchResultViewController.h"
#import "MyAppViewController.h"
#import "SearchViewController.h"

@interface ControllerManager : NSObject

/**< manager的单利 */
+ (ControllerManager *)shareManager;

/**< 根视图 */
@property (nonatomic, strong) UINavigationController *rootViewController;

//tabbar
@property (nonatomic, strong) MainTabBarController *tabbarController;

/** 我的礼包 */
@property (nonatomic, strong) MyGiftBagViewController *myGiftBagView;

/** 游戏详情页面 */
@property (nonatomic, strong) DetailViewController *detailView;

/** 网页视图 */
@property (nonatomic, strong) WebViewController *webController;

/** 登录页面 */
@property (nonatomic, strong) LoginViewController *loginViewController;

/** 搜索视图 */
@property (nonatomic, strong) SearchViewController *searchView;
/** 搜索结果页面 */
@property (nonatomic, strong) SearchResultViewController *searchResultController;

/** 我的应用 */
@property (nonatomic, strong) MyAppViewController *myAppViewController;

/** 等待的时候的屏幕 */
@property (nonatomic, strong) UIWindow *animationWindow;


/** 开启加载等待动画 */
+ (void)starLoadingAnimation;
/** 关闭加载等待动画 */
+ (void)stopLoadingAnimation;


@end
