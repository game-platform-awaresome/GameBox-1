//
//  HomeRecommentController.m
//  GameBox
//
//  Created by 石燚 on 2017/4/20.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "HomeRecommentController.h"
#import "RecommentTableHeader.h"
#import "SearchCell.h"
#import "ControllerManager.h"
#import "RCCCollectionViewCell.h"

//四个子视图
#import "NewServerController.h"
#import "ActivityController.h"
#import "RGiftBagController.h"
#import "StrategyController.h"

#import "GameRequest.h"
#import "AppModel.h"
#import "GameNet+CoreDataClass.h"

#import "MJRefresh.h"
#import "UIImageView+WebCache.h"

#define CELLIDENTIFIER @"SearchCell"
#define BTNTAG 1300

@interface HomeRecommentController ()<UITableViewDelegate,UITableViewDataSource,SearchCellDelelgate,RecommentTableHeaderDeleagte,UICollectionViewDelegate,UICollectionViewDataSource>

/**推荐游戏列表*/
@property (nonatomic, strong) UITableView *tableView;
/**推荐游戏数据*/
@property (nonatomic, strong) NSMutableArray *showArray;
/** 本地游戏 */
@property (nonatomic, strong) NSArray *localArray;
/**轮播图*/
@property (nonatomic, strong) RecommentTableHeader *rollHeader;
/**头部视图*/
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSArray *collectionArray;
@property (nonatomic, strong) NSArray *collectionImage;
@property (nonatomic, strong) UICollectionView *collectionView;

/**开服表*/
@property (nonatomic, strong) NewServerController *rNewServerController;
/**活动*/
@property (nonatomic, strong) ActivityController *rActivityController;
/**礼包*/
@property (nonatomic, strong) RGiftBagController *rGiftBagController;
/**攻略*/
@property (nonatomic, strong) StrategyController *rStrategyController;

/**子视图数组*/
@property (nonatomic, strong) NSArray<UIViewController *> * childControllers;

/**< 总共的页数 */
@property (nonatomic, assign) NSInteger totalPage;

/**< 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL isAll;

@end

@implementation HomeRecommentController

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.rollHeader startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.rollHeader stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self initUserInterface];
}


- (void)initDataSource {
    _childControllers = @[self.rNewServerController,self.rActivityController,self.rGiftBagController,self.rStrategyController];

    _collectionArray = @[@"开服表",@"活动",@"礼包",@"攻略"];
    _collectionImage = @[@"homePage_newServer",@"homePage_rankList",@"homePage_giftBag",@"homePage_strategy"];
    //刷新视图
    [self.tableView.mj_header beginRefreshing];
    
    
    //缓存logo
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    
        NSArray<GameNet *> *array = [GameRequest getAllgameInfo];
        [array enumerateObjectsUsingBlock:^(GameNet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGEURL,obj.logoUrl]] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (finished) {
                    [GameRequest saveGameLogoData:image WithGameID:obj.gameID];
                }
            }];
        }];
    
        
        
        
//    });
}

- (void)initUserInterface {
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
}

#pragma mkar - method
/**刷新数据*/
- (void)refreshData {
    WeakSelf;
    [GameRequest recommendGameWithPage:nil Completion:^(NSDictionary * _Nullable content, BOOL success) {

        if (success && !((NSString *)content[@"status"]).boolValue) {
            self.rollHeader.rollingArray = content[@"data"][@"banner"];
            _showArray = [content[@"data"][@"gamelist"] mutableCopy];
        
            //测试崩溃收集的数据
//            _showArray = [@[@"",@""] mutableCopy];
            _currentPage = 1;
            _isAll = NO;
            
            [weakSelf checkLocalGamesWith:_showArray];
            
            [self.tableView reloadData];
        
        } else {
            _currentPage = 0;
        }
        
        if (_showArray && _showArray.count > 0) {
            weakSelf.tableView.backgroundView = nil;
        } else {
            weakSelf.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wuwangluo"]];
        }
        
        if (self.rollHeader.rollingArray.count > 0) {
            weakSelf.tableView.tableHeaderView = weakSelf.rollHeader;
        } else {
            weakSelf.tableView.tableHeaderView = nil;
        }

        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
    }];
    
    
}

/** 加载更多数据 */
- (void)loadMoreData {
    if (_isAll || _currentPage == 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        //页数加一
        _currentPage++;
        
        [GameRequest recommendGameWithPage:[NSString stringWithFormat:@"%ld",_currentPage] Completion:^(NSDictionary * _Nullable content, BOOL success) {
            if (success && !((NSString *)content[@"status"]).boolValue) {
                NSMutableArray *array = [content[@"data"][@"gamelist"] mutableCopy];
                if (array.count == 0) {
                    _isAll = YES;
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [self checkLocalGamesWith:array];
                    [_showArray addObjectsFromArray:array];
                    
                    [self.tableView reloadData];
                    [self.tableView.mj_footer endRefreshing];
                }
            } else {
                _isAll = YES;
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
}

- (void)checkLocalGamesWith:(NSMutableArray *)array {
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary *dictLocal = [GameRequest gameLocalWithGameID:array[i][@"id"]];
        if (dictLocal && dictLocal.count > 0) {
            NSMutableDictionary *dict = [array[i] mutableCopy];
            [dict setObject:@"1" forKey:@"isLocal"];
            [array replaceObjectAtIndex:i withObject:dict];
        }
    }
    
}


#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.delegate = self;
    
    cell.dict = _showArray[indexPath.row];
    
    [cell.gameLogo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGEURL,_showArray[indexPath.row][@"logo"]]] placeholderImage:[UIImage imageNamed:@"image_downloading"]];
    
    
    
//    GameNet *game = _showArray[indexPath.row];
//    
//    UIImage *image = [UIImage imageWithData:[GameRequest getGameLogoDataWithGameID:game.gameID]];
//    if (image) {
//        cell.gameLogo.image = image;
//    } else {
//        [cell.gameLogo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGEURL,game.logoUrl]] placeholderImage:[UIImage imageNamed:@"image_downloading"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            [GameRequest saveGameLogoData:image WithGameID:game.gameID];
//        }];
//    }
    
    return cell;
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

/** gameDetail */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    
    [ControllerManager shareManager].detailView.gameID = self.showArray[indexPath.row][@"id"];
    
    SearchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [ControllerManager shareManager].detailView.gameLogo = cell.gameLogo.image;
    
    [self.navigationController pushViewController:[ControllerManager shareManager].detailView animated:YES];
    self.parentViewController.hidesBottomBarWhenPushed = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_showArray && _showArray.count != 0) {
        return kSCREEN_WIDTH * 0.218 + 4;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_WIDTH * 0.218 + 10)];
    view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [view addSubview:self.collectionView];
    return view;
}


#pragma mark - downloadGame
/** cell的代理  */
- (void)didSelectCellRowAtIndexpath:(NSDictionary *)dict {
    NSString *isLocal = dict[@"isLocal"];
    if ([isLocal isEqualToString:@"1"]) {
        [AppModel openAPPWithIde:dict[@"ios_pack"]];
        
    } else {
        NSString *url = dict[@"ios_url"];
        
        [GameRequest downLoadAppWithURL:url];
    }
}

#pragma mark - rollingDeleagte
/** 点击轮播图 */
- (void)RecommentTableHeader:(RecommentTableHeader *)header didSelectImageWithInfo:(NSDictionary *)info {
    NSString *type = info[@"type"];
    if (type.integerValue == 1) {
        self.parentViewController.hidesBottomBarWhenPushed = YES;
        [ControllerManager shareManager].detailView.gameID = info[@"gid"];
        [ControllerManager shareManager].detailView.gameLogo = nil;
        [self.navigationController pushViewController:[ControllerManager shareManager].detailView animated:YES];
        self.parentViewController.hidesBottomBarWhenPushed = NO;
    } else {

        self.parentViewController.hidesBottomBarWhenPushed = YES;
        [ControllerManager shareManager].webController.webURL = info[@"url"];
        [self.navigationController pushViewController:[ControllerManager shareManager].webController animated:YES];
        self.parentViewController.hidesBottomBarWhenPushed = NO;
    }
}

#pragma mark - collection deleegate And dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _collectionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RCCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RCSELECT" forIndexPath:indexPath];
    
    cell.titleLabel.text = _collectionArray[indexPath.item];
    
    cell.titleImage.image = [UIImage imageNamed:_collectionImage[indexPath.item]];
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:self.childControllers[indexPath.item] animated:YES];
    self.parentViewController.hidesBottomBarWhenPushed = NO;
}


#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT - 158) style:(UITableViewStylePlain)];
        
        
        [_tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:CELLIDENTIFIER];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.backgroundColor = [UIColor whiteColor];
        
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
        
        //上拉刷新
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        _tableView.tableHeaderView = self.rollHeader;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


/** 滚动轮播图 */
- (RecommentTableHeader *)rollHeader {
    if (!_rollHeader) {
        _rollHeader = [[RecommentTableHeader alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_WIDTH * 0.4)];
        _rollHeader.RecommentTableHeaderDelegate = self;
    }
    return _rollHeader;
}

/** tableview的头部视图 */
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_WIDTH * 0.618)];
        
        _headerView.backgroundColor = [UIColor lightGrayColor];
        //添加滚动轮播图
        [_headerView addSubview:self.rollHeader];
        
        [_headerView addSubview:self.collectionView];
    }
    return _headerView;
}

/** 中间4个按钮 */
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(kSCREEN_WIDTH / 4, kSCREEN_WIDTH * 0.218 - 2);
        
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, kSCREEN_WIDTH, kSCREEN_WIDTH * 0.218) collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[RCCCollectionViewCell class] forCellWithReuseIdentifier:@"RCSELECT"];
        
//        _collectionView.backgroundColor = RGBCOLOR(247, 247, 247);
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

/** 新服视图 */
- (NewServerController *)rNewServerController {
    if (!_rNewServerController) {
        _rNewServerController = [NewServerController new];
    }
    return _rNewServerController;
}

/** 活动视图 */
- (ActivityController *)rActivityController {
    if (!_rActivityController) {
        _rActivityController = [ActivityController new];
    }
    return _rActivityController;
}


/** 礼包视图 */
- (RGiftBagController *)rGiftBagController {
    if (!_rGiftBagController) {
        _rGiftBagController = [RGiftBagController new];
    }
    return _rGiftBagController;
}

/** 攻略视图 */
- (StrategyController *)rStrategyController {
    if (!_rStrategyController) {
        _rStrategyController = [StrategyController new];
    }
    return _rStrategyController;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end










