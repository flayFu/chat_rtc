//
//  JSZCustomFormatter.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/6.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZCustomFormatter.h"
#import "NSString+Time.h"

@implementation JSZCustomFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"❤️ ERROR"; break;
        case DDLogFlagWarning  : logLevel = @"💛 WARNING"; break;
        case DDLogFlagInfo     : logLevel = @"💙 INFO"; break;
        case DDLogFlagDebug    : logLevel = @"💚 DEBUG"; break;
        default                : logLevel = @"💜 VERBOSE"; break;
    }
    
    NSString *dateAndTime = [NSString timeFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;
    NSString *fileName = logMessage.fileName;
    NSString *methodName = logMessage.function;
    NSUInteger lineNumber = logMessage->_line;
    NSString *threadID = logMessage.threadID;
    return [NSString stringWithFormat:@"%@ (%@) %@ [%@(%lu) %@] %@",
            dateAndTime, threadID, logLevel, fileName, (unsigned long)lineNumber, methodName, logMsg];
}

@end
