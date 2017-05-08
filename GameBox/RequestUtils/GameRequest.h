//
//  GameRequest.h
//  GameBox
//
//  Created by 石燚 on 2017/5/5.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "RequestUtils.h"

#import <MJRefresh.h>
#import <UIImageView+WebCache.h>


/** 新游,热门,排行榜 */
typedef enum : NSUInteger {
    newGame = 0,
    hotGame,
    rankingGame,
} GameType;

/** 开服时间:今天,即将,已经 */
typedef enum : NSInteger {
    TodaySer = 1,
    CommingSoonSer,
    AlredaySer,
} openService;

/** 收藏类型:收藏,取消收藏 */
typedef enum : NSInteger {
    collection = 1,
    cancel,
} CollectionType;

/** 游戏名,游戏包名 */
typedef enum : NSUInteger {
    AllName,
    AllBackage,
} AllType;


@interface GameRequest : RequestUtils

/** 推荐游戏接口 */
+ (void)recommendGameWithPage:(NSString * _Nullable)page
                   Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 新游/热门/排行接口 */
+ (void)typeGameWithType:(GameType)gameType
                    Page:(NSString * _Nonnull)page
              Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 新游接口 */
+ (void)newGameWithPage:(NSString * _Nullable)page
             Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 热门接口 */
+ (void)hotGameWithPage:(NSString * _Nullable)page
              Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 排行榜 */
+ (void)rankGameWithhPage:(NSString * _Nullable)page
              Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;


//====================================================================//
/** 开服列表接口 */
+ (void)openGameServerWithType:(openService)serviceTye
                          Page:(NSString * _Nullable)page
                    Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 今日开服 */
+ (void)todayServerOpenWithPage:(NSString * _Nonnull)page
                     Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;
/** 即将开服 */
+ (void)CommingSoonServerOpenWithPage:(NSString * _Nonnull)page
                           Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 已经开服 */
+ (void)AlredayServerOpenWithPage:(NSString * _Nonnull)page
                       Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 游戏详情接口 */
+ (void)gameInfoWithGameID:(NSString * _Nonnull)gameID
                    Comoletion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 单一游戏开服接口 */
+ (void)gameServerOpenWithGameID:(NSString * _Nonnull)gameID
                      Comoletion:(void(^ _Nullable)(NSDictionary * _Nullable content, BOOL scccess))completion;

//====================================================================//
/** 游戏收藏接口 */
+ (void)gameCollectWithType:(CollectionType)collectionType
                            GameID:(NSString * _Nonnull)gameID
                        Comoletion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 游戏分类接口 */
+ (void)gameClassifyWithPage:(NSString *_Nullable)page
                  Comoletion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 游戏单一分类接口 */
+ (void)ClassifyWithID:(NSString * _Nonnull)classifyID
                  Page:(NSString * _Nonnull)page
            Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;


//====================================================================//
/** 所有游戏接口 */
+ (void)allGameWithType:(AllType)type
             Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 搜索游戏热门接口 */
+ (void)searchHotGameCompletion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 搜索游戏接口 */
+ (void)searchGameWithKeyword:(NSString * _Nonnull)keyword
                   Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 游戏更新接口 */
+ (void)gameUpdateWithIDs:(NSString * _Nonnull)ids
               Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;


//====================================================================//
/** 子渠道下载接口 */
+ (void)downLoadGameWithTag:(NSString * _Nonnull)tag
                  ChannelID:(NSString * _Nonnull)channelID
                 Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 我的收藏接口 */
+ (void)myCollectionGameWithPage:(NSString *_Nonnull)page
                      Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

//====================================================================//
/** 游戏安装通知接口 */
+ (void)gameInstallWithGameID:(NSString *_Nonnull)gameID
                     gamePack:(NSString *_Nonnull)gamePackName
                  gameVersion:(NSString *_Nonnull)gameVersion
                   Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 游戏卸载通知接口 */
+ (void)gameUninstallWithGamePackName:(NSString * _Nonnull)gamePackName
                           Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 游戏打分接口 */
+ (void)gameGradeWithSorce:(NSString *_Nonnull)sorce
                    GameID:(NSString *_Nonnull)gameID
                    UserID:(NSString *_Nonnull)uid
                Completion:(void(^_Nullable)(NSDictionary * _Nullable content, BOOL success))completion;

/** 显示提示信息 */
+ (void)showAlertWithMessage:(NSString *_Nullable)message dismiss:(void(^_Nullable)(void))dismiss;


@end













