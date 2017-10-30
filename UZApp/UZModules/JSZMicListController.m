//
//  JSZMicListController.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZMicListController.h"
#import "JSZUserManager.h"
#import "JSZUser.h"
#import "JSZMicListCell.h"
#import "UIButton+UI.h"
#import "Macros.h"
#import "AlertHelper.h"
#import "NSUserDefaults+Save.h"

@interface JSZMicListController ()

@end

@implementation JSZMicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTable];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSLog(@"add no--------");

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldReload) name:@"miclist" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldReload) name:@"all" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)initTable
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}
- (void)shouldReload{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [JSZUserManager sharedInstance].miclist.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


   
    static NSString *jszMicListCell = @"jszMicListCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([JSZMicListCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:jszMicListCell];
        nibsRegistered = YES;
    }
    
    JSZMicListCell *cell = [tableView dequeueReusableCellWithIdentifier:jszMicListCell];
    
    JSZUser *user = [JSZUserManager sharedInstance].miclist[indexPath.row];
    
    cell.userId.text = user.userName;
    [self addActionButtons:cell row:indexPath.row];
    
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
    
    JSZUser *user = [JSZUserManager sharedInstance].miclist[row];
    // 麦序列表
    if ([[JSZUserManager sharedInstance].adminId isEqualToString:user.userId]) {// 房主麦序
        if (![self currentUserIsAdmin]) { // 用户看房主图标
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateAtUser];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            [button addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        // 房主看房主始终无图标
    } else { // 用户麦序
        /*
         *      - 房主邀请尚未同意的麦序
         *      - 房主禁麦
         *      - 非自己可 @
         *      - 私聊显示
         *      - 自己可下麦
         *      - 非自己尚未同意的麦序
         *      - 正在聊天
         */
        
//        if ([self currentUserIsAdmin]) {
//            [button addTarget:self action:@selector(agreeMicOnAction:) forControlEvents:UIControlEventTouchUpInside];
//        }
        
        if ([self currentUserIsAdmin]) {
            // 房主邀请尚未同意的麦序
            if (![self agreeMicOn:user.userId]) {
                UIButton *button = [UIButton userMediaState:JSZUserMediaStateInvite];
                button.tag = 2000+row;
                [cell.contentView addSubview:button];
                [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
                [button addTarget:self action:@selector(agreeMicOnAction:) forControlEvents:UIControlEventTouchUpInside];
                
                actionButtonIndex++;
            }
            // 房主禁麦
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateForbiddenMic];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            [button addTarget:self action:@selector(forbidPubOnMic:) forControlEvents:UIControlEventTouchUpInside];
            
            actionButtonIndex++;
        }
        if (![self currentUserIsSelf:user.userId]) { // 非自己可 @
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateAtUser];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            [button addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
            
            actionButtonIndex++;
        }
        if (user.pubState == PUBSTATEPRIVATE) { // 私聊显示
            UIButton *button = [UIButton userMediaState:JSZUserMediaStatePrivateInfo];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            
            actionButtonIndex++;
        }
        if ([self currentUserIsSelf:user.userId]) {  // 自己可下麦
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateMicOff];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
            [button addTarget:self action:@selector(forbidPubOnMic:) forControlEvents:UIControlEventTouchUpInside];
            
            actionButtonIndex++;
        } else { // 非自己尚未同意的麦序
            if (![self agreeMicOn:user.userId]) {
                UIButton *button = [UIButton userMediaState:JSZUserMediaStateMicOn];
                button.tag = 2000+row;
                [cell.contentView addSubview:button];
                [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
                
                actionButtonIndex++;
                
            }
        }
         // 正在聊天
        if ([self agreeMicOn:user.userId]) {
            UIButton *button = [UIButton userMediaState:JSZUserMediaStateChatting];
            button.tag = 2000+row;
            [cell.contentView addSubview:button];
            [button addLayoutAtIndex:actionButtonIndex from:cell.contentView];
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
/**
 * 麦序列表是否同意

 @param userId 用户ID
 */
- (BOOL)agreeMicOn:(NSString *)userId {
    __block BOOL hasAgreeMicOn = NO;
    [[JSZUserManager sharedInstance].onMicVideo enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:userId]) {
            hasAgreeMicOn = YES;
        }
    }];
    
    return hasAgreeMicOn;
}

- (IBAction)agreeMicOnAction:(UIButton *)sender {
    if ([JSZUserManager sharedInstance].allVideos >= MAX_VIDEO_COUNT) {
        [AlertHelper alertWithText:@"上麦人数已达上限" target:self];
    }else{
        if (![NSUserDefaults jsz_turnOn]) {
            [AlertHelper alertWithText:@"请先开启视频" target:self];
        }
        if (sender.tag < 2000) {
            NSLog(@"error:sender.tag = %@",@(sender.tag));
            return;
        }
        JSZUser *user = [JSZUserManager sharedInstance].miclist[sender.tag - 2000];
        if ([self agreeMicOn:user.userId]) {
            NSLog(@"已经同意过了别点了");
            return;
        }
        //同意谁上麦
        [self performSelector:@selector(sendAgreeMicOn:) withObject:user afterDelay:2];
    }
    
}
//让这个用户公聊下麦
- (IBAction)forbidPubOnMic:(UIButton *)sender {
    
    NSInteger indexRow = sender.tag-2000;
    if (indexRow < 0) {
        NSLog(@"error:sender.tag = %@",@(sender.tag));
        return;
    }
    JSZUser *user = [JSZUserManager sharedInstance].miclist[indexRow];
    
    [[JSZUserManager sharedInstance].onMicVideo enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:user.userId]) {
            [[JSZUserManager sharedInstance].onMicVideo removeObject:obj];
        }
    }];

    if ([[JSZUserManager sharedInstance].selfId isEqualToString:user.userId]) {
        NSLog(@"自己下麦");
        [[JSZUserManager sharedInstance].miclist enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:user.userId]) {
                [[JSZUserManager sharedInstance].miclist removeObject:obj];
                [[JSZUserManager sharedInstance].userList addObject:obj];
            }

            [[NSNotificationCenter defaultCenter]postNotificationName:@"all" object:nil];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initiativePubDownMic" object:self userInfo:@{@"userId" : user.userId,@"userName" : user.userName, @"private" : (user.pubState == PUBSTATEPRIVATE)?@"YES":@"NO"}];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"forbidPubOnMic" object:self userInfo:@{@"userId":user.userId}];
        
    }
}

- (void)sendAgreeMicOn:(JSZUser *)user {
    [[JSZUserManager sharedInstance].onMicVideo addObject:user.userId];
    if (user.pubState == PUBSTATEPRIVATE) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"agreePrivateMicOn" object:self userInfo:@{@"userId":user.userId}];
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"agreePubMicOn" object:self userInfo:@{@"userId":user.userId}];
    }
}

// @ 聊天
- (void)atAction:(UIButton *)btn;
{
    NSInteger indexRow = btn.tag-2000;
    if (indexRow < 0) {
        NSLog(@"error:sender.tag = %@",@(btn.tag));
        return;
    }
    JSZUser *user = [JSZUserManager sharedInstance].miclist[indexRow];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"atAction" object:self userInfo:@{@"user" : user}];
}

@end
