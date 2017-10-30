//
//  JSZChatViewController.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZChatViewController.h"
#import "JSZMsgManager.h"
#import "JSZUserManager.h"
#import "JSZMsgProducer.h"
#import "InputView.h"
#import "JSZMsgComeCell.h"
#import "JSZMsgGoCell.h"
#import "JSZUser.h"
#import "JSZMsg.h"
#import "NSString+Time.h"
#import "AlertHelper.h"
@interface JSZChatViewController ()<UITextViewDelegate, InputViewDelegate>
{
    UITableView *_users;
    InputView *_inputView;
}

@end

static NSString *identify = @"JSZChatTableViewGoCell";
static NSString *reuse = @"JSZMsgComeCell";
@implementation JSZChatViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initTable];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"JSZChatviewControllertableView" object:nil];

}


- (void)reloadTableView
{
    [self.tableView reloadData];
    // 滚到底部
    if ([JSZMsgManager sharedInstance].msgs.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[JSZMsgManager sharedInstance].msgs.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
    [self.tableView reloadData];
}

- (void)initTable{
    [self.tableView registerClass:[JSZMsgGoCell class] forCellReuseIdentifier:identify];
    [self.tableView registerClass:[JSZMsgComeCell class] forCellReuseIdentifier:reuse];
    
}






- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1) {
        return  [JSZUserManager sharedInstance].allUsers.count;
    }
    return [JSZMsgManager sharedInstance].msgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        UITableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"user"];
        if (!userCell) {
            userCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user"];
        }
        JSZUser *user = [JSZUserManager sharedInstance].allUsers[indexPath.row];
        userCell.textLabel.text = user.userName;
        return userCell;
    }

    
    JSZMsg *msg = [JSZMsgManager sharedInstance].msgs[indexPath.row];
    if (msg.isCome) {
       
        JSZMsgComeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
        [cell refreshCell:msg];
        cell.timeLabel.text = [NSString time];
        /**
         *  显示用户ID
         */
        cell.userId.text = msg.sender_NAME;

        return cell;

    }else{
        
        JSZMsgGoCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        [cell refreshCell:msg];
        cell.timeLabel.text = [NSString time];
        
        cell.userId.text = [JSZUserManager sharedInstance].selfId;
       

        return cell;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JSZMsg *msg = [JSZMsgManager sharedInstance].msgs[indexPath.row];
    CGRect rec = [msg.msg boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    return rec.size.height + 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 1) {
        JSZUser *user = [JSZUserManager sharedInstance].allUsers[indexPath.row];
        _inputView.sendToId = user.userId;
        [_users removeFromSuperview];
    }
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JSZChatviewControllertableView" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
