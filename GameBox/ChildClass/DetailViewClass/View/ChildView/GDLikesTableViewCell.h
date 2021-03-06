//
//  GDLikesTableViewCell.h
//  GameBox
//
//  Created by 石燚 on 2017/5/4.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDLikesTableViewCell;

@protocol GDLikesTableViewCellDelegate <NSObject>

- (void)GDLikesTableViewCell:(GDLikesTableViewCell *)cell clickGame:(NSDictionary *)dict;

@end

@interface GDLikesTableViewCell : UITableViewCell

/** 游戏信息 */
@property (nonatomic, strong) NSArray *array;

@property (nonatomic, weak) id<GDLikesTableViewCellDelegate> delegate;

@end
