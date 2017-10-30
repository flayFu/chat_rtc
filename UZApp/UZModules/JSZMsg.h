//
//  JSZMsg.h
//  UZApp
//
//  Created by bin wu on 2017/7/19.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSZMsg : NSObject
@property(nonatomic, assign)BOOL isCome;
@property(nonatomic, copy)NSString *msg;


@property(nonatomic, copy) NSString *sender_ID; /** 发送消息人的ID**/
@property(nonatomic, copy) NSString *sender_NAME; /**发送消息人的名字**/
@property(nonatomic, copy) NSString *target_ID; /** 目标id **/

@end
