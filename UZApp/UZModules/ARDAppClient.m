/*
 * libjingle
 * Copyright 2014, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ARDAppClient.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "ARDMessageResponse.h"
#import "ARDRegisterResponse.h"
#import "ARDSignalingMessage.h"
#import "ARDUtilities.h"
#import "ARDWebSocketChannel.h"
#import "RTCICECandidate+JSON.h"
#import "RTCICEServer+JSON.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription+JSON.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoTrack.h"
#import "RTCAudioTrack.h"
#import "OrderedDictionary.h"
#import "RTCDataChannel.h"
#import "RTCPeerConnection+MetaData.h"
#import "RTCVideoTrack+MetaData.h"
#import "JSZMsgProducer.h"
#import "JSZUserManager.h"
#import "JSZMsgManager.h"
#import "JSZMsg.h"
#import "JSZUser.h"
#import "AlertHelper.h"
#import "RTCVideoTrack.h"
//#import "AppDelegate.h"
#import "JSZChatRoomController.h"
#import "JSZAppDelegate.h"
#import "JSZTypeConvert.h"
#import "NSUserDefaults+Save.h"
#import "JSZMsgProducer.h"

typedef void(^regOk)(ARDMessageResponse *response);
// TODO(tkchin): move these to a configuration object.
static NSString *kARDRoomServerHostUrl =
@"http://192.168.0.118:8080/Conference/";
static NSString *kARDRoomServerRegisterFormat =
@"%@/join/%@";
static NSString *kARDRoomServerMessageFormat =
@"%@/message/%@/%@";
static NSString *kARDRoomServerByeFormat =
@"%@/leave/%@/%@";

static NSString *kARDDefaultSTUNServerUrl =
@"stun:stun.l.google.com:19302";
// TODO(tkchin): figure out a better username for CEOD statistics.
static NSString *kARDTurnRequestUrl =
@"stun:stun.services.mozilla.com";

static NSString *kARDAppClientErrorDomain = @"ARDAppClient";
static NSInteger kARDAppClientErrorSetSDP = -4;
//返回值 参数 都为空
typedef void(^emptyBlock)(void);
@interface ARDAppClient () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCDataChannelDelegate,SRWebSocketDelegate,SocketIODelegate>{
    NSMutableArray *_data;
    RTCDataChannel *_rtcChannel;
    RTCDataChannel *_remoteChannel;
    BOOL _open;
    RTCMediaStream *_mediaStream;
    NSMutableArray *_peers;
    BOOL _secondOffer;//用户申请上麦，房主同意后进行二次offer
    NSMutableArray *_candidates;
    BOOL _getAllCandidates;
    BOOL _dealWithPubMicOn;
    BOOL _shangMai;//作为用户是否公聊上麦
    BOOL _privateMai;
    //    BOOL _askForVideo;//别的用户要视频
    BOOL _dealWithLogIn;//正在处理登入事件(作为房主)
    BOOL _endOfferWithAdmin;//和房主的信令结束了
    BOOL _endOfferWithSomeOnePubMicOn;//和某个人的 offer video event 处理完了
    
    BOOL _dealWithPreLoginsAsUser;//当自己上麦后要向之前登陆的发送offer
    
    NSUInteger _allVideos;//共有几个视频正在显示
    NSMutableArray<RTCVideoTrack *> *_remoteVideoTracks;
    
    NSMutableArray *_pubMicOnUsers;//在和房主公聊的人,作为用户时处理
    
    NSMutableArray *_shangMaiUsers;//同意上麦的人们
    
    NSMutableArray *_logIns;//开启视频的时候有多少用户想要看房主的视频
    
    NSMutableArray *_users;//当自己上麦时需要向谁发送offer
    
    BOOL _onceCompelete;//完成一次
    
    SocketIO *socketIO;
    
}
@property(nonatomic, copy) NSString *sendToId;
@property(nonatomic, copy) regOk reponse;
@property(nonatomic, strong) ARDWebSocketChannel *channel;
//@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) NSMutableArray *messageQueue;
@property(nonatomic, strong) UILabel *log;
@property(nonatomic, assign) BOOL isTurnComplete;
@property(nonatomic, assign) BOOL hasReceivedSdp;
@property(nonatomic, readonly) BOOL isRegisteredWithRoomServer;

@property(nonatomic, strong) NSString *roomId;
@property(nonatomic, strong) NSString *clientId;
@property(nonatomic, copy) NSString *adminId;
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, assign) BOOL isInitiator;

@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *roomName;

@property(nonatomic, assign) BOOL isAdmin;
@property(nonatomic, assign) BOOL isSpeakerEnabled;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, strong) NSURL *webSocketURL;
@property(nonatomic, strong) NSURL *webSocketRestURL;
@property(nonatomic, strong) RTCAudioTrack *defaultAudioTrack;
@property(nonatomic, strong) RTCVideoTrack *defaultVideoTrack;

@end

@implementation ARDAppClient

@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize serverHostUrl = _serverHostUrl;
@synthesize channel = _channel;
//@synthesize peerConnection = _peerConnection;
@synthesize factory = _factory;
@synthesize messageQueue = _messageQueue;
@synthesize isTurnComplete = _isTurnComplete;
@synthesize hasReceivedSdp  = _hasReceivedSdp;
@synthesize roomId = _roomId;
@synthesize clientId = _clientId;
@synthesize isInitiator = _isInitiator;
@synthesize isSpeakerEnabled = _isSpeakerEnabled;
@synthesize iceServers = _iceServers;
@synthesize webSocketURL = _websocketURL;
@synthesize webSocketRestURL = _websocketRestURL;

//1.A和B连接上服务端，建立一个TCP长连接（任意协议都可以，WebSocket/MQTT/Socket原生/XMPP），我们这里为了省事，直接采用WebSocket，这样一个信令通道就有了。
//
//2.A从ice server（STUN Server）获取ice candidate并发送给Socket服务端，并生成包含session description（SDP）的offer，发送给Socket服务端。
//
//3.Socket服务端把A的offer和ice candidate转发给B，B会保存下A这些信息。
//
//4.然后B发送包含自己session description的answer(因为它收到的是offer，所以返回的是answer，但是内容都是SDP)和ice candidate给Socket服务端。
//
//5.Socket服务端把B的answer和ice candidate给A，A保存下B的这些信息。
//
//至此A与B建立起了一个P2P连接。
//

- (void)connectToRoomWithRoomId:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName adminId:(NSString *)adminId roomName:(NSString *)roomName options:(NSDictionary *)options
{
    _data = [NSMutableArray new];
    NSParameterAssert(roomId.length);
    NSParameterAssert(_state == kARDAppClientStateDisconnected);
    _state = kARDAppClientStateConnecting;
    
    
    __weak ARDAppClient *weakSelf = self;
    NSURL *turnRequestURL = [NSURL URLWithString:kARDTurnRequestUrl];
    [self requestTURNServersWithURL:turnRequestURL completionHandler:^(NSArray *turnServers) {
        ARDAppClient *strongSelf = weakSelf;
        [strongSelf.iceServers addObjectsFromArray:turnServers];
        strongSelf.isTurnComplete = YES;
    }];
    
    [self registerWithRoomId:roomId userId:userId userName:userName adminId:adminId roomName:roomName];
    
}

- (void)initiativePubDownMic:(NSNotification *)notification
{
    NSString *sendrId = notification.userInfo[@"userId"];
    NSString *sendrName = notification.userInfo[@"userName"];
    NSString *privateString = notification.userInfo[@"private"];
    NSLog(@"主动下麦 ```````%@", sendrId);
    [_peers enumerateObjectsUsingBlock:^(RTCPeerConnection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeStream:_mediaStream];
        NSLog(@"删除流");
    }];
    _allVideos--;
    [JSZUserManager sharedInstance].allVideos = _allVideos;
    
    [self.delegate appClient:self didReceiveRemoteVideoTracks:[_remoteVideoTracks copy] isAdmin:_isAdmin];
    [self.delegate appClient:self didReceiveLocalVideoTrack:nil isAdmin:NO];
    if ([privateString isEqualToString:@"YES"]) {
        //响应房主的下麦
        [self.webSocket send:[JSZMsgProducer privateMicVideoDownSenderName:sendrName senderId:sendrId]];
    }else {
        //响应房主的下麦
        
        [self.webSocket send:[JSZMsgProducer publicMicVideoDownSenderName:sendrName senderId:sendrId]];
    }
}
- (void)registerWithRoomId:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName adminId:(NSString *)adminId roomName:(NSString *)roomName
{
    _roomId = roomId;
    _userName = userName;
    _roomName = roomName;
    
    _peers = [NSMutableArray new];
    _adminId = adminId;
    _userId = userId;
    
    [JSZUserManager sharedInstance].adminId = _adminId;
    [JSZUserManager sharedInstance].selfId = _userId;
    
    _log = [[UILabel alloc] initWithFrame:CGRectMake(100, 64, 200, 300)];
    _log.numberOfLines = 0;
    _log.backgroundColor = [UIColor clearColor];
    _log.textColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_log];
    
//    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://192.168.0.123:8080/Conference/websocket/3/%@/3/%@/%@/3/conn", _userId, _userName, _adminId]]]];
    
//    192.168.0.103https://192.168.0.103:8000?a=2
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://192.168.0.103:8000?a=3"]]]];
    
    [JSZUserManager sharedInstance].adminId = adminId;
    
    [JSZUserManager sharedInstance].selfId = _userId;
    [JSZUserManager sharedInstance].selfName = _userName;
    self.webSocket.delegate = self;
    self.clientId = userId;
    if ([userId isEqualToString:_adminId]) {
        self.isAdmin = YES;
    }else {
        self.isAdmin = NO;
    }
    [self.webSocket open];
    
    
//    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"localhost", NSHTTPCookieDomain,
//                                @"/", NSHTTPCookiePath,
//                                @"auth", NSHTTPCookieName,
//                                @"56cdea636acdf132", NSHTTPCookieValue,
//                                nil];
//    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
//    NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
//    
//    socketIO.cookies = cookies;
//    
//    // connect to the socket.io server that is running locally at port 3000
//    socketIO = [[SocketIO alloc] initWithDelegate:self];
//    [socketIO connectToHost:@"192.168.0.103" onPort:8000];

    
    
}

//- (void)socketIODidConnect:(SocketIO *)socket
//{
//    NSLog(@"socket.io connected.");
//}
//
//- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
//{
//    NSLog(@"didReceiveEvent()");
//}
//
//- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
//{
//    NSLog(@"sdd");
//}
#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    //    [self.webSocket send:[JSZTypeConvert jsonToString:@{@"event":@"user_info", @"roomid":_roomId, @"roomname":_roomName, @"userid":_userId, @"username":_userName, @"adminid": _adminId}]];
    
    
    JSZUser *user = [JSZUser new];
    user.userId = _userId;
    user.userName = _userName;
    if (_isAdmin) {
        [[JSZUserManager sharedInstance].miclist addObject:user];
    }else {
        [[JSZUserManager sharedInstance].userList addObject:user];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"miclist" object:self];
    [NSTimer scheduledTimerWithTimeInterval:23 target:self selector:@selector(ping) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSDictionary *dict = [NSDictionary dictionaryWithJSONString:message];
    
    NSLog(@"~~~~~!!!!!!!!###~~~~~~~%@", dict);
    
    if ([dict[@"event"] isEqualToString:@"_offer_start_media"]) {
        _allVideos++;
        [JSZUserManager sharedInstance].allVideos = _allVideos;
        _endOfferWithAdmin = NO;
        
        _sendToId = dict[@"sender_ID"];
        NSLog(@"%@ 接受 offer 来自于 %@", _clientId, _sendToId);
        _log.text = [NSString stringWithFormat:@"%@\n%@收到offer", _log.text, _clientId];
        NSString *sdp = dict[@"data"][@"sdp"][@"sdp"];
        
        //从ice server（STUN Server）获取ice candidate并发送给Socket服务端，并生成包含session description（SDP）的offer
        RTCSessionDescription *sessionDes = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];
        [self reactToOffer];
        RTCPeerConnection *peerConnection = [self findLastConnection];
        if (sessionDes) {
            //1.设置远端描述
            [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sessionDes];
            [self performSelector:@selector(sendAllCandidates) withObject:nil afterDelay:2];
        }
        
        RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
        [peerConnection createAnswerWithDelegate:self constraints:constraints];
        
    }else if ([dict[@"event"] isEqualToString:@"_answer"]) { //收到别人的offer，而回复answer
        RTCPeerConnection *peerConnection = [self findLastConnection];
        NSString *sdp = dict[@"data"][@"sdp"][@"sdp"];
        NSString *type = dict[@"data"][@"sdp"][@"type"];
        NSLog(@"%@ 接受answer来自于%@", _clientId, _sendToId);
        _log.text = [NSString stringWithFormat:@"%@\n%@～～～ddddfffg～～～～～～～～收到answer",_log.text, _clientId];
        RTCSessionDescription *sessionDes = [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
        [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sessionDes];
        [self performSelector:@selector(sendAllCandidates) withObject:nil afterDelay:2];
    }else if ([dict[@"event"] isEqualToString:@"_ice_candidate"]) { //接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
        RTCPeerConnection *peerConnection = [self findLastConnection];
        NSDictionary *candidateDict = dict[@"data"][@"candidate"];
        NSString *mid = candidateDict[@"sdpMid"];
        
        NSNumber *indexNum = candidateDict[@"sdpMLineIndex"];
        NSInteger index = [indexNum integerValue];
        
        NSString *sdp = candidateDict[@"candidate"];
        //生成远端网络地址对象
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:mid index:index sdp:sdp];
        NSLog(@"%@ 接收candidate来自于 %@ %@", _clientId, _sendToId, candidate);
        //添加到点对点连接中
        [peerConnection addICECandidate:candidate];
        
        if (![_log.text containsString:@"收到ICE"]) {
            _log.text = [NSString stringWithFormat:@"%@\n%@收到ICE", _log.text,_clientId];
        }
        _log.textColor = [UIColor blueColor]; //按时收到candidate
        
    }else if ([dict[@"event"] isEqualToString:@"_login"]) {
        NSLog(@"有人登陆-------------");
        JSZUser *user = [JSZUser new];
        user.userId = dict[@"sender_ID"];
        user.userName = dict[@"sender_NAME"];
        
        if ([user.userId isEqualToString:[JSZUserManager sharedInstance].adminId]) {
            [[JSZUserManager sharedInstance].miclist addObject:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"miclist" object:@"logIn" userInfo:@{@"userId":dict[@"sender_ID"]}];
        }else {
            [[JSZUserManager sharedInstance].userList addObject:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"someonlogin" object:@"logIn" userInfo:@{@"userId":dict[@"sender_ID"]}];
        }
        
        if (_isAdmin || _shangMai) {
            if (![NSUserDefaults jsz_turnOn]) {
                __block BOOL preContain = NO;
                [_logIns enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.userId isEqualToString:user.userId]) {
                        preContain = YES;
                    }
                }];
                if (!preContain) {
                    [_logIns addObject:user];//先存放起来，等开启视频后再做处理
                }
            }else {
                if (_shangMaiUsers.count == 0 && _pubMicOnUsers.count == 0) {
                    NSLog(@"直接出来登陆事件");
                    if (!_isAdmin) {
                        if (_endOfferWithAdmin && _shangMai && !_dealWithPreLoginsAsUser) {
                            _sendToId = dict[@"sender_ID"];
                            [self startSignalingIfReady];
                        }else {
                            __block BOOL preContain = NO;
                            [_logIns enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj.userId isEqualToString:user.userId]) {
                                    preContain = YES;
                                }
                            }];
                            if (!preContain) {
                                NSLog(@"我在忙，登陆者先存起来");
                                [_logIns addObject:user];//先存放起来，等开启视频后再做处理
                                
                            }
                        }
                    }else {
                        if (_endOfferWithSomeOnePubMicOn) {
                            _sendToId = dict[@"sender_ID"];
                            [self startSignalingIfReady];
                        }else {
                            __block BOOL preContain = NO;
                            [_logIns enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj.userId isEqualToString:user.userId]) {
                                    preContain = YES;
                                }
                            }];
                            if (!preContain) {
                                NSLog(@"我在忙，登陆者先存起来");
                                [_logIns addObject:user]; //先存放起来，等开启视频后再做处理
                            }
                        }
                    }
                }else {
                    __block BOOL preContain = NO;
                    [_logIns enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.userId isEqualToString:user.userId]) {
                            preContain = YES;
                        }
                    }];
                    if (!preContain) {
                        NSLog(@"我在忙，登陆者先存起来");
                        [_logIns addObject:user]; //先存放起来，等开启视频后再做处理
                    }
                    
                }
            }
        }
        
    }else if ([dict[@"event"] isEqualToString:@"_mic_video_on"]) {
        NSLog(@"收到申请上麦的消息 不做任何信令处理 立马将其添加到麦序列表中");
        NSString *senderTo = dict[@"sender_ID"];
        [[JSZUserManager sharedInstance].userList enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:senderTo]) {
                [[JSZUserManager sharedInstance].userList removeObject:obj];
                [[JSZUserManager sharedInstance].miclist addObject:obj];
                NSLog(@"``````*******```````````%@", dict[@"media_TYPE"]);
                if ([dict[@"media_TYPE"] isEqualToString:@"私聊"]) {
                    obj.pubState = PUBSTATEPRIVATE;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
        }];
        
    }else if ([dict[@"event"] isEqualToString:@"_offer_agree_video"]) {//收到同意上麦
        _users = [[NSMutableArray alloc] initWithArray:[JSZUserManager sharedInstance].allUsers];
        
        //
        NSLog(@"上麦了？？？？！！！");
        _endOfferWithAdmin = NO;
        _shangMai = YES;
        _sendToId = dict[@"sender_ID"];
        NSLog(@"%@接收offer来自于 %@", _clientId, _sendToId);
        _log.text = [NSString stringWithFormat:@"%@\n%@收到offer", _log.text, _clientId];
        NSString *sdp = dict[@"data"][@"sdp"][@"sdp"];
        RTCSessionDescription *sessionDes = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];
        
        [self reactToOffer];
        RTCPeerConnection *peerConnection = [self findLastConnection];
        if (sessionDes) {
            [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sessionDes];
        }
        [self performSelector:@selector(sendAllCandidates) withObject:nil afterDelay:2];
        
        RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
        [peerConnection createAnswerWithDelegate:self constraints:constraints];
        [[JSZUserManager sharedInstance].onMicVideo addObject:_clientId];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"agreePubMicOn" object:self userInfo:@{@"userId":_clientId}];
        
    }else if ([dict[@"event"] isEqualToString:@"_mic_video_down"]) {
        // 下麦
        [JSZUserManager sharedInstance].forbided = YES;
        _sendToId = dict[@"sender_ID"];
        [[JSZUserManager sharedInstance].onMicVideo enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:_sendToId]) {
                [[JSZUserManager sharedInstance].onMicVideo removeObject:obj];
            }
        }];
        [[JSZUserManager sharedInstance].miclist enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:_sendToId]) {
                NSLog(@"麦序表中删除，添加到用户表");
                [[JSZUserManager sharedInstance].userList addObject:obj];
                [[JSZUserManager sharedInstance].miclist removeObject:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
            }
        }];
        [_remoteVideoTracks enumerateObjectsUsingBlock:^(RTCVideoTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RTCVideoTrack *video = (RTCVideoTrack *)obj;
            if ([video.belong isEqualToString:_sendToId]) {
                _allVideos--;
                [JSZUserManager sharedInstance].allVideos = _allVideos;
                NSLog(@"删除 %@ 的视频", video.belong);
                [_remoteVideoTracks removeObject:video];
            }
            [self.delegate appClient:self didReceiveRemoteVideoTracks:_remoteVideoTracks isAdmin:_isAdmin];
            [_delegate appClient:self didReceiveLocalVideoTrack:[_mediaStream.videoTracks firstObject] isAdmin:_isAdmin];
        }];
        
    }else if ([dict[@"data"][@"message"] isEqualToString:@"用户下线"]) {
        [[JSZUserManager sharedInstance] removeUser:dict[@"sender_ID"]];
        [_peers enumerateObjectsUsingBlock:^(RTCPeerConnection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.belong isEqualToString:dict[@"sender_ID"]]) {
                [_peers removeObject:obj];
            }
        }];
        
    }else if ([dict[@"data"][@"client_IDs"] count]) {//自己登陆时的已经登陆的人
        for (int index = 0; index < [(dict[@"data"][@"client_IDs"]) count]; index++) {
            NSString *userId = dict[@"data"][@"client_IDs"][index];
            //client_ids 中是 除了自己之外的所有已经登陆的用户 包括房主
            JSZUser *user = [JSZUser new];
            user.userId = userId;
            user.userName = dict[@"data"][@"client_NAMEs"][index];
            
            if (![user.userId isEqualToString:[JSZUserManager sharedInstance].adminId]) {
                __block BOOL preContain = NO;
                [_logIns enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.userId isEqualToString:user.userId]) {
                        preContain = YES;
                    }
                }];
                if (!preContain) {
                    [_logIns addObject:user];
                }
                NSLog(@"client_IDs logins = %@", _logIns);
            }
            if ([userId isEqualToString:[JSZUserManager sharedInstance].adminId]) {
                [[JSZUserManager sharedInstance].miclist addObject:user];
            }else {
                [[JSZUserManager sharedInstance].userList addObject:user];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
        
    }else if ([dict[@"event"] isEqualToString:@"_textChat_message"]) {
        /**
         *
         * 发送文字信息
         */
      
    }else if ([dict[@"event"] isEqualToString:@"_offer_video"]) { //有用户在视频，发送offer(房主先接通)
        _allVideos++;
        [JSZUserManager sharedInstance].allVideos = _allVideos;
        [self performSelector:@selector(startOfferVideo:) withObject:dict afterDelay:2];
        
    }else if ([dict[@"event"] isEqualToString:@"_forbidOnMic"]) {
        NSLog(@"被禁麦");
        [JSZUserManager sharedInstance].forbided = YES;
        [[JSZUserManager sharedInstance].miclist enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:_userId]) {
                NSLog(@"麦序表中删除，添加到用户表");
                [[JSZUserManager sharedInstance].userList addObject:obj];
                [[JSZUserManager sharedInstance].miclist removeObject:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
            }
        }];
        
        [_peers enumerateObjectsUsingBlock:^(RTCPeerConnection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeStream:_mediaStream];
            NSLog(@"删除流");
        }];
        _allVideos--;
        [JSZUserManager sharedInstance].allVideos = _allVideos;
        [self.delegate appClient:self didReceiveLocalVideoTrack:nil isAdmin:NO];
        [self.delegate appClient:self didReceiveRemoteVideoTracks:[_remoteVideoTracks copy] isAdmin:_isAdmin];
        [self.webSocket send:[JSZMsgProducer publicMicVideoDownSenderName:_userId senderId:_userId]]; //响应房主的下麦
        
    }else if ([dict[@"event"] isEqualToString:@"_offer_agree_video_private"]) {//收到同意私聊上麦
        NSLog(@"收到同意私聊上麦的消息");
        _privateMai = YES;
        _sendToId = dict[@"sender_ID"];
        NSLog(@"%@ received offer from %@",_clientId,_sendToId);
        _log.text = [NSString stringWithFormat:@"%@\n%@收到offer",_log.text, _clientId];
        NSString *sdp = dict[@"data"][@"sdp"][@"sdp"];
        RTCSessionDescription *sessionDes = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];
        [self reactToOffer];
        
        RTCPeerConnection *peerConnection = [self findLastConnection];
        if (sessionDes) {
            [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sessionDes];
        }
        [self performSelector:@selector(sendAllCandidates) withObject:nil afterDelay:2];
        
        RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
        [peerConnection createAnswerWithDelegate:self constraints:constraints];
        
        [[JSZUserManager sharedInstance].onMicVideo addObject:_clientId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"agreePrivateMicOn" object:self userInfo:@{@"userId":_clientId}];
        
    }else if ([dict[@"event"] isEqualToString:@"_repeatLogin"]){
        NSLog(@"用户重复登录");
    }
}



- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    _log.backgroundColor = [UIColor redColor];
    NSLog(@"websocket关闭原因：%@",reason);
    self.webSocket = nil;
}

#pragma mark -RTCPeerConnectionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"Signaling state changed %d", stateChanged);
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{
    if (_secondOffer) {
        NSLog(@"和%@的上麦完成了哦",_shangMaiUsers[0]);
        
        [_shangMaiUsers removeObjectAtIndex:0];
        
        if (_shangMaiUsers.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(adminCheckAgreeOnUsers) withObject:nil afterDelay:2];
            });
        }else {
            _secondOffer = NO;
        }
    }//以上处理多人上麦的情况
    
    if (!_endOfferWithSomeOnePubMicOn) {
        if (_pubMicOnUsers.count > 0) {
            [_pubMicOnUsers removeObjectAtIndex:0];
        }
    }
    if ([_sendToId isEqualToString:[JSZUserManager sharedInstance].adminId]) {
        NSLog(@"和房主的offer结束了");
        _endOfferWithAdmin = YES;
    }
    NSLog(@"正在公聊的 %@", _pubMicOnUsers);
    if (_dealWithPreLoginsAsUser) {
        if (_users.count > 0) {
            [_users removeObjectAtIndex:0];
        }else {
            _dealWithPreLoginsAsUser = NO;
        }
    }
    if (_shangMai && _users.count > 0) {
        NSLog(@"有需要处理的之前登陆的人");
        _dealWithPreLoginsAsUser = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(userCheckPubMicOnUsers) withObject:nil afterDelay:4];
    });
    
    NSLog(@"Received %lu video tracks and %lu audio tracks",(unsigned long)stream.videoTracks.count,(unsigned long)stream.audioTracks.count);
    if (stream.videoTracks.count) {
        RTCVideoTrack *videoTrack = stream.videoTracks[0];
        videoTrack.belong = _sendToId;
        NSLog(@"收到 %@ 的视频流--------", videoTrack.belong);
        __block NSUInteger index = -1;
        [_remoteVideoTracks enumerateObjectsUsingBlock:^(RTCVideoTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.belong isEqualToString:_sendToId]) {
                [_remoteVideoTracks removeObject:obj];
                index = idx;
            }
        }];
        if (index != -1) {
            [_remoteVideoTracks insertObject:videoTrack atIndex:index];
        }else {
            [_remoteVideoTracks addObject:videoTrack];
        }
        NSLog(@"~~~~~~~~~~~~~~~~~~remoteVideoTracks  %@",_remoteVideoTracks);
        [_delegate appClient:self didReceiveRemoteVideoTracks:[_remoteVideoTracks copy] isAdmin:_isAdmin];
        [_delegate appClient:self didReceiveLocalVideoTrack:[_mediaStream.videoTracks firstObject] isAdmin:_isAdmin];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"未能创建会话描述。错误: %@ %@", error, sdp.type);
            [self disconnect];
            return;
        }
        
        NSLog(@"%@ 设置本地描述", _clientId);
        [[self findLastConnection] setLocalDescriptionWithDelegate:self sessionDescription:sdp];
        [self sendSignal:sdp];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"Failed to set session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to set session description."};
            NSError *sdpError = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain code:kARDAppClientErrorSetSDP userInfo:userInfo];
            [_delegate appClient:self didError:sdpError];
            return ;
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
{
    if (newState == 2) {
        _getAllCandidates = YES;
    }else {
        if (_getAllCandidates) {
            _getAllCandidates = NO;
        }
    }
    NSLog(@"ICE gathering state changed: %d", newState);
    
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    if (!_onceCompelete) {
        [_candidates addObject:candidate];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_log.text containsString:@"ICE"]) {
            _log.text = [NSString stringWithFormat:@"%@\n%@发送ICE",_log.text,_clientId];
        }
    });
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"ICE state changed: %d",newState);
    if (newState == RTCICEConnectionConnected) {
        NSLog(@"建立连接");
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
    if (newState == RTCICEConnectionCompleted) {
        _onceCompelete = YES;
        NSLog(@"连接完成");
        if (_isAdmin || _shangMai) {
            if (_shangMaiUsers.count == 0 || _pubMicOnUsers.count == 0) {
                [self checkLogins];
            }
        }
    }
}


- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    NSLog(@"WARNING: 需要重新谈判，但未实现。");
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
{
    NSLog(@"Stream was removed.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _log.text = [NSString stringWithFormat:@"%@\n open data channel",_log.text];
    });
    _remoteChannel = dataChannel;
    _remoteChannel.delegate = self;
    NSLog(@"open data channel %@",_clientId);
}

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    _log.backgroundColor = [UIColor greenColor];
    NSLog(@"did receive msg %@", [[NSString alloc]initWithData:buffer.data encoding:NSUTF8StringEncoding]);
}
- (void)channelDidChangeState:(RTCDataChannel *)channel
{
    NSLog(@"did change state %d",channel.state);
    if (channel.state == 1) {
        _open = YES;
    }
}
//startSignalingIfReady

- (void)sendSignal:(RTCSessionDescription *)sdp
{
    if ([sdp.type isEqualToString:@"offer"]) {
        if (_isAdmin) {
            NSString *msg;
            if (_secondOffer) {
                NSString *sendto = [_shangMaiUsers firstObject];
                if (!sendto) {
                    return;
                }else {
                    _sendToId = sendto;
                }
                msg = [JSZMsgProducer offerFrom:_clientId to:sendto sdp:sdp agreePubMicOn:_secondOffer];
            }else {
                msg = [JSZMsgProducer offerFrom:_clientId to:_sendToId sdp:sdp agreePubMicOn:_secondOffer];
                NSLog(@"普通offer信息---------- %@", msg);
            }
            [self.webSocket send:msg];
            _log.text = [NSString stringWithFormat:@"%@\n%@发送offer给%@", _log.text, _clientId,_sendToId];
            
        }else {
            NSString *event = @"_offer_video";
            OrderedDictionary *dataDict = [OrderedDictionary dictionaryWithObjectsAndKeys:sdp.type,@"type",sdp.description,@"sdp", nil];
            OrderedDictionary *dict = [OrderedDictionary dictionaryWithObjectsAndKeys:event,@"event",_clientId,@"sender_ID",_sendToId,@"target_ID",@{@"sdp":dataDict},@"data", nil];
            
            NSString *msg = [self dictionaryToJson:dict];
            [self.webSocket send:msg];
            _log.text = [NSString stringWithFormat:@"%@\n%@发送offer给%@", _log.text, _clientId,_sendToId];
            NSLog(@"因为公聊上麦 %@ send offer to %@",_clientId, _sendToId);
        }
    }else if ([sdp.type isEqualToString:@"answer"]) {
        NSLog(@"%@ send answer to %@", _clientId, _sendToId);
        _log.text = [NSString stringWithFormat:@"%@\n%@发送answer给%@",_log.text, _clientId,_sendToId];
        OrderedDictionary *dataDict = [OrderedDictionary dictionaryWithObjectsAndKeys:sdp.type,@"type",sdp.description,@"sdp", nil];
        OrderedDictionary *dict = [OrderedDictionary dictionaryWithObjectsAndKeys:@"_answer",@"event",_clientId,@"sender_ID",_sendToId,@"target_ID",@{@"sdp":dataDict},@"data", nil];
        NSString *strTo = [self dictionaryToJson:dict];
        [self.webSocket send:strTo];
    }
}
- (void)startOfferVideo:(NSDictionary *)dict
{
    if (_endOfferWithAdmin && _endOfferWithSomeOnePubMicOn) {
        NSLog(@"开始offer video");
        _endOfferWithSomeOnePubMicOn = NO;
        _sendToId = dict[@"sender_ID"];
        [self handleOthersPubMicOn:dict];
    }else {
        [_pubMicOnUsers addObject:dict];
        NSLog(@"_pubMicOnUsers  %@", _pubMicOnUsers);
    }
}

- (void)handleOthersPubMicOn:(NSDictionary *)dict
{
    NSString *sdp = dict[@"data"][@"sdp"][@"sdp"];
    RTCSessionDescription *sessionDes = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];
    
    [self reactToOffer];
    
    RTCPeerConnection *peerConnection = [self findLastConnection];
    if (sessionDes) {
        [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sessionDes];
    }
    [self performSelector:@selector(sendAllCandidates) withObject:nil afterDelay:2];
    
    RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
    [peerConnection createAnswerWithDelegate:self constraints:constraints];
}
//登陆时先检查是否有人正在公聊 然后根据自己是否上麦再算处理
- (void)userCheckPubMicOnUsers
{
    _endOfferWithSomeOnePubMicOn = YES;//开始此offer的时候置为NO
    if (_pubMicOnUsers.count) {
        _sendToId = [_pubMicOnUsers firstObject][@"sender_ID"];
        [self handleOthersPubMicOn:[_pubMicOnUsers firstObject]];
    }else {
        if (_shangMai && _dealWithPreLoginsAsUser) {
            [self handlePreLoginsWhenPubOn];
        }
    }
}

- (void)handlePreLoginsWhenPubOn
{
    if (_users.count > 0) {
        NSLog(@"处理自己上麦时之前已经有人登陆");
        JSZUser *user = _users[0];
        _sendToId = user.userId;
        [self startSignalingIfReady];
    }else {
        _dealWithPreLoginsAsUser = NO;
    }
}
- (void)adminCheckAgreeOnUsers
{
    _sendToId = _shangMaiUsers[0];
    [self startSignalingIfReady];
}
// 发送Candidate
- (void)sendAllCandidates
{
    for (RTCICECandidate *candidate in _candidates) {
        [self sendCandidate:candidate];
    }
}
// 发送Candidate
- (void)sendCandidate:(RTCICECandidate *)candidate
{
    _log.textColor = [UIColor blueColor];//暗示发送candidate
    
    OrderedDictionary *dict;
    if (_secondOffer) { //如果处于上麦的情况的话, 第二次offer
        NSString *sendto = [_shangMaiUsers firstObject];
        
        NSLog(@"发送 candidate-- %@", sendto);
        OrderedDictionary *candidateDict = [OrderedDictionary dictionaryWithObjectsAndKeys:candidate.sdp,@"candidate", candidate.sdpMid,@"sdpMid",@(candidate.sdpMLineIndex),@"sdpMLineIndex", nil];
        dict = [OrderedDictionary dictionaryWithObjectsAndKeys:@"_ice_candidate",@"event",_clientId,@"sender_ID",sendto,@"target_ID",@{@"candidate": candidateDict},@"data", nil];
    }else {
        NSLog(@"发送给 candidate + %@",_sendToId);
        OrderedDictionary *candidateDict = [OrderedDictionary dictionaryWithObjectsAndKeys:candidate.sdp,@"candidate", candidate.sdpMid,@"sdpMid",@(candidate.sdpMLineIndex),@"sdpMLineIndex", nil];
        dict = [OrderedDictionary dictionaryWithObjectsAndKeys:@"_ice_candidate",@"event",_clientId,@"sender_ID",_sendToId,@"target_ID",@{@"candidate": candidateDict},@"data", nil];
    }
    NSString *str = [self dictionaryToJson:dict];
    [self.webSocket send:str];
}

- (RTCMediaConstraints *)defaultAnswerConstraints
{
    return [self defaultOfferConstraints];
}

// 对offer做出反应
- (void)reactToOffer
{
    [_peers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RTCPeerConnection *peer = (RTCPeerConnection *)obj;
        
        if ([peer.belong isEqualToString:_sendToId]) {
            [_peers removeObject:peer];// 找到了之前的连接，现在删除掉
        }
    }];
    // 创建peer connection
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    // 获取ice candidate并发送给Socket服务端，并生成session description（SDP）的
    RTCPeerConnection *peerConnection = [_factory peerConnectionWithICEServers:_iceServers constraints:constraints delegate:self];
    
    peerConnection.belong = _sendToId;
    
    if (!_mediaStream) {
        _mediaStream = [self createLocalMediaStream];
    }
    if (_shangMai || _isAdmin || _privateMai) { //如果是房主或者申请上麦的话则添加视频流 (申请上麦包括 私聊 和 公聊)
        [peerConnection addStream:_mediaStream];
    }
    [_peers addObject:peerConnection];
}
- (void)ping
{
    NSString *hasAdmin;
    if (_isAdmin) {
        hasAdmin = @"1";
    }else {
        hasAdmin = @"0";
    }
    OrderedDictionary *dict = [OrderedDictionary dictionaryWithObjectsAndKeys:@"_ping",@"event",_clientId,@"sender_ID",@"服务器", @"target_ID",hasAdmin,@"hasAdmin",@{@"message": [NSString stringWithFormat:@"%@--ping",_clientId]},@"data", nil];
    NSString *str = [self dictionaryToJson:dict];
    [self.webSocket send:str];
    if (_open) {
        NSData *data = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
        RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:data isBinary:YES];
        
        if ([_rtcChannel sendData:buffer]) {
            _log.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSString *STR = DICTTOSTR(dic);
    return STR;
}
- (void)requestTURNServersWithURL:(NSURL *)requestURL completionHandler:(void (^)(NSArray *turnServers))completionHandler
{
    NSParameterAssert([requestURL absoluteString].length);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    [request addValue:@"Mozilla/5.0" forHTTPHeaderField:@"user-agent"];
    [request addValue:self.serverHostUrl forHTTPHeaderField:@"origin"];
    [NSURLConnection sendAsyncRequest:request completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSArray *turnServers = [NSArray array];
        if (error) {
            NSLog(@"Unable to get TURN server.");
            completionHandler(turnServers);
            return;
        }
        NSDictionary *dict = [NSDictionary dictionaryWithJSONData:data];
        turnServers = [RTCICEServer serversFromCEODJSONDictionary:dict];
        completionHandler(turnServers);
    }];
}
- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate
{
    if (self = [super init]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        _delegate = delegate;
        
        _shangMaiUsers = [NSMutableArray new];
        _pubMicOnUsers = [NSMutableArray new];
        _logIns = [NSMutableArray new];
        
        _endOfferWithAdmin = YES;
        _endOfferWithSomeOnePubMicOn = YES;
        _remoteVideoTracks = [NSMutableArray new];
        _factory = [[RTCPeerConnectionFactory alloc] init];
        _messageQueue = [NSMutableArray new];
        _iceServers = [self defaultSTUNServer]; // 获取STUNServer 服务器
        _getAllCandidates = NO;
        _candidates = [NSMutableArray new];
        _serverHostUrl = kARDRoomServerHostUrl;
        _isSpeakerEnabled = YES;
        _allVideos = 0;
        [JSZUserManager sharedInstance].allVideos = 0;
        
        //申请公聊
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pubMicOn:) name:@"pubMicOn" object:@"gxpusercell"];
        //申请私聊
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privatePubMicOn:) name:@"agreePrivateMicOn" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agreePubMicOn:) name:@"agreePubMicOn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agreePrivateMicOn:) name:@"agreePrivateMicOn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initiativePubDownMic:) name:@"initiativePubDownMic" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forbidOnMic:) name:@"forbidPubOnMic" object:nil];
        
    }
    return self;
}

- (void)forbidOnMic:(NSNotification *)notification
{
    NSString *targetId = notification.userInfo[@"userId"];
    NSLog(@"禁止 %@ 上麦", targetId);
    [self.webSocket send:[JSZMsgProducer senderId:_userId forbidId:targetId]];
}

// 1.
- (void)setTurnOn:(BOOL)turnOn
{
    if (turnOn) {
        _allVideos++;
    }else {
        _allVideos--;
    }
    [JSZUserManager sharedInstance].allVideos = _allVideos;
    
    [NSUserDefaults jsz_setTurnOn:turnOn];
    
    _turnOn = turnOn;
    if (turnOn) {
        if (!_mediaStream) {
            _mediaStream = [self createLocalMediaStream];
        }
        // 枚举器是一种苹果官方推荐的更加面向对象的一种遍历方式
        [_peers enumerateObjectsUsingBlock:^(RTCPeerConnection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj addStream:_mediaStream];
        }];
        // 调用本地渲染
        [self.delegate appClient:self didReceiveLocalVideoTrack:[_mediaStream.videoTracks firstObject] isAdmin:_isAdmin];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        [AlertHelper alertWithText:@"开启视频" target:rootViewController];
        
        [self checkLogins];
    }else {
        [self.delegate appClient:self didReceiveLocalVideoTrack:nil isAdmin:_isAdmin];
        [_peers enumerateObjectsUsingBlock:^(RTCPeerConnection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeStream:_mediaStream];
        }];
    }
}

// 2.
- (RTCMediaStream *)createLocalMediaStream
{
    NSLog(@"create media stream-----------------");
    if ([NSUserDefaults jsz_turnOn]) {
        RTCMediaStream *localStream = [_factory mediaStreamWithLabel:@"erqe"];
        
        RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
        if (localVideoTrack) {
            [localStream addVideoTrack:localVideoTrack]; //仅在是房主的时候 流中才添加视频
            [_delegate appClient:self didReceiveLocalVideoTrack:localVideoTrack isAdmin:_isAdmin];
        }else {
            NSLog(@"创建视频失败");
        }
        RTCAudioTrack *audioTrack = [_factory audioTrackWithID:@"jljljlj"];
        
        [localStream addAudioTrack:audioTrack];
        return localStream;
    }
    return nil;
}
// 创造本地videoTrack  // 3.
- (RTCVideoTrack *)createLocalVideoTrack
{
    RTCVideoTrack *localVideoTrack  = nil;
    
    NSString *cameraID = nil;
    for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        //摄像头向前
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
    localVideoTrack = [_factory videoTrackWithID:@"12" source:videoSource];
    
    return localVideoTrack;
    
}
//1.我已登陆但是未开启视频  2.我登陆的时候之前已经有让你登陆了
- (void)checkLogins
{
    if (_shangMai || _isAdmin) {
        if (_logIns.count > 0) {
            _dealWithLogIn = YES;
            [self handleLogInUsers:[_logIns firstObject]];
            [_logIns removeObjectAtIndex:0];
        }else {
            _dealWithLogIn = NO;
        }
    }
}

- (void)handleLogInUsers:(JSZUser *)user {
    _sendToId = user.userId;
    [self startSignalingIfReady];
    NSLog(@"处理登入者");
}

- (void)startSignalingIfReady
{
    [_peers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RTCPeerConnection *peer = (RTCPeerConnection *)obj;
        if ([peer.belong isEqualToString:_sendToId]) {
            NSLog(@"找到了之前的连接 %@，现在删除掉", peer.belong);
            [peer removeStream:_mediaStream];
            [_peers removeObject:peer];
        }
    }];//如果之前有这个连接就删掉
    
    // 创建peer connection
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    //
    RTCPeerConnection *peerConnection = [_factory peerConnectionWithICEServers:_iceServers constraints:constraints delegate:self];
    
    peerConnection.belong = _sendToId;
    
    if (_mediaStream) {
        if (_shangMai || _isAdmin) { //如果是房主或者申请上麦的话则添加视频流
            [peerConnection addStream:_mediaStream];
        }
    } else {
        _mediaStream = [self createLocalMediaStream];
        if (_shangMai || _isAdmin) { //如果是房主或者申请上麦的话则添加视频流
            [peerConnection addStream:_mediaStream];
        }
    }
    [_peers addObject:peerConnection];
    if (!_isAdmin) {
        if (_shangMai) {
            [self sendOffer];
            NSLog(@"因为公聊上麦了故发送 offer");
        }
    }else {
        [self sendOffer];
        NSLog(@"房主发送offer");
    }
}

// 默认peer connection约束
- (RTCMediaConstraints *)defaultPeerConnectionConstraints
{
    NSArray *optionalConstraints = @[[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    return constraints;
}
// 发送offer
- (void)sendOffer {
    RTCPeerConnection *peer = [self findLastConnection];
    [peer createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
}

- (void)agreePubMicOn:(NSNotification *)notification
{
    _allVideos++;
    [JSZUserManager sharedInstance].allVideos = _allVideos;
    NSString *userId = notification.userInfo[@"userId"];
    _secondOffer = YES;
    [_shangMaiUsers addObject:userId];
    
    NSLog(@"_shangMaiUsers = %@ ----------",_shangMaiUsers);
    if (_isAdmin) {
        _sendToId = userId;
        [self startSignalingIfReady];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
}

- (void)agreePrivateMicOn:(NSNotification *)notification
{
    _allVideos++;
    [JSZUserManager sharedInstance].allVideos = _allVideos;
    NSString *userId = notification.userInfo[@"userId"];
    _secondOffer = YES;
    [_shangMaiUsers addObject:userId];
    
    NSLog(@" agreePrivateMicOn shangmai = %@",_shangMaiUsers);
    if (_isAdmin) {
        [self startSignalingIfReady];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"all" object:self];
}
// 默认的offer约束
- (RTCMediaConstraints *)defaultOfferConstraints {
    NSArray *mandatoryConstraints = @[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]];
    
    NSArray *optionals = @[[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionals];
    return constraints;
}

//找到最新活跃的peer_connection websocket open之后就有了
- (RTCPeerConnection *)findLastConnection
{
    return [_peers lastObject];
}


- (RTCMediaConstraints *)defaultMediaStreamConstraints
{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
    return constraints;
}

- (void)pubMicOn:(NSNotification *)notification
{
    if (![NSUserDefaults jsz_turnOn]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        [AlertHelper alertWithText:@"请先开启视频" target:rootViewController];
    }
    [self micVideoOn];
    
    //申请上麦后 从用户列表中删除，添加到麦序列表中
    [[JSZUserManager sharedInstance].userList enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:_userId]) {
            [[JSZUserManager sharedInstance].userList removeObject:obj];
            [[JSZUserManager sharedInstance].miclist addObject:obj];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"all" object:self];
        }
    }];
}
- (void)privatePubMicOn:(NSNotification *)notification{
    if (![NSUserDefaults jsz_turnOn]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        [AlertHelper alertWithText:@"请先开启视频" target:rootViewController];
        return;
    }
    
    [self privateMicVideoOn];
    //申请上麦后 从用户列表中删除，添加到麦序列表中
    
    [[JSZUserManager sharedInstance].userList enumerateObjectsUsingBlock:^(JSZUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:_userId]) {
            [[JSZUserManager sharedInstance].userList removeObject:obj];
            [[JSZUserManager sharedInstance].miclist addObject:obj];
            obj.pubState = PUBSTATEPRIVATE;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"all" object:self];
        }
    }];
    
}


- (void)privateMicVideoOn
{
    [self.webSocket send:[JSZMsgProducer privateMicVideoOnSenderName:self.userName senderId:self.userId]];
}



//STUN Server
- (NSMutableArray *)defaultSTUNServer
{
    NSMutableArray *servers = [NSMutableArray new];
    RTCICEServer *server1 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"stun:turn.jiashizhan.com"] username:@"" password:@""];
    RTCICEServer *server2 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:turn.jiashizhan.com"] username:@"zhimakai" password:@"zhimakai888"];
    RTCICEServer *server3 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"stun:webrtcweb.com:7788"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server4 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:7788"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server5 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turns:webrtcweb.com:7788"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server6 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:8877"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server7 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turns:webrtcweb.com:8877"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server8 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"stun:webrtcweb.com:4455"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server9 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:4455"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server10 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:3344"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server11 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:4433"] username:@"muazkh" password:@"muazkh"];
    RTCICEServer *server12 = [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:webrtcweb.com:5544?transport=tcp"] username:@"muazkh" password:@"muazkh"];
    [servers addObjectsFromArray:@[server1, server2, server3, server4, server5, server6, server7, server8, server9, server10, server11, server12]];
    return servers;
}

- (void)disconnect
{
    if (_state == kARDAppClientStateDisconnected) {
        return;
    }
    if (self.isRegisteredWithRoomServer) {
        [self unregisterWithRoomServer];
    }
    if (_channel) {
        if (_channel.state == kARDWebSocketChannelStateRegistered) {
            ARDByeMessage *byeMessage = [[ARDByeMessage alloc] init];
            NSData *byeData = [byeMessage JSONData];
            [_channel sendData:byeData];
        }
        _channel = nil;
    }
    _roomId = nil;
    _isInitiator = NO;
    _hasReceivedSdp = NO;
    _messageQueue = [NSMutableArray array];
    _state = kARDAppClientStateDisconnected;
}

- (void)unregisterWithRoomServer
{
    [_log removeFromSuperview];
    NSString *urlString = [NSString stringWithFormat:kARDRoomServerByeFormat, self.serverHostUrl, _roomId, _clientId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"C->RS: BYE");
    
    [NSURLConnection sendAsyncPostToURL:url withData:nil completionHandler:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            NSLog(@"注册来自room的服务器");
        }else {
            NSLog(@"失败注册来自room的服务器");
        }
    }];
}

- (BOOL)isRegisteredWithRoomServer
{
    return _clientId.length;
}

- (void)setState:(ARDAppClientState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    [_delegate appClient:self didChangeState:_state];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _mediaStream = nil;
    [self disconnect];
}


@end
