//
//  JSZMsgGoCell.m
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZMsgGoCell.h"
#import "UIImage+Resource.h"
#define WIDTH [[UIScreen mainScreen] bounds].size.width
@implementation JSZMsgGoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.headImageView = [[UIImageView alloc] init];
        self.headImageView.layer.cornerRadius = 25.0f;
        self.headImageView.layer.borderWidth = 1.0f;
        self.headImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        
        self.backView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.backView];
        
        self.msgLabel = [[UILabel alloc] init];
        self.msgLabel.numberOfLines = 0;
//        self.msgLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.backView addSubview:self.msgLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:10.f];
        [self.contentView addSubview:self.timeLabel];
        
        self.userId = [[UILabel alloc] init];
        [self.contentView addSubview:self.userId];
        self.userId.font = [UIFont systemFontOfSize:11.f];
        self.userId.textAlignment = NSTextAlignmentRight;
        
    }
    return self;
}

- (void)refreshCell:(JSZMsg *)msg
{
    if ([msg.msg containsString:@"@"]) {
        NSInteger begin = [msg.msg rangeOfString:@"@"].location;
        NSInteger length = [msg.msg rangeOfString:@":"].location-begin+1;

        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:msg.msg];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(begin, length)];
        self.msgLabel.attributedText = attrStr;
    }else if ([msg.msg containsString:@"悄悄对_"]) {
        NSLog(@"``````4$$$$$`````%@", msg.msg);
        NSUInteger begin = [msg.msg rangeOfString:@"悄悄对_"].location;
     
        NSInteger length = [msg.msg rangeOfString:@":"].location-begin+1;
        NSLog(@"`````111111`````%@", @(length));
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:msg.msg];
        

        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(begin, length)];
        self.msgLabel.attributedText = attrStr;
    } else {
        self.msgLabel.text = msg.msg;
        
    }
    
    
    // 首先计算文本宽度和高度
    CGRect rec = [msg.msg boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    
    // 气泡
    UIImage *image = nil;
    // 头像
    UIImage *headImage = nil;
    
    
    self.headImageView.frame = CGRectMake(WIDTH - 55, rec.size.height - 18, 50, 50);
    self.backView.frame = CGRectMake(WIDTH - 55 - rec.size.width - 20 - 38, 10, rec.size.width + 20, rec.size.height + 20);
    image = [UIImage imageResourceNamed:@"go.png"];
    headImage= [UIImage imageResourceNamed:@"head.png"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    
    self.backView.image = image;
    self.headImageView.image = headImage;
    // 文本内容的frame
    self.msgLabel.frame = CGRectMake(5, 5, rec.size.width, rec.size.height);

    
    self.timeLabel.frame = CGRectMake(WIDTH/2-70, 0, 140, 10);
    
    
    self.userId.frame = CGRectMake(WIDTH - 55 - 38, rec.size.height - 18, 38, 20);
    

    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
