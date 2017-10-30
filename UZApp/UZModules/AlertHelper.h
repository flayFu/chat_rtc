//
//  AlertHelper.h
//  AppRTC
//
//  Created by gaoxiupei on 2017/6/16.
//  Copyright © 2017年 ISBX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NextHandler)(void);
typedef void(^NextHandlerWithObj)(NSObject *obj);

@interface AlertHelper : NSObject

+ (void)alertWithText:(NSString *)text target:(UIViewController *)targetVC;

+ (void)alertWithText:(NSString *)text target:(UIViewController *)targetVC nextHandler:(NextHandler)nextHandler;

+ (void)sheetWithSelectorName:(NSString *)name array:(NSArray *)array
                        title:(NSString *)title target:(UIViewController *)targetVC
           NextHandlerWithObj:(NextHandlerWithObj)NextHandlerWithObj
                cancelHandler:(NextHandler)cancelHandler;

@end
