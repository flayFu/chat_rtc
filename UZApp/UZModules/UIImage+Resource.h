//
//  UIImage+Resource.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/8.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resource)

+ (nullable UIImage *)imageResourceNamed:(NSString * _Nonnull)name;
+ (nullable UIImage *)imageResourceNamed:(NSString * _Nonnull)name size:(CGSize)size;

@end
