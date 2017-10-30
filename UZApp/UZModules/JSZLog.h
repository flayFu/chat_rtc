//
//  JSZLog.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifndef JSZLog_h
#define JSZLog_h

#ifndef JSZLogsEnabled
    #ifdef DEBUG
        #define JSZLogsEnabled 1
        //Simple log macro
        #define DLog(s,...) NSLog((@"[%s] " s),__func__,## __VA_ARGS__);
    #else
        #define JSZLogsEnabled 0
        //Log only in debug mode
        #define DLog(...)
    #endif
#endif

#ifndef JSZLogLevel
    #define JSZLogLevel DDLogLevelVerbose
#endif

#if JSZLogsEnabled
    static const int ddLogLevel = JSZLogLevel;
#else
    static const int ddLogLevel = 0;
#endif

#endif /* JSZLog_h */
