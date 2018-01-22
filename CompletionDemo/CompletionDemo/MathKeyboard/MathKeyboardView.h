//
//  MathKeyboardView.h
//  ClassMate
//
//  Created by DLZ on 2018/1/15.
//  Copyright © 2018年 tal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTEditableMathLabel.h"

@interface MathKeyboardView : UIView<MTMathKeyboard>
#pragma mark - MTMathKeyboardTraits
@property (nonatomic) BOOL equalsAllowed;
@property (nonatomic) BOOL fractionsAllowed;
@property (nonatomic) BOOL variablesAllowed;
@property (nonatomic) BOOL numbersAllowed;
@property (nonatomic) BOOL operatorsAllowed;
@property (nonatomic) BOOL exponentHighlighted;
@property (nonatomic) BOOL squareRootHighlighted;
@property (nonatomic) BOOL radicalHighlighted;
//隐藏键盘
- (void)dismissPressed:(id)sender;
//确定
- (void)enterPressed:(id)sender;
@end
