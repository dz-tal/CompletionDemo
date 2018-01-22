//
//  MathKeyboardInputView.m
//  ClassMate
//
//  Created by DLZ on 2018/1/16.
//  Copyright © 2018年 tal. All rights reserved.
//

#import "MathKeyboardInputView.h"
#import "MTEditableMathLabel.h"
#import "MathKeyboardView.h"
#import "UIColor+YYAdd.h"

@interface MathKeyboardInputView ()<MTEditableMathLabelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIView *inputBgView;
@property (weak, nonatomic) IBOutlet MTEditableMathLabel *editLabel;
@property (strong, nonatomic) MathKeyboardView *keyBoardView;
@property (copy, nonatomic) MathKeyboardViewComplete complete;
@end

@implementation MathKeyboardInputView

//+(instancetype)sharedInstance{
//    static MathKeyboardInputView *keyboard = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        keyboard = [[NSBundle mainBundle] loadNibNamed:@"MathKeyboardInputView" owner:self options:nil][0];
//    });
//    return keyboard;
//}

-(void)awakeFromNib{
    [super awakeFromNib];
    _inputBgView.layer.cornerRadius = 3;
    _inputBgView.clipsToBounds = YES;
    
    _confirmBtn.layer.cornerRadius = 3;
    _confirmBtn.clipsToBounds = YES;
    
    _keyBoardView = [[NSBundle mainBundle] loadNibNamed:@"MathKeyboardView" owner:self options:nil][0];

    _editLabel.keyboard = _keyBoardView;
    _editLabel.highlightColor = UIColorHex(@"eeeeee");
    _editLabel.fontSize = 14;
    _editLabel.delegate = self;
    [_editLabel enableTap:YES];
    
    [_confirmBtn addTarget:self action:@selector(finishEditMath) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMathKeyboard) name:HIDE_MATH_KEYBOARD object:nil];
}
    
+(MathKeyboardInputView *)createMathKeyboard:(MathKeyboardViewComplete)complete{
    NSInteger tag = 998877;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MathKeyboardInputView *inputView = [window viewWithTag:tag];
    if(!inputView){
        inputView = [[NSBundle mainBundle] loadNibNamed:@"MathKeyboardInputView" owner:self options:nil][0];
        inputView.tag = tag;
        inputView.complete = complete;
        
        CGFloat safeMargin = 0;
        if (@available(iOS 11.0, *)) {
            safeMargin = window.safeAreaInsets.bottom;;
        }
        inputView.frame = CGRectMake(0, window.height, window.width, inputView.height+safeMargin);
        [window addSubview:inputView];
    }
    return inputView;
}

-(void)showMathKeyboard{
    if(!self.superview){
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [self.editLabel startEditing];
    
    [UIView animateWithDuration:0.27
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.top = [UIApplication sharedApplication].keyWindow.height-self.height;
                     } completion:nil];
}

//隐藏键盘
-(void)hideMathKeyboard{
    [self removeFromSuperview];
}

-(void)finishEditMath{
    [self hideMathKeyboard];
    if(self.complete){
        self.complete(self.editLabel.mathList);
    }
}

#pragma mark --MTEditableMathLabelDelegate--

- (void)textModified:(MTEditableMathLabel *)label{
    if(label.hasText){
        if(!_confirmBtn.userInteractionEnabled){
            _confirmBtn.userInteractionEnabled = YES;
            _confirmBtn.backgroundColor = [UIColor colorWithHexString:@"52a7ff"];
            [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }else{
        if(_confirmBtn.userInteractionEnabled){
            _confirmBtn.userInteractionEnabled = NO;
            _confirmBtn.backgroundColor = [UIColor colorWithHexString:@"dadada"];
            [_confirmBtn setTitleColor:[UIColor colorWithHexString:@"bebebe"] forState:UIControlStateNormal];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
    
@end
