//
//  JSZUserController.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
// 用户列表
@interface JSZUserController : UITableViewController

@property(nonatomic, strong)NSMutableArray *users;
@property(nonatomic, copy)NSString *selfUserId;
@end
