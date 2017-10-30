//
//  JSZUserController.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZUserController.h"
#import "JSZUser.h"
#import "JSZUserManager.h"
#import "JSZUserCell.h"

#import "AlertHelper.h"
#import "Macros.h"
#import "UIButton+UI.h"

@interface JSZUserController ()
@property(nonatomic, strong) UILabel *cellUserLb;
@end

@implementation JSZUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldReload) name:@"someonlogin" object:@"logIn"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldReload) name:@"all" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)shouldReload{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [JSZUserManager sharedInstance].userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JSZUserCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"JSZUserCell" owner:self options:nil] firstObject];
    JSZUser *user = [JSZUserManager sharedInstance].userList[indexPath.row];
    
    cell.userId.text = user.userName;
    [self addActionButtons:cell row:indexPath.row];
    UILabel *cellUserLb = cell.userId;
    cellUserLb.tag = 10000+indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)addActionButtons:(UITableViewCell *)cell row:(NSInteger)row {
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }

    NSUInteger actionButtonIndex = 0;
    
    JSZUser *user = [JSZUserManager sharedInstance].userList[row];
    
    if ([self currentUserIsAdmin]) { // 房主
        {
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateForbiddenMic];
            button.tag = 100+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
        }
        
        actionButtonIndex++;
        
        {
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateAtUser];
            button.tag = 1000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            
            [button addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        if ([self currentUserIsSelf:user.userId]) {
            {
                UIButton *button = [UIButton userMediaState:JSZUserMediaStatePrivateChat];
                button.tag = 100+row;
                [cell.contentView addSubview:button];
                [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
                
                [button addTarget:self action:@selector(priMicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            
//            actionButtonIndex++;
//            
//            {
//                UIButton *button = [UIButton userMediaState:JSZUserMediaStatePubChat];
//                button.tag = 1000+row;
//                [cell.contentView addSubview:button];
//                [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
//                
//                [button addTarget:self action:@selector(pubMicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            }
//            
//            actionButtonIndex++;
//            
//            {
//                UIButton *button = [UIButton userMediaState:JSZUserMediaStateAudioChat];
//                button.tag = 1000+row;
//                [cell.contentView addSubview:button];
//                [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
//            }
        } else {
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateAtUser];
            button.tag = 1000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            
            [button addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

// MARK:- action helper

- (BOOL)currentUserIsAdmin {
    return [[JSZUserManager sharedInstance].adminId isEqualToString:[JSZUserManager sharedInstance].selfId];
}
- (BOOL)currentUserIsSelf:(NSString *)userId {
    return [userId isEqualToString:[JSZUserManager sharedInstance].selfId];
}

- (void)pubMicBtnClick:(UIButton *)sender
{
    NSUInteger indexPath = sender.tag - 1000;
    UILabel *cellUserLb = (UILabel *)[self.view viewWithTag:(indexPath+10000)];
    if ([JSZUserManager sharedInstance].allVideos >= MAX_VIDEO_COUNT || [JSZUserManager sharedInstance].forbided) {
        
        [AlertHelper alertWithText:@"上麦人数已达上限" target:self];
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pubMicOn" object:@"gxpusercell" userInfo:@{@"userId":cellUserLb}];
    }
    
    
}

- (void)priMicBtnClick:(UIButton *)sender
{
    NSUInteger indexPath = sender.tag - 100;
    UILabel *cellUserLb = (UILabel *)[self.view viewWithTag:indexPath+10000];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privatePubMicOn" object:@"gxpusercell" userInfo:@{@"userId":cellUserLb}];
    
}
// @ 聊天
- (void)atAction:(UIButton *)btn;
{
    NSInteger indexRow = btn.tag-1000;
    JSZUser *user = [JSZUserManager sharedInstance].userList[indexRow];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"atAction" object:self userInfo:@{@"user" : user}];
}

@end
