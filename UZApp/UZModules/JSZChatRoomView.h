//
//  JSZChatRoomView.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARDAppClient.h"

@class RTCVideoTrack;
@class RTCEAGLVideoView;
@class JSZMicListController;
@class JSZUserController;
@class JSZChatViewController;
@class JSZChatRoomView;
#import "RTCEAGLVideoView.h"
#import "CAPSPageMenu.h"
#import "InputView.h"
@protocol JSZChatRoomDelegate <NSObject>

- (void)chatRoomHangupButtonPressed:(UIButton *)sender from:(JSZChatRoomView *)fromView;

@end


@interface JSZChatRoomView : UIView <CAPSPageMenuDelegate, RTCEAGLVideoViewDelegate>{
    CAPSPageMenu *_pageMenu;
    JSZMicListController *_vc1;
    JSZUserController *_vc2;
    JSZChatViewController *_chatVc;
}

@property (strong, nonatomic) InputView *inputView;

@property (strong, nonatomic) ARDAppClient *client;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomUrl;

//Views, Labels, and Buttons
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;//顶部
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;//左
//@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *secRemoteView;//右

@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;



@property (strong, nonatomic)NSMutableArray *users;
//Auto Layout Constraints used for animations
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *remoteViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *remoteViewRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *remoteViewLeftConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *footerViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewLeftConstraint;

@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;//左视频区
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;//最上面的视频区
//@property (strong, nonatomic) RTCVideoTrack *secRemoteVieoTrack;//右视频区
@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;

@property (nonatomic, weak) id<JSZChatRoomDelegate> delegate;

@end
