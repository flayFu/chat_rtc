//
//  JSZUserManager.m
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZUserManager.h"
#import "JSZUser.h"

@implementation JSZUserManager

static JSZUserManager* _instance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.userList = [NSMutableArray new];
        _instance.miclist = [NSMutableArray new];
        _instance.onMicVideo = [NSMutableArray new];
    });
    return _instance;
}

+ (void)resetUserManager {
    [JSZUserManager sharedInstance].allVideos = 0;
    [JSZUserManager sharedInstance].userList = [@[] mutableCopy];
    [JSZUserManager sharedInstance].miclist = [@[] mutableCopy];
    [JSZUserManager sharedInstance].onMicVideo = [@[] mutableCopy];
}

- (void)setAllVideos:(NSUInteger)allVideos{
    _allVideos = allVideos;
    NSLog(@"现在共有 %lu 个视频显示",(unsigned long)_allVideos);
}
- (void)removeUser:(NSString *)userId{
    [_userList enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userId]) {
            [_userList removeObject:obj];
        }
    }];
    
    [_miclist enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userId]) {
            [_miclist removeObject:obj];
        }
    }];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"all" object:self];
}

- (NSMutableArray *)allUsers{
    NSMutableArray *array = [self atUsers];
    
    for (NSUInteger i = 0; i < array.count; i++) {
        JSZUser *obj = array[i];
        if ([obj.userId isEqualToString:_adminId]) {
            NSLog(@"删除房主");
            [array removeObject:obj];
            break;
        }
        
    }
    
    NSLog(@"当前登陆的所有人 after %@",array);
    return array;
}

- (NSMutableArray *)atUsers{
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:_userList];
    [array addObjectsFromArray:_miclist];
    NSLog(@"当前登陆的所有人 before %@",array);
    
    for (NSUInteger i = 0; i < array.count; i++) {
        JSZUser *obj = array[i];
        
        if ([obj.userId isEqualToString:[JSZUserManager sharedInstance].selfId]) {
            NSLog(@"删除自己");
            [array removeObject:obj];
            break;
        }
        
    }
    
    return array;
}

- (NSMutableArray *)UserAndAdmin {
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:_userList];
    [array addObjectsFromArray:_miclist];
    NSLog(@"当前登陆的所有人 before %@",array);
    
    return array;
    
}

@end
