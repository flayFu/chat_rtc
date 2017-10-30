//
//  UIButton+UI.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/12.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "UIButton+UI.h"
#import "UIImage+Resource.h"
#import "Masonry.h"

#define JSZUserMediaSize CGSizeMake(32, 32)

@implementation UIButton (UI)

- (void)turnOnUI:(BOOL)isOn useMediaType:(JSZMediaType)mediaType {
    NSString *mediaDesc = (mediaType == JSZMediaTypeVideo)?@"video":@"audio";
    NSString *onOffDesc = isOn?@"On":@"Off";
    NSString *mediaStatusDesc = [NSString stringWithFormat:@"%@%@", mediaDesc, onOffDesc];
    [self setImage:[UIImage imageResourceNamed:mediaStatusDesc] forState:UIControlStateNormal];
}

+ (UIButton *)userMediaState:(JSZUserMediaState)state {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    [btn setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = btn.frame;
    frame.size = JSZUserMediaSize;
    btn.frame = frame;
    
    switch (state) {
        case JSZUserMediaStatePrivateInfo:
        {
            [btn setTitle:@"私" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:18];
            [btn setBackgroundColor:[UIColor redColor]];
        }
            break;
        case JSZUserMediaStateAtUser:
        {
            [btn _imageSet:@"atUser"];
        }
            break;
        case JSZUserMediaStateChatting:
        {
            [btn _imageSet:@"xunz"];
        }
            break;
        case JSZUserMediaStateAudioChat:
        {
            [btn _imageSet:@"audioChatting"];
        }
            break;
        case JSZUserMediaStateAudioChatOn:
        {
            [btn _imageSet:@"audioChattingOn"];
        }
            break;
        case JSZUserMediaStateAudioChatOff:
        {
            [btn _imageSet:@"audioChattingOff"];
        }
            break;
        case JSZUserMediaStateAudioChatForbid:
        {
            [btn _imageSet:@"audioChattingForbid"];
        }
            break;
        case JSZUserMediaStatePubChat:
        {
            [btn _imageSet:@"gongliao"];
        }
            break;
        case JSZUserMediaStatePrivateChat:
        {
            [btn _imageSet:@"siliao"];
        }
            break;
        case JSZUserMediaStateMicOn:
        {
            [btn _imageSet:@"shangmai"];
        }
            break;
        case JSZUserMediaStateMicOff:
        {
            [btn _imageSet:@"xiamai"];
        }
            break;
        case JSZUserMediaStateForbiddenMic:
        {
            [btn _imageSet:@"jinmai"];
        }
            break;
        case JSZUserMediaStateInvite:
        {
            [btn _imageSet:@"invite"];
        }
            break;
        default:
            break;
    }
    
//    [btn addTarget:<#(nullable id)#> action:<#(nonnull SEL)#> forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)addLayoutAtIndex:(NSUInteger)index from:(UIView *)superView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat trailing = 5 + (16 + 32) * index;
        make.top.mas_equalTo(superView.mas_top).with.offset(24);
        make.trailing.mas_equalTo(superView.mas_trailing).with.offset(-trailing);
    }];
}

// MARK:- helper method

- (void)_imageSet:(NSString *)btnImageName {
    [self setImage:[UIImage imageResourceNamed:btnImageName size:JSZUserMediaSize] forState:UIControlStateNormal];
}

@end
