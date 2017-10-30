//
//  InputView.h
//  UZApp
//
//  Created by bin wu on 2017/8/4.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputView;

@protocol InputViewDelegate <NSObject>

@optional

@end

@interface InputView : UIView

@property(nonatomic, strong) UIButton *privateBtn; 
@property(nonatomic, strong) UIButton *userListBtn;
@property(nonatomic, strong) UIButton *startVideo;

@property(nonatomic, strong) UITextView *msgTf;
@property(nonatomic, copy)NSString *sendToId;
@property(nonatomic, strong) UIButton *sendBtn;

@property(nonatomic, assign) id<InputViewDelegate>delegate;

/**
 *  textView占位符
 */
@property (nonatomic,strong)UILabel *placeholderLabel;
/**
 *  设置输入框最大行数
 */
@property (nonatomic,assign)NSInteger textViewMaxLine;

@property (nonatomic, copy) void (^keyIsVisiableBlock)(BOOL keyboardIsVisiable);

@end
