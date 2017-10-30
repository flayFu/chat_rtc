//
//  JSZChatRoomView.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZChatRoomView.h"

#import "RTCEAGLVideoView.h"
#import "RTCVideoTrack.h"

#import "Masonry.h"
#import "UIImage+Resource.h"

#import "JSZMicListController.h"
#import "JSZUserController.h"
#import "JSZChatViewController.h"
#import "UIButton+UI.h"


#import "JSZMsgManager.h"
#import "JSZUserManager.h"




@implementation JSZChatRoomView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_pageMenu) {
        return;
    }
    
    [self.remoteView setDelegate:self];
    [self.localView setDelegate:self];
    
    self.backgroundColor = [UIColor whiteColor];
    
    

    
    //page menu
    _vc1 = [[JSZMicListController alloc] initWithStyle:UITableViewStylePlain];
    _vc1.title = @"麦序列表";
    _vc2 =[[JSZUserController alloc] initWithStyle:UITableViewStylePlain];
    _vc2.title = @"用户列表";
    _chatVc = [[JSZChatViewController alloc] initWithStyle:UITableViewStylePlain];
    _chatVc.title = @"聊天列表";
    
    NSArray *controllerArray = @[_vc1,_vc2,_chatVc];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor:[UIColor colorWithRed:38.0/255.0 green:194.0/255.0 blue:137.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor blackColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithRed:38.0/255.0 green:194.0/255.0 blue:137.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                    };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, CGRectGetMaxY(self.remoteView.frame), self.frame.size.width, self.frame.size.height) options:parameters];
    _pageMenu.delegate = self;
    _pageMenu.view.backgroundColor = [UIColor clearColor];
    [self addSubview:_pageMenu.view];
    
    [_pageMenu.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_remoteView.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).with.offset(-85);
    }];
    

    

    
    _inputView = [[InputView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-85, [UIScreen mainScreen].bounds.size.width, 85)];
    [self addSubview:_inputView];
    [_inputView.startVideo addTarget:self action:@selector(hangupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _inputView.placeholderLabel.text = @"请输入...";
    _inputView.textViewMaxLine = 4;

    
    [self.remoteView addSubview:self.localView];
}
/**
    点击开启视频
 */
- (void)hangupButtonPressed:(id)sender
{   
    UIButton *hangup = sender;
    JSZChatRoomView *room = [[JSZChatRoomView alloc] init];
    [self.delegate chatRoomHangupButtonPressed:hangup from:room];
    
}
/**
 * 聊天发送视图
 */
- (void)sendTextView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 30)];
    view.backgroundColor = [UIColor cyanColor];
    UITextField *inputTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame) - 50, 30)];
    inputTf.backgroundColor = [UIColor redColor];
    [view addSubview:inputTf];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(CGRectGetWidth(inputTf.frame), 0, 50, 30);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:sendBtn];
    [self addSubview:view];
}

- (void)sendText{
//    [self.client sendText];
    
}




- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size
{
    
}


@end
