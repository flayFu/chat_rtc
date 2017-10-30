//
//  UIButton+UI.h
//  UZApp
//
//  Created by jiashizhan on 2017/7/12.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSZMediaType.h"
#import "JSZUserMediaState.h"

@interface UIButton (UI)

- (void)turnOnUI:(BOOL)isOn useMediaType:(JSZMediaType)mediaType;

+ (UIButton *)userMediaState:(JSZUserMediaState)state;

- (void)addLayoutAtIndex:(NSUInteger)index from:(UIView *)superView;

@end
