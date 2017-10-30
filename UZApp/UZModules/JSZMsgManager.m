//
//  JSZMsgManager.m
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZMsgManager.h"
static JSZMsgManager* _instance = nil;
@implementation JSZMsgManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.msgs = [NSMutableArray new];

    });
    return _instance;
}

@end
