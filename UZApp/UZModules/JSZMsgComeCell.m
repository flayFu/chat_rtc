//
//  JSZMsgComeCell.m
//  UZApp
//
//  Created by bin wu on 2017/7/20.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZMsgComeCell.h"
#import "UIImage+Resource.h"
#define WIDTH [[UIScreen mainScreen] bounds].size.width
@implementation JSZMsgComeCell

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
        self.userId.font = [UIFont systemFontOfSize:11.0f];
        [self.contentView addSubview:self.userId];
        self.userId.textAlignment = NSTextAlignmentLeft;
        
    }
    return self;
}



- (void)refreshCell:(JSZMsg *)msg
{
    NSArray *arr = [msg.msg componentsSeparatedByString:@"</p>"];
    
    msg.msg = arr[0];
    
    
    
    if ([msg.msg containsString:@"@"]) {
        NSInteger begin = [msg.msg rangeOfString:@"@"].location;
        NSInteger length = [msg.msg rangeOfString:@":"].location-begin+1;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:msg.msg];

        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(begin, length)];
        self.msgLabel.attributedText = attrStr;
    }else if ([msg.msg containsString:@"悄悄对_"]) {
        NSInteger begin = [msg.msg rangeOfString:@"悄悄对_"].location;
        NSInteger length = [msg.msg rangeOfString:@"_说:"].location-begin+1+2;
//        NSLog(@"`````####`````%ld", length);

        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:msg.msg];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(begin, length)];
        self.msgLabel.attributedText = attrStr;
    } else {
        self.msgLabel.text = msg.msg;

    }
    
    
    // 首先计算文本宽度和高度
    CGRect rec = [msg.msg boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil];
    
    // 气泡
    UIImage *image = nil;
    // 头像
    UIImage *headImage = nil;
    
    // 当输入只有一个行的时候高度就是20多一点
    self.headImageView.frame = CGRectMake(5, rec.size.height - 18, 50, 50);
    self.userId.frame = CGRectMake(60, 10, 38, 20);
    self.backView.frame = CGRectMake(98, 10, rec.size.width + 20, rec.size.height + 20);
    image = [UIImage imageResourceNamed:@"come.png"];
    headImage = [UIImage imageResourceNamed:@"head.png"];
    
    
    // 拉伸图片 参数1 代表从左侧到指定像素禁止拉伸，该像素之后拉伸，参数2 代表从上面到指定像素禁止拉伸，该像素以下就拉伸
    image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    self.backView.image = image;
//    self.backView.backgroundColor = [UIColor redColor];
    self.headImageView.image = headImage;
    
    // 文本内容的frame
    self.msgLabel.frame = CGRectMake(12, 5, rec.size.width, rec.size.height);

    

    self.timeLabel.frame = CGRectMake(WIDTH/2-70, 0, 140, 10);
    

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
