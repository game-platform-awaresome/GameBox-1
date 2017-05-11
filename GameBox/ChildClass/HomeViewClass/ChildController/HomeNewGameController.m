//
//  HomeNewGameController.m
//  GameBox
//
//  Created by 石燚 on 2017/4/20.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "HomeNewGameController.h"
#import "SearchCell.h"

//#import "GameModel.h"
#import "GameRequest.h"
#import "ControllerManager.h"

#import "MJRefresh.h"
#import <UIImageView+WebCache.h>

#define CELLIDENTIFIER @"SearchCell"

@interface HomeNewGameController ()<UITableViewDelegate,UITableViewDataSource,SearchCellDelelgate>

@property (nonatomic, strong) UITableView *tableView;

/**< 数据 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**时间数组*/
@property (nonatomic, strong) NSArray<NSString *> * timeArray;

/**游戏数组*/
@property (nonatomic, strong) NSMutableDictionary * dataDictionary;

/**< 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;

/**< 是否加载了全部 */
@property (nonatomic, assign) BOOL isAll;

@end

@implementation HomeNewGameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initDataSource];
    [self initUserInterface];
}

- (void)initDataSource {
    [self.tableView.mj_header beginRefreshing];
}

- (void)initUserInterface {
    _isAll = NO;
    [self.view addSubview:self.tableView];
}

#pragma markr - method
- (void)refreshData {
    [GameRequest newGameWithPage:@"1" Completion:^(NSDictionary * _Nullable content, BOOL success) {
        if (success && !((NSString *)content[@"status"]).boolValue) {
            _dataArray = [content[@"data"] mutableCopy];
            [self clearUpData:_dataArray];
            _currentPage = 1;
            _isAll = NO;
        
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];

    }];
}

- (void)loadMoreData {
    if (_isAll) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        _currentPage++;
        
        [GameRequest newGameWithPage:[NSString stringWithFormat:@"%ld",_currentPage] Completion:^(NSDictionary * _Nullable content, BOOL success) {
            if (success && !((NSString *)content[@"status"]).boolValue) {
                NSArray *array = content[@"data"];
                if (array.count == 0) {
                    _isAll = YES;
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [_dataArray addObjectsFromArray:array];
                    [self clearUpData:_dataArray];
                    [self.tableView reloadData];
                    [self.tableView.mj_footer endRefreshing];
                }
            }
        }];
    }
}

- (NSMutableArray *)clearUpData:(NSArray *)array {
    
    NSMutableSet *set = [NSMutableSet set];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *timeStr = obj[@"addtime"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStr.integerValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-dd";
        timeStr = [formatter stringFromDate:date];
        
        NSMutableArray *array = dict[timeStr];
        if (array == nil) {
            array = [NSMutableArray array];
        }
        [array addObject:obj];
        
        [dict setObject:array forKey:timeStr];
        
        [set addObject:timeStr];

    }];

    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:NO]];
    self.timeArray = [set sortedArrayUsingDescriptors:sortDesc];
    

    self.dataDictionary = [dict mutableCopy];
    
    return [array mutableCopy];
}

#pragma mark - tableviewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.timeArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataDictionary[self.timeArray[section]];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFIER];
     NSArray *array = self.dataDictionary[self.timeArray[indexPath.section]];
    
    
    [cell.gameLogo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGEURL,array[indexPath.row][@"logo"]]] placeholderImage:nil];
    
    cell.delegate = self;
    
    cell.dict = array[indexPath.row];
    
    return cell;
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 20)];
    
    label.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    label.text = [NSString stringWithFormat:@"   %@",self.timeArray[section]];
    
    return label;
}

/** cell的点击事件 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    [ControllerManager shareManager].detailView.gameID = self.dataDictionary[self.timeArray[indexPath.section]][indexPath.row][@"id"];
    SearchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [ControllerManager shareManager].detailView.gameLogo = cell.gameLogo.image;
    [self.navigationController pushViewController:[ControllerManager shareManager].detailView animated:YES];
    self.parentViewController.hidesBottomBarWhenPushed = NO;
}

#pragma mark - cellDeleagate 
- (void)didSelectCellRowAtIndexpath:(NSDictionary *)dict {
    CLog(@"下载游戏:%@",dict);
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT - 157) style:(UITableViewStylePlain)];
        
        
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

        
        _tableView.tableFooterView = [UIView new];
        
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
