//
//  JSZAppDelegate.m
//  JSZCode
//
//  Created by hourunjing on 2017/3/28.
//  Copyright © 2017年 JiaShiZhan. All rights reserved.
//

#import "JSZAppDelegate.h"

#import "RTCPeerConnectionFactory.h"
#import "NSUserDefaults+Save.h"

@implementation JSZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [RTCPeerConnectionFactory initializeSSL];  //
    [NSUserDefaults jsz_setTurnOn:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  NSLog(@"applicationWillResignActive");
  
  // [[NSNotificationCenter defaultCenter]
  //  postNotificationName:@"UIApplicationDidEnterBackgroundNotification" object:nil];
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  NSLog(@"applicationDidEnterBackground");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationDidEnterBackgroundNotification" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  NSLog(@"UIApplicationDidBecomeActiveNotification");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationDidBecomeActiveNotification" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [NSUserDefaults jsz_setTurnOn:NO];
    [RTCPeerConnectionFactory deinitializeSSL];
}

@end
