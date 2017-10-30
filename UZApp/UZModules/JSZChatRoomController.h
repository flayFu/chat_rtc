//
//  JSZChatRoomController.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARDAppClient;
#import "JSZChatRoomView.h"
#import "RTCEAGLVideoView.h"

@class RoomInfo;

@interface JSZChatRoomController : UIViewController <ARDAppClientDelegate, RTCEAGLVideoViewDelegate>

@property (strong, nonatomic) NSString *roomUrl;


@property (strong, nonatomic) ARDAppClient *client;

@property (assign, nonatomic) BOOL isZoom; //used for double tap remote view

//togle button parameter
@property (assign, nonatomic) BOOL isAudioMute;
@property (assign, nonatomic) BOOL isVideoMute;

- (void)setRoomId:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName adminId:(NSString *)adminId roomName:(NSString *)roomName;

@property(nonatomic, strong)JSZChatRoomView *chatRoomView;


@property(nonatomic, strong) NSString *roomId;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *adminId;
@property(nonatomic, strong) NSString *roomName;

@property(nonatomic, strong) RoomInfo *roomInfo;




@end
