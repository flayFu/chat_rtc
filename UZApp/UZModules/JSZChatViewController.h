//
//  JSZChatViewController.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARDAppClient.h"

// 聊天列表

@interface JSZChatViewController : UITableViewController

@property (strong, nonatomic) SRWebSocket *webSocket;

@end
