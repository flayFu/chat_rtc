//
//  AlertHelper.m
//  AppRTC
//
//  Created by gaoxiupei on 2017/6/16.
//  Copyright © 2017年 ISBX. All rights reserved.
//

#import "AlertHelper.h"

#import "JSZUser.h"

@implementation AlertHelper

/**
 弹出提示信息
 
 @param text 提示的具体内容
 @param targetVC 弹出框所在的 ViewController
 */
+ (void)alertWithText:(NSString *)text target:(UIViewController *)targetVC {
    UIAlertAction *normalAlertAction = [UIAlertAction actionWithTitle:@"确认"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示信息"
                                                                             message:text
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:normalAlertAction];
    
    [targetVC presentViewController:alertController animated:YES completion:nil];
}
/**
 弹出需要确认处理的消息
 
 @param text 提示处理的具体信息
 @param targetVC 弹出框所在的 ViewController
 @param nextHandler 选择「确认」的下一步处理
 */
+ (void)alertWithText:(NSString *)text target:(UIViewController *)targetVC nextHandler:(NextHandler)nextHandler {
    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              nextHandler();
                                                          }];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:text
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:cancelAlertAction];
    [alertController addAction:okAlertAction];
    
    [targetVC presentViewController:alertController animated:YES completion:nil];
}

+ (void)sheetWithSelectorName:(NSString *)name array:(NSArray *)array
                        title:(NSString *)title target:(UIViewController *)targetVC
           NextHandlerWithObj:(NextHandlerWithObj)nextHandlerWithObj
                cancelHandler:(NextHandler)cancelHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:title
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  cancelHandler();
                                                              }];
    
    [alertController addAction:cancelAlertAction];
    
    for (NSObject *obj in array) {
        SEL selector = NSSelectorFromString(name);
        if ([obj respondsToSelector:selector]) {
            IMP imp = [obj methodForSelector:selector];
            NSString *(*func)(id, SEL) = (void *)imp;
            NSString *subTitle = func(obj, selector);
            if ([obj isKindOfClass:[JSZUser class]] && (!subTitle || ![subTitle isKindOfClass:[NSString class]])) {
                subTitle = [NSString stringWithFormat:@"用户%@",((JSZUser *)obj).userId];
                ((JSZUser *)obj).userName = subTitle;
            }
            
            UIAlertAction *selectorAlertAction = [UIAlertAction actionWithTitle:subTitle
                                                                        style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                                            nextHandlerWithObj(obj);
                                                                        }];
            
            [alertController addAction:selectorAlertAction];
        }
    }
    if (!targetVC) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        targetVC = window.rootViewController;
    }
    [targetVC presentViewController:alertController animated:YES completion:nil];
}

@end
