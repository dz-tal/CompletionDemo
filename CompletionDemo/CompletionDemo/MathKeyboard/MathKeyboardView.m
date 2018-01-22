//
//  MathKeyboardView.m
//  ClassMate
//
//  Created by DLZ on 2018/1/15.
//  Copyright © 2018年 tal. All rights reserved.
//

#import "MathKeyboardView.h"
#import "MathKeyboardInputView.h"
#import <iosMath/IosMath.h>
#import <iosMath/MTMathAtomFactory.h>

static NSArray *keyboardDatas = nil;

@interface MathKeyboardViewCell : UICollectionViewCell
@property(nonatomic, strong)UILabel *titleLabel;
@end

@implementation MathKeyboardViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"ededed"];
        
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"444444"];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}
    
@end

@interface MathKeyboardView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIInputViewAudioFeedback>
@property (weak, nonatomic) IBOutlet UIView *typeSelectedView;
@property (weak, nonatomic) IBOutlet UIButton *numberBtn;
@property (weak, nonatomic) IBOutlet UIButton *symbolBtn;
@property (weak, nonatomic) IBOutlet UIButton *capLetterBtn;
@property (weak, nonatomic) IBOutlet UIButton *lowLetterBtn;
@property (weak, nonatomic) IBOutlet UIButton *hideKeyboardBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_marginHeight;
@property (weak, nonatomic) UIView<UIKeyInput>* textView;
@end

@implementation MathKeyboardView
    
-(void)awakeFromNib{
    [super awakeFromNib];
    
    _typeSelectedView.layer.cornerRadius = 3;
    _typeSelectedView.clipsToBounds = YES;
    
    _hideKeyboardBtn.layer.cornerRadius = 3;
    _hideKeyboardBtn.clipsToBounds = YES;
    
    _deleteBtn.layer.cornerRadius = 3;
    _deleteBtn.clipsToBounds = YES;
    
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:[MathKeyboardViewCell class] forCellWithReuseIdentifier:@"MathKeyboardViewCell"];
    
    _layout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 0);
    _layout.itemSize = CGSizeMake((kScreenWidth-155)/3, 45);
    _layout.minimumLineSpacing = 5;
    _layout.minimumInteritemSpacing = 5;
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if(keyboardDatas == nil){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MathKeyboard" ofType:@"plist"];
        keyboardDatas = [NSArray arrayWithContentsOfFile:path];
    }
    
    [_hideKeyboardBtn addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn addTarget:self action:@selector(backspacePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (@available(iOS 11.0, *)) {
        CGFloat margin = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        self.layout_marginHeight.constant = margin;
    }
}
    
- (BOOL)enableInputClicksWhenVisible{
    return YES;
}

- (void)playClickForCustomKeyTap{
    [[UIDevice currentDevice] playInputClick];
}
    
//确定
- (void)enterPressed:(id)sender{
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"\n"];
}
//删除
- (void)backspacePressed:(id)sender{
    [self playClickForCustomKeyTap];
    [self.textView deleteBackward];
}

//隐藏键盘
- (void)dismissPressed:(id)sender{
    [self playClickForCustomKeyTap];
    [self.textView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MATH_KEYBOARD object:nil];
}
    
- (IBAction)typeButtonClick:(UIButton *)sender {
    _typeSelectedView.centerY = sender.centerY;
    CGFloat origianY = 0;
    if(sender == _symbolBtn){
        origianY = 200;
    }else if (sender == _capLetterBtn){
        origianY = 400;
    }else if (sender == _lowLetterBtn){
        origianY = self.collectionView.contentSize.height-self.collectionView.height;
    }
    if(self.collectionView.contentOffset.y != origianY){
        [self.collectionView setContentOffset:CGPointMake(0, origianY) animated:NO];
    }
}
    
#pragma mark --UICollectionViewDelegate-
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return keyboardDatas.count;
}
    
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
    
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MathKeyboardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MathKeyboardViewCell" forIndexPath:indexPath];
    NSDictionary *dict = keyboardDatas[indexPath.item];
    cell.titleLabel.text = dict[@"text"];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = keyboardDatas[indexPath.item];
    switch ([dict[@"id"] integerValue]) {
        case 24://指数
        {
            [self.textView insertText:@"^"];
        }
        break;
        case 22://根号
        {
            [self playClickForCustomKeyTap];
//            [self.textView insertText:MTSymbolSquareRoot];
            [self.textView insertText:MTSymbolCubeRoot];
        }
        break;
        case 21://log
        {
            [self playClickForCustomKeyTap];
            [self.textView insertText:@"log"];
            [self.textView insertText:@"_"];
        }
        break;
        case 23://分数
        {
            [self playClickForCustomKeyTap];
            [self.textView insertText:MTSymbolFractionSlash];
        }
        break;
        case 17://大于等于
        {
            [self playClickForCustomKeyTap];
            [self.textView insertText:MTSymbolGreaterEqual];
        }
            break;
        case 18://小于等于
        {
            [self playClickForCustomKeyTap];
            [self.textView insertText:MTSymbolLessEqual];
        }
            break;
        default:
        {
            NSString *text = dict[@"text"];
            [self playClickForCustomKeyTap];
            [self.textView insertText:text];
        }
        break;
    }
}
    
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat centerY = 0;
    CGFloat origianY = scrollView.contentOffset.y;
    if(origianY<200){
        centerY = _numberBtn.centerY;
    }else if (origianY<400){
        centerY = _symbolBtn.centerY;
    }else if (origianY<MIN(600, self.collectionView.contentSize.height-self.collectionView.height)){
        centerY = _capLetterBtn.centerY;
    }else{
        centerY = _lowLetterBtn.centerY;
    }
    if(_typeSelectedView.centerY != centerY){
        _typeSelectedView.centerY = centerY;
    }
}
    
#pragma mark --MTMathKeyboardTraits--
    
- (void)setEqualsAllowed:(BOOL)equalsAllowed{
    _equalsAllowed = equalsAllowed;
}
    
- (void)setNumbersAllowed:(BOOL)numbersAllowed{
    _numbersAllowed = numbersAllowed;
}
    
- (void)setOperatorsAllowed:(BOOL)operatorsAllowed{
    _operatorsAllowed = operatorsAllowed;
}
    
- (void)setVariablesAllowed:(BOOL)variablesAllowed{
    _variablesAllowed = variablesAllowed;
}
    
- (void)setExponentHighlighted:(BOOL)exponentHighlighted{
    _exponentHighlighted = exponentHighlighted;
}
    
- (void)setSquareRootHighlighted:(BOOL)squareRootHighlighted{
    _squareRootHighlighted = squareRootHighlighted;
}
    
- (void)setRadicalHighlighted:(BOOL)radicalHighlighted{
    _radicalHighlighted = radicalHighlighted;
}
    
#pragma mark --MTMathKeyboard--
    
- (void)startedEditing:(UIView<UIKeyInput> *)label{
    self.textView = label;
}
    
- (void)finishedEditing:(UIView<UIKeyInput> *)label{
    self.textView = nil;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
    
@end
