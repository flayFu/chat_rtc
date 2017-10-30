//
//  NSUserDefaults+Save.m
//  UZApp
//
//  Created by hourunjing on 2017/7/31.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "NSUserDefaults+Save.h"

@implementation NSUserDefaults (Save)

+ (void)jsz_setTurnOn:(BOOL)turnOn {
    [[NSUserDefaults standardUserDefaults] setBool:turnOn forKey:@"com.jiashizhan.turnon"];
}

+ (BOOL)jsz_turnOn {
    BOOL turnOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.jiashizhan.turnon"];
    return turnOn;
}

@end
