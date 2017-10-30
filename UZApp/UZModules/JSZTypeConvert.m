//
//  JSZTypeConvert.m
//  UZApp
//
//  Created by hourunjing on 2017/7/31.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "JSZTypeConvert.h"

@implementation JSZTypeConvert

+ (NSString *)jsonToString:(NSDictionary *)dict {
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
