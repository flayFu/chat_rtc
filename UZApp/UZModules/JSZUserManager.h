//
//  JSZUserManager.h
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSZUserManager : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic, assign)NSUInteger allVideos;//已经显示的视频数
@property(nonatomic, strong)NSMutableArray *onMicVideo;
@property(nonatomic, strong)NSMutableArray *miclist;
@property(nonatomic, strong)NSMutableArray *userList;
@property(nonatomic, copy)NSString *adminId;
@property(nonatomic, copy)NSString *selfId;
@property(nonatomic, copy)NSString *selfName;
///所有已经登入的用户,除了房主
@property(nonatomic, strong)NSMutableArray *allUsers;
@property(nonatomic, strong)NSMutableArray *atUsers;
- (void)removeUser:(NSString *)userId;
@property(nonatomic, assign)BOOL forbided;

+ (void)resetUserManager;

@property(nonatomic, strong) NSMutableArray *UserAndAdmin;

@end
