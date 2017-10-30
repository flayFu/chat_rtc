//
//  JSZMicListCell.m
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZMicListCell.h"
#import "UIImage+Resource.h"

@interface JSZMicListCell ()

@end
@implementation JSZMicListCell

+ (instancetype)micCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *classname = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:classname bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:classname];
    return [tableView dequeueReusableCellWithIdentifier:classname];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.image = [UIImage imageResourceNamed:@"head.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
