//
//  GiftBagViewController.m
//  GameBox
//
//  Created by 石燚 on 17/4/10.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "GiftBagViewController.h"
#import "ControllerManager.h"
#import "GiftBagCell.h"
#import "GiftRequest.h"
#import "RequestUtils.h"
#import "SearchGiftController.h"
#import "SearchModel.h"
#import "SearchGiftResultController.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import "UserModel.h"
#import "GameRequest.h"


#define CELLIDENTIFIER @"GiftBagCell"

@interface GiftBagViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,GiftBagCellDelegate>

/**列表*/
@property (nonatomic, strong) UITableView *tableView;

/**显示数组*/
@property (nonatomic, strong) NSMutableArray *showArray;

/**我的礼包按钮*/
@property (nonatomic, strong) UIBarButtonItem *rightBtn;

/** 搜索 */
@property (nonatomic, strong) UISearchBar *searchBar;

/** 应用按钮(左边按钮) */
@property (nonatomic, strong) UIBarButtonItem *downLoadBtn;

/** 消息按钮(右边按钮) */
@property (nonatomic, strong) UIBarButtonItem *messageBtn;

/** 取消按钮(右边按钮) */
@property (nonatomic, strong) UIBarButtonItem *cancelBtn;

/** 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;

/** 礼包搜索页面 */
@property (nonatomic, strong) SearchGiftController *searchGiftCongroller;

@property (nonatomic, assign) BOOL isAll;


@end

@implementation GiftBagViewController

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.titleView = self.searchBar;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.titleView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self initUserInterface];

}

/**初始化数据*/
- (void)initDataSource {
    
    //进入刷新状态
    [self.tableView.mj_header beginRefreshing];
    

}


/**初始化用户界面*/
- (void)initUserInterface {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.navigationItem.leftBarButtonItem = self.downLoadBtn;
    self.navigationItem.rightBarButtonItem = self.messageBtn;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - respond
/** 我的应用 */
- (void)clickDownloadBtn {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:[ControllerManager shareManager].myAppViewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

/** 我的消息 */
- (void)clickMessageBtn {
    self.hidesBottomBarWhenPushed = YES;
    if ([UserModel CurrentUser]) {
        [self.navigationController pushViewController:[ControllerManager shareManager].myNewsViewController animated:YES];
    } else {
        [self.navigationController pushViewController:[ControllerManager shareManager].loginViewController animated:YES];
    }
    self.hidesBottomBarWhenPushed = NO;
}

- (void)clickCancelBtn {
    [self.searchBar resignFirstResponder];
    
    self.searchBar.text = @"";
    
    [self.searchGiftCongroller.view removeFromSuperview];
    
    self.navigationItem.rightBarButtonItem = self.messageBtn;
    self.navigationItem.leftBarButtonItem = self.downLoadBtn;
}

#pragma mark - searchDeleagete
//即将开始搜索
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    self.navigationItem.rightBarButtonItem = self.cancelBtn;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.view addSubview:self.searchGiftCongroller.view];
    [self addChildViewController:self.searchGiftCongroller];
    
    
    return YES;
}

//开始搜索
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

}

//即将结束搜索
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    
    return YES;
}

//结束搜索
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {

}

//文本已经改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

//文编即将改变
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    return YES;
}

//点击cancel按钮的响应事件
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //点击cancel按钮
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (![searchBar.text isEqualToString:@""]) {
        [SearchModel addGiftSearchHistoryWithKeyword:searchBar.text];

        
        SearchGiftResultController *search = [SearchGiftResultController new];
        search.keyword = searchBar.text;
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:search animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}


/**刷新数据*/
- (void)refreshData {
    WeakSelf;
    [GiftRequest giftListWithPage:@"1" Completion:^(NSDictionary * _Nullable content, BOOL success) {
        if (REQUESTSUCCESS && success) {
            
            _showArray = [content[@"data"][@"list"] mutableCopy];
            _isAll = NO;
            _currentPage = 1;
            
        } else {
            _currentPage = 0;
        }
        
        if (_showArray && _showArray.count > 0) {
            weakSelf.tableView.backgroundView = nil;
        } else {
            weakSelf.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wuwangluo"]];
        }
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)loadMoreData {
    if (_isAll) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        _currentPage++;

        [GiftRequest giftListWithPage:[NSString stringWithFormat:@"%ld",(long)_currentPage] Completion:^(NSDictionary * _Nullable content, BOOL success) {
            if (REQUESTSUCCESS && success) {
                
                NSArray *array = content[@"data"][@"list"];
                if (array.count == 0) {
                    _isAll = YES;
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [_showArray addObjectsFromArray:array];
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView reloadData];
                }
                
            } else {
                _showArray = nil;
                _currentPage = 0;
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
        }];
    }
}


/** 点击cell的领取按钮的响应事件 */
- (void)getGiftBagCellAtIndex:(NSInteger)idx {
    NSString *str = _showArray[idx][@"card"];
    
    if ([str isKindOfClass:[NSNull class]]) {
        //领取礼包
        [GiftRequest getGiftWithGiftID:_showArray[idx][@"id"] Completion:^(NSDictionary * _Nullable content, BOOL success) {
            if (success && REQUESTSUCCESS) {
                NSMutableDictionary *dict = [_showArray[idx] mutableCopy];
                [dict setObject:content[@"data"] forKey:@"card"];
                [_showArray replaceObjectAtIndex:idx withObject:dict];
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
                
                [GiftRequest showAlertWithMessage:@"已领取礼包兑换码" dismiss:^{
                    
                }];
            } else {
                [GiftRequest showAlertWithMessage:@"礼包发送完了" dismiss:nil];
            }
        }];
        
    } else {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        pasteboard.string = str;
        
        [GiftRequest showAlertWithMessage:@"已复制礼包兑换码" dismiss:^{
            
        }];
    }
}





#pragma mark - tableviewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftBagCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFIER forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    
    cell.currentIdx = indexPath.row;
    
    cell.dict = _showArray[indexPath.row];
    
    [cell.packLogo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGEURL,_showArray[indexPath.row][@"pack_logo"]]]  placeholderImage:[UIImage imageNamed:@"image_downloading"]];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 3)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    return titleLabel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kSCREEN_WIDTH, kSCREEN_HEIGHT - 113) style:(UITableViewStylePlain)];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"GiftBagCell" bundle:nil] forCellReuseIdentifier:CELLIDENTIFIER];
        
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        
        //下拉刷新
        MJRefreshNormalHeader *customRef = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        
        [customRef setTitle:@"数据已加载" forState:MJRefreshStateIdle];
        [customRef setTitle:@"刷新数据" forState:MJRefreshStatePulling];
        [customRef setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
        [customRef setTitle:@"即将刷新" forState:MJRefreshStateWillRefresh];
        [customRef setTitle:@"所有数据加载完毕，没有更多的数据了" forState:MJRefreshStateNoMoreData];
        
        
        //自动更改透明度
        _tableView.mj_header.automaticallyChangeAlpha = YES;
    
        _tableView.mj_header = customRef;
        
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        _tableView.tableFooterView = [UIView new];
        
        
    }
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 20)];
        
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 14.0f;
            searchField.layer.masksToBounds = YES;
        }
        
        
        _searchBar.placeholder = @"搜索礼包";
        _searchBar.tintColor = [UIColor blueColor];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIBarButtonItem *)downLoadBtn {
    if (!_downLoadBtn) {
        _downLoadBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"homePage_download"] style:(UIBarButtonItemStyleDone) target:self action:@selector(clickDownloadBtn)];
    }
    return _downLoadBtn;
}

- (UIBarButtonItem *)messageBtn {
    if (!_messageBtn) {
        _messageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"homePage_message"] style:(UIBarButtonItemStyleDone) target:self action:@selector(clickMessageBtn)];
    }
    return _messageBtn;
}

- (UIBarButtonItem *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:(UIBarButtonItemStyleDone) target:self action:@selector(clickCancelBtn)];
    }
    return _cancelBtn;
}

- (SearchGiftController *)searchGiftCongroller {
    if (!_searchGiftCongroller) {
        _searchGiftCongroller = [[SearchGiftController alloc] init];
    }
    return _searchGiftCongroller;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
