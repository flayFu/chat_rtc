//
//  InputView.m
//  UZApp
//
//  Created by bin wu on 2017/8/4.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "InputView.h"
#import "JSZUserManager.h"
#import "AlertHelper.h"
#import "JSZUser.h"
#import "JSZMsg.h"
#import "JSZMsgManager.h"
#import "UIView+LSExtension.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface InputView ()<UITextViewDelegate>
/***文本输入框最高高度***/
@property (nonatomic, assign)NSInteger textInputMaxHeight;

/***文本输入框高度***/
@property (nonatomic, assign)CGFloat textInputHeight;

/***键盘高度***/
@property (nonatomic, assign)CGFloat keyboardHeight;

/***当前键盘是否可见*/
@property (nonatomic,assign)BOOL keyboardIsVisiable;

@property (nonatomic,assign) CGFloat origin_y;

@end

@implementation InputView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.origin_y = frame.origin.y;
        
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
        

        self.msgTf = [[UITextView alloc] initWithFrame:CGRectMake(5, 6, frame.size.width-5-100, 37)];
        self.msgTf.inputAccessoryView = nil;
        self.msgTf.font = [UIFont systemFontOfSize:15];
        self.msgTf.layer.cornerRadius = 5;
        self.msgTf.layer.borderColor = RGBACOLOR(227, 228, 232, 1).CGColor;
        self.msgTf.layer.borderWidth = 1.0f;
        self.msgTf.layer.masksToBounds = YES;
        self.msgTf.enablesReturnKeyAutomatically = YES;
        [self addSubview:self.msgTf];
        self.msgTf.returnKeyType = UIReturnKeySend;
        self.msgTf.delegate = self;
        
        
        
      
        
        self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendBtn.frame = CGRectMake(self.width - 50 - 10, 6, 50, 30);
        [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.sendBtn.layer.borderWidth = 1.0f;
        self.sendBtn.layer.cornerRadius = 5.0f;

        self.sendBtn.layer.borderColor=[UIColor grayColor].CGColor;
        self.sendBtn.enabled = NO;
        self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.sendBtn setTitleColor:RGBACOLOR(0, 0, 0, 0.2) forState:UIControlStateNormal];
        [self.sendBtn addTarget:self action:@selector(clickSendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendBtn];
        
        self.userListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.userListBtn.frame = CGRectMake(20, 6+6+self.msgTf.frame.size.height, 80, 30);
        [self.userListBtn setTitle:@"选择用户列表" forState:UIControlStateNormal];
        [self.userListBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.userListBtn addTarget:self action:@selector(showUserList:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.userListBtn];
        self.userListBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        
        
        self.startVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        self.startVideo.frame = CGRectMake(frame.size.width/2-40, 6+6+self.msgTf.frame.size.height, 60, 30);
        [self.startVideo setTitle:@"开始视频" forState:UIControlStateNormal];
        [self.startVideo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:self.startVideo];
        self.startVideo.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        
        
        self.privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.privateBtn.frame = CGRectMake(frame.size.width-20-100, 6+6+self.msgTf.frame.size.height, 80, 30);
        [self.privateBtn setTitle:@"是否私聊" forState:UIControlStateNormal];
        [self.privateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:self.privateBtn];
        self.privateBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.privateBtn addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
        
        self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, self.width - 50 - 20, 37)];
        self.placeholderLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.placeholderLabel.font = self.msgTf.font;
        if (!self.placeholderLabel.text.length) {
            self.placeholderLabel.text = @" ";
        }
        [self addSubview:self.placeholderLabel];
        
        
        [self addEventListening];
        

    }
    return self;
}
/**
 *  是否私聊
 *
 */
- (void)changeMode:(UIButton *)btn
{
    if ([self.userListBtn.titleLabel.text isEqualToString:@"选择用户列表"]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        [AlertHelper alertWithText:@"请选择用户" target:rootViewController];
    } else {
        btn.selected = !btn.selected;
//        if (btn.selected) {
//            _sendToId = nil;
        NSString *userName = self.userListBtn.titleLabel.text;
        for (JSZUser *user in [JSZUserManager sharedInstance].atUsers) {
            if ([user.userName isEqualToString:userName]) {
                _sendToId = user.userId;
                NSLog(@"%@", _sendToId);
                NSLog(@"%i", btn.selected);
                break;
            }
        }
            
//        }
        [btn setTitle:@"私聊" forState:UIControlStateSelected];
    }

 
}

-(void)initView
{
    if (!self.textViewMaxLine || self.textViewMaxLine == 0) {
        self.textViewMaxLine = 3;
    }
}

- (void)setTextViewMaxLine:(NSInteger)textViewMaxLine
{
    _textViewMaxLine = textViewMaxLine;
    _textInputMaxHeight = ceil(self.msgTf.font.lineHeight * (textViewMaxLine - 1) +
                               self.msgTf.textContainerInset.top + self.msgTf.textContainerInset.bottom);
    
}
/**
 *  发送信息
 *
 */

- (void)clickSendMsg:(UIButton *)btn
{

    if (![self.msgTf.text isEqualToString:@""]) {
//        JSZMsg *msg = [JSZMsg new];
//       
//        msg.isCome = NO;
       
        
        [self msgToSend:self.msgTf.text private:self.privateBtn.isSelected to:self.sendToId];
//        msg.msg = self.msgTf.text;
//        [[JSZMsgManager sharedInstance].msgs addObject:msg];

    }
  
    self.msgTf.text = nil;
    
    [self textViewDidChange:self.msgTf];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JSZChatviewControllertableView" object:nil];
    
}

- (void)msgToSend:(NSString *)msg private:(BOOL)privateMsg to:(NSString *)target{
    
    JSZMsg *msg1 = [JSZMsg new];
    msg1.isCome = NO;
    
    if (privateMsg) {
        NSString *str1 = [NSString stringWithFormat:@"悄悄对_%@_说:", _sendToId];
        msg = [str1 stringByAppendingString:msg];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"sendtext" object:self userInfo:@{@"msg":msg,@"target":target,@"private":@(privateMsg)}];
        msg1.msg = msg;
        
    
      
    }else{
        if ([self.userListBtn.titleLabel.text isEqualToString:@"选择用户列表"]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"sendtext" object:self userInfo:@{@"msg":msg}];
            msg1.msg = msg;
            NSLog(@"%@", msg);
        }else {
            NSString *str1 = @"@";
            NSString *str2 = @":";
            NSString *string1, *string2;
            
            string1 = [str1 stringByAppendingString:self.userListBtn.titleLabel.text];
            string2 = [string1 stringByAppendingString:str2];
            msg = [string2 stringByAppendingString:msg];
            
            NSLog(@"%@", msg);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendtext" object:self userInfo:@{@"msg":msg}];
            msg1.msg = msg;
        }
        
    }
    [[JSZMsgManager sharedInstance].msgs addObject:msg1];
    
}
/**
 *  用户列表
 *
 */
- (void)showUserList:(UIButton *)sender {
    NSMutableArray *allUsers = [JSZUserManager sharedInstance].atUsers;
    __weak __typeof(self) wSelf = self;
    [AlertHelper sheetWithSelectorName:@"userName" array:[allUsers copy] title:@"选择用户列表" target:nil NextHandlerWithObj:^(NSObject *obj) {
        __strong __typeof(wSelf) sSelf = wSelf;
        if (sSelf) {
            if ([obj isKindOfClass:[JSZUser class]]) {
                JSZUser *user = (JSZUser *)obj;
                [sSelf.userListBtn setTitle:user.userName forState:UIControlStateNormal];
                
            }
        }
    } cancelHandler:^{
        __strong __typeof(wSelf) sSelf = wSelf;
        if (sSelf) {
            [sSelf.userListBtn setTitle:@"选择用户列表" forState:UIControlStateNormal];
            [sSelf.privateBtn setTitle:@"是否私聊" forState:UIControlStateNormal];
            sSelf.sendToId = nil;
        }
    }];
}


// 添加通知
-(void)addEventListening
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}


#pragma mark keyboardnotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:7];
    self.y = keyboardFrame.origin.y - self.height;
    [UIView commitAnimations];
    self.keyboardIsVisiable = YES;
    if (self.keyIsVisiableBlock) {
        self.keyIsVisiableBlock(YES);
    }
}
- (void)keyboardWillHidden:(NSNotification *)notification
{
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.y = self.origin_y;
    }];
    self.keyboardIsVisiable = NO;
    if (self.keyIsVisiableBlock) {
        self.keyIsVisiableBlock(NO);
    }
}

/**
 *  输入框变化
 *
 */
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.placeholderLabel.hidden = textView.text.length;
    if (textView.text.length) {
        self.sendBtn.enabled = YES;
        [self.sendBtn setTitleColor:RGBACOLOR(0, 0, 0, 0.9) forState:UIControlStateNormal];
    }else {
        self.sendBtn.enabled = NO;
        [self.sendBtn setTitleColor:RGBACOLOR(0, 0, 0, 0.2) forState:UIControlStateNormal];
    }
    _textInputHeight = ceilf([self.msgTf sizeThatFits:CGSizeMake(self.msgTf.width, MAXFLOAT)].height);
    
    self.msgTf.scrollEnabled = _textInputHeight > _textInputMaxHeight && _textInputMaxHeight > 0;
    NSLog(@"%i", self.msgTf.scrollEnabled);
    if (self.msgTf.scrollEnabled) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.msgTf.height = 5 + _textInputMaxHeight;
        
        
        self.y = SCREEN_HEIGHT - _keyboardHeight - _textInputMaxHeight  - 30 - 18;
        
        NSLog(@"%lf", _keyboardHeight);
        self.height = _textInputMaxHeight + 30 + 6 + 6 + 6 + 5;
        


        self.userListBtn.y = 6+6+self.msgTf.frame.size.height;
        self.startVideo.y = 6+6+self.msgTf.frame.size.height;
        self.privateBtn.y = 6+6+self.msgTf.frame.size.height;
        [UIView commitAnimations];
       
        
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.msgTf.height = _textInputHeight;
        if (self.y == [UIScreen mainScreen].bounds.size.height - 85) {
            self.y = [UIScreen mainScreen].bounds.size.height - 85;
        } else {
             self.y = SCREEN_HEIGHT - _keyboardHeight - _textInputHeight - 30 - 18;
        }
       
        NSLog(@"%lf", _keyboardHeight);
        self.height = _textInputHeight + 6 + 6 + 6 + 30;
        
        self.userListBtn.y = 6+6+self.msgTf.frame.size.height;
        self.startVideo.y = 6+6+self.msgTf.frame.size.height;
        self.privateBtn.y = 6+6+self.msgTf.frame.size.height;

        [UIView commitAnimations];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
