//
//  JSZChatRoomController.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZChatRoomController.h"
#import "JSZChatRoomController+UX.h"

#import "JSZChatRoomView.h"

#import "ARDAppClient.h"

#import "UIButton+UI.h"
#import "JSZUserManager.h"
#import "NSUserDefaults+Save.h"
#import "JSZMsgProducer.h"
#import "JSZUser.h"

#import <IQKeyboardManager/IQKeyboardManager.h>
#define SERVER_HOST_URL @"https://appr.tc"
@interface JSZChatRoomController ()
<
    JSZChatRoomDelegate
>

@property (nonatomic, strong) NSString *offlineString;

@end

@implementation JSZChatRoomController

@synthesize chatRoomView = _chatRoomView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isZoom = NO;
    self.isAudioMute = NO;
    self.isVideoMute = NO;
    
    [self navBarSetting];
    
    [self addBackGestureRecognizer];
    
}


- (void)orientationChanged:(NSNotification *)notification
{
    
    [self.chatRoomView videoView:self.chatRoomView.localView didChangeVideoSize:self.chatRoomView.localVideoSize];
    [self.chatRoomView videoView:self.chatRoomView.remoteView didChangeVideoSize:self.chatRoomView.remoteVideoSize];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self disconnect];
    
    _offlineString = @"A";
    
    //Getting Orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(atActionUserList:)
                                                 name:@"atAction"
                                               object:nil];
   
    // pass
    self.client = [[ARDAppClient alloc] initWithDelegate:self];
    [self.client setServerHostUrl:SERVER_HOST_URL];
  
//    [self.client connectToRoomWithId:self.roomName options:nil];//其他默认为1，输入的 房间名 作为 用户名 和 用户 id
    [self.client connectToRoomWithRoomId:_roomId userId:_userId userName:_userName adminId:_adminId roomName:_roomName options:nil];
  

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.client];
    [NSUserDefaults jsz_setTurnOn:NO];
    [self disconnect];
    
    [JSZUserManager resetUserManager];
    
    if(self.client.webSocket.readyState == SR_OPEN) {
        [self.client.webSocket send:[JSZMsgProducer pubOfflineSenderId:[JSZUserManager sharedInstance].selfId senderName:[JSZUserManager sharedInstance].selfName onMic:YES closeManner:_offlineString]];
        [self.client.webSocket close];
    }
    
    [super viewWillDisappear:animated];
}


- (void)loadView {
    [super loadView];
    
    _chatRoomView = [[[NSBundle mainBundle] loadNibNamed:@"JSZChatRoomView" owner:self options:nil] objectAtIndex:0];
    _chatRoomView.delegate = self;
    
    self.view = _chatRoomView;
}

//// MARK:- JSZChatRoomDelegate
//
//- (void)chatRoomAudioButtonPressed:(UIButton *)sender from:(JSZChatRoomView *)fromView {
//    //TODO: this change not work on simulator (it will crash)
//    UIButton *audioButton = sender;
////    [audioButton turnOnUI:self.isAudioMute useMediaType:JSZMediaTypeAudio];
//    if (self.isAudioMute) {
//        [self.client unmuteAudioIn];
//        audioButton.selected = YES;
//        self.isAudioMute = NO;
//    } else {
//        [self.client muteAudioIn];
//        audioButton.selected = NO;
//        self.isAudioMute = YES;
//    }
//    
//}

//- (void)chatRoomVideoButtonPressed:(UIButton *)sender from:(JSZChatRoomView *)fromView {
//    UIButton *videoButton = sender;
//    if (self.isVideoMute) {
//        //        [self.client unmuteVideoIn];
//        [self.client swapCameraToFront];
//        [videoButton turnOnUI:YES useMediaType:JSZMediaTypeVideo];
////        [videoButton setImage:[UIImage imageNamed:@"videoOn"] forState:UIControlStateNormal];
//        self.isVideoMute = NO;
//    } else {
//        [self.client swapCameraToBack];
//        //[self.client muteVideoIn];
//        //[videoButton setImage:[UIImage imageNamed:@"videoOff"] forState:UIControlStateNormal];
//        self.isVideoMute = YES;
//    }
//}

- (void)chatRoomHangupButtonPressed:(UIButton *)sender from:(JSZChatRoomView *)fromView {
    self.client.turnOn = !([NSUserDefaults jsz_turnOn]?:NO);
    sender.selected = self.client.turnOn;
    
}
- (void)setRoomId:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName adminId:(NSString *)adminId roomName:(NSString *)roomName
{
//    _roomName = roomName;

    
    _roomId = roomId;
    _userId = userId;
    _userName = userName;
    _adminId = adminId;
    _roomName = roomName;

    
}

- (void)appClient:(ARDAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack isAdmin:(BOOL)isAdmin{
    
    if (localVideoTrack) {
        NSLog(@"收到本地视频");
        if (isAdmin) {
            NSLog(@"在顶部渲染房主视频");
            [_chatRoomView.remoteVideoTrack removeRenderer:_chatRoomView.remoteView];
            _chatRoomView.remoteVideoTrack = nil;
            [_chatRoomView.remoteView renderFrame:nil];
            
            _chatRoomView.remoteVideoTrack = localVideoTrack;
            [_chatRoomView.remoteVideoTrack addRenderer:_chatRoomView.remoteView];
            
            if (_chatRoomView.localVideoTrack) {
                _chatRoomView.localView.hidden = NO;
            }else {
                _chatRoomView.localView.hidden = YES;
            }
            
        }else{//如果不是房主的话 说明 申请上麦了 从左往右开始搞起
            if ([JSZUserManager sharedInstance].allVideos == 1) {//算上自己只有一个，也就是房主没开视频
                NSLog(@"本地视频渲染在第一个上 %@",localVideoTrack);
                [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
                _chatRoomView.localVideoTrack = nil;
                [_chatRoomView.localView renderFrame:nil];
                
                _chatRoomView.localVideoTrack = localVideoTrack;
                [_chatRoomView.localVideoTrack addRenderer:_chatRoomView.localView];
                
                _chatRoomView.localView.hidden = NO;
                
                
            }else if ([JSZUserManager sharedInstance].allVideos == 2){//算上自己有两个，也就是房主开视频了
                
                NSLog(@"本地视频渲染在第一个上 %@",localVideoTrack);
                [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
                _chatRoomView.localVideoTrack = nil;
                [_chatRoomView.localView renderFrame:nil];
//                [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//                _chatRoomView.secRemoteVieoTrack = nil;
//                [_chatRoomView.secRemoteView renderFrame:nil];
                
                
                _chatRoomView.localVideoTrack = localVideoTrack;
                [_chatRoomView.localVideoTrack addRenderer:_chatRoomView.localView];
            }else if ([JSZUserManager sharedInstance].allVideos == 3){
                NSLog(@"本地视频渲染在第二个上");
//                [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//                _chatRoomView.secRemoteVieoTrack = nil;
//                [_chatRoomView.secRemoteView renderFrame:nil];
//                
//                _chatRoomView.secRemoteVieoTrack = localVideoTrack;
//                [_chatRoomView.secRemoteVieoTrack addRenderer:_chatRoomView.secRemoteView];
            }else if([JSZUserManager sharedInstance].allVideos == 0){
                NSLog(@"没有视频需要显示");
                [_chatRoomView.remoteVideoTrack removeRenderer:_chatRoomView.remoteView];
                _chatRoomView.remoteVideoTrack = nil;
                [_chatRoomView.remoteView renderFrame:nil];
                
                [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
                _chatRoomView.localVideoTrack = nil;
                [_chatRoomView.localView renderFrame:nil];
                
//                [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//                _chatRoomView.secRemoteVieoTrack = nil;
//                [_chatRoomView.secRemoteView renderFrame:nil];
                
            }else{
                NSLog(@"已有三个无法渲染 本地");
            }
        }
        
    }
}

//房主肯定是第一个远端视频流
- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTracks:(NSArray *)remoteVideoTracks isAdmin:(BOOL)isAdmin{
    if (remoteVideoTracks.count == 0) {
        return ;
    }
    NSLog(@"远端视频流 %@",remoteVideoTracks);//房主肯定在第一个
    
    //渲染
    if ([[JSZUserManager sharedInstance].adminId isEqualToString:[JSZUserManager sharedInstance].selfId]) {//自己是房主
        for (int i = 0; i<remoteVideoTracks.count; i++) {
            RTCVideoTrack *videoTrack = remoteVideoTracks[i];
            if (i == 0) {
                NSLog(@"第一个远端 %@",videoTrack);
                
                /**显示localView**/
                [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
                _chatRoomView.localVideoTrack = nil;
                [_chatRoomView.localView renderFrame:nil];
                
                _chatRoomView.localVideoTrack = videoTrack;
                [_chatRoomView.localVideoTrack addRenderer:_chatRoomView.localView];
                
                _chatRoomView.localView.hidden = NO;
                
                           }
            
            if (i == 1) {
                NSLog(@"第二个远端 %@",videoTrack);
//                [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//                _chatRoomView.secRemoteVieoTrack = nil;
//                [_chatRoomView.secRemoteView renderFrame:nil];
                
//                _chatRoomView.secRemoteVieoTrack = videoTrack;
//                [_chatRoomView.secRemoteVieoTrack addRenderer:_chatRoomView.secRemoteView];
                
            }
            
            if (i >= 2) {
                NSLog(@"怎么有超过2人上麦了");
            }
        }
        
    }else{
        NSLog(@"不是房主");
        for (int i = 0; i<remoteVideoTracks.count; i++) {
            RTCVideoTrack *videoTrack = remoteVideoTracks[i];
            if (i == 0) {//是房主的渲染
                NSLog(@"渲染房主视频 %@",videoTrack);
                [_chatRoomView.remoteVideoTrack removeRenderer:_chatRoomView.remoteView];
                _chatRoomView.remoteVideoTrack = nil;
                [_chatRoomView.remoteView renderFrame:nil];
                
                _chatRoomView.remoteVideoTrack = videoTrack;
                [_chatRoomView.remoteVideoTrack addRenderer:_chatRoomView.remoteView];
            }
            
            if (i == 1) {
                NSLog(@"渲染上麦者的视频");
                [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
                _chatRoomView.localVideoTrack = nil;
                [_chatRoomView.localView renderFrame:nil];
                
                _chatRoomView.localVideoTrack = videoTrack;
                [_chatRoomView.localVideoTrack addRenderer:_chatRoomView.localView];
            }
            
            if (i == 2) {
//                [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//                _chatRoomView.secRemoteVieoTrack = nil;
//                [_chatRoomView.secRemoteView renderFrame:nil];
//                
//                _chatRoomView.secRemoteVieoTrack = videoTrack;
//                [_chatRoomView.secRemoteVieoTrack addRenderer:_chatRoomView.secRemoteView];
            }
            
            if (i > 2) {
                NSLog(@"怎么有超过2人上麦了");
            }
        }
        
    }
    //清除
    if ([JSZUserManager sharedInstance].allVideos == 1) {
        NSLog(@"清除localView");
        [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
        _chatRoomView.localVideoTrack = nil;
        [_chatRoomView.localView renderFrame:nil];
        
//        [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//        _chatRoomView.secRemoteVieoTrack = nil;
//        [_chatRoomView.secRemoteView renderFrame:nil];
    }else if ([JSZUserManager sharedInstance].allVideos == 2){
        NSLog(@"清除左2");
//        [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
//        _chatRoomView.secRemoteVieoTrack = nil;
//        [_chatRoomView.secRemoteView renderFrame:nil];
    }
}

- (void)appClient:(ARDAppClient *)client didError:(NSError *)error {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"%@", error]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [self disconnect];
}

- (void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state
{
    switch (state) {
        case kARDAppClientStateConnected:
            NSLog(@"Client connected.");
            break;
        case kARDAppClientStateConnecting:
            NSLog(@"Client connecting.");
            break;
        case kARDAppClientStateDisconnected:
            NSLog(@"Client disconnected.");
            [self remoteDisconnected];
        default:
            break;
    }
}

- (void)isRepeatLoginOffLine:(NSString *)offlineString {
    if ([offlineString isEqualToString:@"B"]) {
        _offlineString = offlineString;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disconnect {
    if (self.client) {
        if (_chatRoomView.localVideoTrack) [_chatRoomView.localVideoTrack removeRenderer:_chatRoomView.localView];
        if (_chatRoomView.remoteVideoTrack) [_chatRoomView.remoteVideoTrack removeRenderer:_chatRoomView.remoteView];
//        if (_chatRoomView.secRemoteVieoTrack) [_chatRoomView.secRemoteVieoTrack removeRenderer:_chatRoomView.secRemoteView];
        _chatRoomView.localVideoTrack = nil;
        [_chatRoomView.localView renderFrame:nil];
        
        _chatRoomView.remoteVideoTrack = nil;
        [_chatRoomView.remoteView renderFrame:nil];
        
//        _chatRoomView.secRemoteVieoTrack = nil;
//        [_chatRoomView.secRemoteView renderFrame:nil];
        
        [self.client disconnect];
    }
}
- (void)remoteDisconnected {
    if (_chatRoomView.remoteVideoTrack) [_chatRoomView.remoteVideoTrack removeRenderer:_chatRoomView.remoteView];
    _chatRoomView.remoteVideoTrack = nil;
    [_chatRoomView.remoteView renderFrame:nil];
    [_chatRoomView videoView:_chatRoomView.localView didChangeVideoSize:_chatRoomView.localVideoSize];
    
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    
}


// MARK:- atAction

- (void)atActionUserList:(NSNotification *)notif {
    JSZUser *user = (JSZUser *)notif.userInfo[@"user"];
    
    [_chatRoomView.inputView.userListBtn setTitle:user.userName forState:UIControlStateNormal];
}

@end
