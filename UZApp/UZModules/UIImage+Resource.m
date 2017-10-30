//
//  UIImage+Resource.m
//  UZApp
//
//  Created by jiashizhan on 2017/7/8.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "UIImage+Resource.h"

@implementation UIImage (Resource)

/**
 * 根据资源名称返回图片
 
 @param name 资源名称
 @return 返回图片
 */
+ (nullable UIImage *)imageResourceNamed:(NSString * _Nonnull)name {
    return [self imageResourceNamed:name size:CGSizeZero];
}

/**
 * 根据资源名称返回图片

 @param name 资源名称
 @param size 图片尺寸，CGSizeZero：不改变原有图片尺寸
 @return 返回图片
 */
+ (UIImage *)imageResourceNamed:(NSString *)name size:(CGSize)size {
    NSString *resName = [NSString stringWithFormat:@"res_chatRoomModule/%@.png", name];
    NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:resName];
    
    UIImage *originImage = [UIImage imageWithContentsOfFile:path];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return originImage;
    }
    return [self resizeImage:originImage imageSize:size];
}

+ (UIImage *)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
}

@end
