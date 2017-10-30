//
//  JSZChatRoomModule.m
//  UZModule
//
//  Created by kenny on 14-3-5.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "JSZChatRoomModule.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"
#import "JSZAppDelegate.h"
#import "JSZLog.h"

#import "JSZChatRoomController.h"
#import "RoomInfo.h"

@interface JSZChatRoomModule ()
<UIAlertViewDelegate>
{
    NSInteger _cbId;
}

@end

@implementation JSZChatRoomModule

+ (void)launchMethod {
    JSZAppDelegate *appDelegate = [[JSZAppDelegate alloc] init];
    [theApp addAppHandle:appDelegate];
}

- (id)initWithUZWebView:(UZWebView *)webView_ {
    if (self = [super initWithUZWebView:webView_]) {
        
    }
    return self;
}

- (void)dispose {
    //do clean
}

- (void)enterRoom:(NSDictionary *)paramDict {
    // 获取房间信息
    NSString *roomid = [paramDict stringValueForKey:@"roomid" defaultValue:nil];
    NSString *userid = [paramDict stringValueForKey:@"userid" defaultValue:nil];
    NSString *username = [paramDict stringValueForKey:@"username" defaultValue:nil];
    NSString *adminid = [paramDict stringValueForKey:@"adminid" defaultValue:nil];
    NSString *roomname = [paramDict stringValueForKey:@"roomname" defaultValue:nil];
    
    // 进入会议室
    if (roomid && userid && username && adminid && roomname) {
        DDLogVerbose(@"进入会议室");
        JSZChatRoomController *chatRoomController = [[JSZChatRoomController alloc] init];
//        RoomInfo *roomInfo = [[RoomInfo alloc] init];
      
//        roomInfo.roomid = roomid;
//        roomInfo.userid = userid;
//        roomInfo.password = password;
//        roomInfo.username = username;
//        roomInfo.adminid = adminid;
//        roomInfo.roomname = roomname;
//        
        [chatRoomController setRoomId:roomid userId:userid userName:username adminId:adminid roomName:roomname];
        
        
    
        [self.viewController.navigationController pushViewController:chatRoomController animated:YES];
        
        
    }
    
}

@end
