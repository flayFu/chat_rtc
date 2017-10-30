//
//  JSZMsgManager.h
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSZMsgManager : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic, strong)NSMutableArray *msgs;

@end
