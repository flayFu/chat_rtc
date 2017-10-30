//
//  JSZMicListCell.h
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSZMicListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;

//@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;
//@property (strong, nonatomic) IBOutlet UIButton *forbidOnMic;
@property (strong, nonatomic) IBOutlet UILabel *userId;

+ (instancetype)micCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
