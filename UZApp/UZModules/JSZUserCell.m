//
//  JSZUserCell.m
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZUserCell.h"
#import "JSZUserManager.h"
#import "AlertHelper.h"
#import "JSZUserController.h"
#import "Macros.h"
#import "UIImage+Resource.h"

@implementation JSZUserCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    [super removeFromSuperview];
    self.headImageView.image = [UIImage imageResourceNamed:@"head.png"];

    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
