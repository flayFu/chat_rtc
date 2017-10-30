//
//  JSZUserMediaState.h
//  UZApp
//
//  Created by hourunjing on 2017/8/10.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#ifndef JSZUserMediaState_h
#define JSZUserMediaState_h

/**
 * 用户可用状态表
 */
typedef enum : NSUInteger {
    JSZUserMediaStatePrivateInfo, ///< 私聊信息显示
    JSZUserMediaStateAtUser, ///< at 用户
    JSZUserMediaStateChatting, ///< 聊天中
    JSZUserMediaStateAudioChat, ///< 音频聊天
    JSZUserMediaStateAudioChatOn, ///< 音频上麦
    JSZUserMediaStateAudioChatOff, ///< 音频下麦
    JSZUserMediaStateAudioChatForbid, ///< 音频禁麦
    JSZUserMediaStatePubChat, ///< 公聊
    JSZUserMediaStatePrivateChat,  ///< 私聊
    JSZUserMediaStateMicOn, ///< 上麦
    JSZUserMediaStateMicOff, ///< 下麦
    JSZUserMediaStateForbiddenMic, ///< 禁麦
    JSZUserMediaStateInvite  ///< 邀请
} JSZUserMediaState;

#endif /* JSZUserMediaState_h */
