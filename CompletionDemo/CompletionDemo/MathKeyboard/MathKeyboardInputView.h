//
//  MathKeyboardInputView.h
//  ClassMate
//
//  Created by DLZ on 2018/1/16.
//  Copyright © 2018年 tal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iosMath/IosMath.h>

#define HIDE_MATH_KEYBOARD   @"hide_math_keyboard"

typedef void(^MathKeyboardViewComplete) (MTMathList *mathList);

@interface MathKeyboardInputView : UIView
+(MathKeyboardInputView *)createMathKeyboard:(MathKeyboardViewComplete)complete;
-(void)showMathKeyboard;
-(void)hideMathKeyboard;
@end
