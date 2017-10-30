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

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
//#import <SocketRocket/SRSocketRocket.h>
#import "RTCVideoTrack.h"
#import "RoomInfo.h"

#import "SocketIO.h"


typedef NS_ENUM(NSInteger, ARDAppClientState) {
    // Disconnected from servers.
    kARDAppClientStateDisconnected,
    // Connecting to servers.
    kARDAppClientStateConnecting,
    // Connected to servers.
    kARDAppClientStateConnected,
};

@class ARDAppClient;
@protocol ARDAppClientDelegate <NSObject>

- (void)appClient:(ARDAppClient *)client
   didChangeState:(ARDAppClientState)state;
//表示开启视频需要渲染，分为房主和用户的情况
- (void)appClient:(ARDAppClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack isAdmin:(BOOL)isAdmin;

- (void)appClient:(ARDAppClient *)client
didReceiveRemoteVideoTracks:(NSArray *)remoteVideoTracks isAdmin:(BOOL)isAdmin;

- (void)appClient:(ARDAppClient *)client
         didError:(NSError *)error;
- (void)isRepeatLoginOffLine:(NSString *)offlineString;

@end

// Handles connections to the AppRTC server for a given room.
@interface ARDAppClient : NSObject
// 公聊上麦
- (void)micVideoOn;
// 公聊下麦
- (void)micVideoDown;
//- (void)sendText;
@property(nonatomic, assign)BOOL turnOn;
@property(nonatomic, readonly) ARDAppClientState state;
@property(nonatomic, weak) id<ARDAppClientDelegate> delegate;
@property(nonatomic, strong) NSString *serverHostUrl;
@property(nonatomic, strong)SRWebSocket *webSocket;

@property(nonatomic, strong) RoomInfo *roomInfo;

- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate;



- (void)connectToRoomWithRoomId:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName adminId:(NSString *)adminId roomName:(NSString *)roomName options:(NSDictionary *)options;



// Disconnects from the AppRTC servers and any connected clients.
- (void)disconnect;

@end