//
//  JSZUser.h
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum USERSTATE{
    USERSTATEDEFAULT,//默认状态 未上麦
    USERSTATEPUBMICON,//已经上麦
}USERSTATE;
typedef enum : NSUInteger {
    PUBSTATEDEFAULT,//默认状态 公聊
    PUBSTATEPRIVATE,//私聊
}PUBSTATE;
@interface JSZUser : NSObject
@property(nonatomic, copy)NSString *userName;
@property(nonatomic, copy)NSString *userId;
@property(nonatomic, assign)USERSTATE state;
@property(nonatomic, assign)PUBSTATE pubState;

@end
