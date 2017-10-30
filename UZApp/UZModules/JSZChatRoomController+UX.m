//
//  JSZChatRoomController+UX.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/8.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZChatRoomController+UX.h"

#import "AlertHelper.h"
#import "UIViewController+BackButtonHandler.h"
#import "JSZMsgProducer.h"
#import "JSZUserManager.h"
#import "JSZChatRoomView.h"
#import "UIImage+Resource.h"

@implementation JSZChatRoomController (UX)

// MARK: - 界面基本设定

/**
 * 导航相关设置
 */
- (void)navBarSetting {
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = @"会议室";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:38.0/255.0 green:192.0/255.0 blue:136.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil, nil]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageResourceNamed:@"icon_back" size:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button addTarget:self action:@selector(navigationShouldPopOnBackButton) forControlEvents:UIControlEventTouchUpInside];
    // 让按钮内部的所有内容左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;  //偏移距离  -向左偏移, +向右偏移
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:button]];
    
   
    
}

// MARK: BackButtonHandlerProtocol

/**
 * 返回按钮确认处理
 */
- (BOOL)navigationShouldPopOnBackButton {
    [self _backAction:nil];
    
    return NO;
}
/**
 * 添加右滑返回手势
 */
- (void)addBackGestureRecognizer {
    UISwipeGestureRecognizer *backGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_backAction:)];
    backGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:backGestureRecognizer];
}
/**
 * 右滑返回确认
 */
- (void)_backAction:(UIGestureRecognizer *)sender {
    [AlertHelper alertWithText:@"确认要退出会议室吗？" target:self nextHandler:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
