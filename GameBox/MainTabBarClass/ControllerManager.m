//
//  ControllerManager.m
//  GameBox
//
//  Created by 石燚 on 2017/4/11.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "ControllerManager.h"

static ControllerManager *manager = nil;

@implementation ControllerManager

//单例
+ (ControllerManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ControllerManager alloc]init];
    });
    return manager;
}

#pragma mark - getter 
- (UINavigationController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [[UINavigationController alloc]initWithRootViewController:self.tabbarController];
        _rootViewController.navigationBarHidden = YES;
    }
    return _rootViewController;
}

- (MainTabBarController *)tabbarController {
    if (!_tabbarController) {
        _tabbarController = [[MainTabBarController alloc]init];
    }
    return _tabbarController;
}


//我的礼包视图
- (MyGiftBagViewController *)myGiftBagView {
    if (!_myGiftBagView) {
        _myGiftBagView = [MyGiftBagViewController new];
    }
    return _myGiftBagView;
}

/**游戏详情页面*/
- (DetailViewController *)detailView {
    if (!_detailView) {
        _detailView = [DetailViewController new];
    }
    return _detailView;
}

/**网页*/
- (WebViewController *)webController {
    if (!_webController) {
        _webController = [[WebViewController alloc] init];
        
    }
    return _webController;
}







@end