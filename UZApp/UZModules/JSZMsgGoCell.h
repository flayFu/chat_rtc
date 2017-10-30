//
//  JSZMsgGoCell.h
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSZMsg.h"

@interface JSZMsgGoCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headImageView; //用户头像
@property (nonatomic,strong) UIImageView *backView; // 气泡
@property (nonatomic, strong)UILabel *msgLabel;

- (void)refreshCell:(JSZMsg *)msg;

@property(nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *userId; // 用户

@end
