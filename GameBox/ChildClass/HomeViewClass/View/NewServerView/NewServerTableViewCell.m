//
//  NewServerTableViewCell.m
//  GameBox
//
//  Created by 石燚 on 2017/4/14.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "NewServerTableViewCell.h"
#import "GameRequest.h"

@interface NewServerTableViewCell ()

/** 游戏名称标签 */
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;

/** 游戏开始标签 */
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

/** 提醒按钮 */
@property (weak, nonatomic) IBOutlet UIButton *remindButton;

@end

@implementation NewServerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.gameNameLabel.font = [UIFont systemFontOfSize:13];
    self.startTimeLabel.font = [UIFont systemFontOfSize:13];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)respondsToremindButtn:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"提醒"]) {
        
        NSString *time = _dict[@"start_time"];
        NSString *detail = [NSString stringWithFormat:@"%@ - %@服 即将开启",_dict[@"gamename"],_dict[@"server_id"]];
        
        NSMutableDictionary *dict = [_dict mutableCopy];
        
        [dict setObject:@"1" forKey:@"isRemind"];
        
        self.dict = dict;
        
        [GameRequest registerNotificationWith:[NSDate dateWithTimeIntervalSince1970:(time.integerValue - 300)] Title:_dict[@"gamename"] Detail:detail Identifier:[NSString stringWithFormat:@"%@%@", _dict[@"game"],_dict[@"start_time"]] GameDict:dict];


    } else {
        
    }
}

#pragma mark - setter
- (void)setDict:(NSDictionary *)dict {
    if (_dict != dict) {
        _dict = dict;
    }

    
    NSArray *notificationArray = [GameRequest notificationRecord];
    
    for (NSDictionary *notification in notificationArray) {
        if ([notification[@"gamename"] isEqualToString:dict[@"gamename"]] && [notification[@"server_id"] isEqualToString:dict[@"server_id"]]) {
            NSMutableDictionary *dNoti = [dict mutableCopy];
            [dNoti setObject:@"1" forKey:@"isRemind"];
            _dict = dNoti;
            break;
        }
    }
    
    //设置游戏名
    self.gameNameLabel.text = [NSString stringWithFormat:@"%@ - %@服",_dict[@"gamename"],_dict[@"server_id"]];
    
    //设置开服时间
    NSString *timeStr = _dict[@"start_time"];
    NSDate *starDate = [NSDate dateWithTimeIntervalSince1970:timeStr.integerValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm";
    
    timeStr = [formatter stringFromDate:starDate];
    self.startTimeLabel.text = [NSString stringWithFormat:@"开服时间: %@",timeStr];
    
    //设置按钮
    if ([[NSDate date] timeIntervalSinceDate:starDate] < 0.0f) {
        if ([_dict[@"isRemind"] isEqualToString:@"1"]) {
            [self.remindButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [self.remindButton setTitle:@"已添加" forState:(UIControlStateNormal)];
            [self.remindButton setBackgroundImage:[UIImage imageNamed:@"downLoadButton"] forState:(UIControlStateNormal)];
            [self.remindButton removeTarget:self action:@selector(respondsToremindButtn:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.remindButton setBackgroundImage:[UIImage imageNamed:@"button_circle"] forState:(UIControlStateNormal)];
            [self.remindButton setTitle:@"提醒" forState:(UIControlStateNormal)];
            [self.remindButton setTitleColor:[UIColor orangeColor] forState:(UIControlStateNormal)];
            [self.remindButton addTarget:self action:@selector(respondsToremindButtn:) forControlEvents:(UIControlEventTouchUpInside)];
        }
        [self.remindButton setBackgroundColor:[UIColor whiteColor]];
    } else {
        [self.remindButton setBackgroundImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [self.remindButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.remindButton setTitle:@"已开服" forState:(UIControlStateNormal)];
        [self.remindButton setTitleColor:[UIColor darkGrayColor] forState:(UIControlStateNormal)];
    }
}




@end









