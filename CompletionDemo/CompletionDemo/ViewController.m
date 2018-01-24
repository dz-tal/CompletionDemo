//
//  ViewController.m
//  CompletionDemo
//
//  Created by DLZ on 2018/1/22.
//  Copyright © 2018年 DLZ. All rights reserved.
//

#import "ViewController.h"
#import "MathInfo.h"
#import "MathKeyboardInputView.h"

static const CGFloat line_space = 5;
static const CGFloat font_size = 15;
#define TEX_HOST_URL @"http://cdn.stc.gaokaopai.com/Download/mathpng"

@interface ViewController ()
@property(nonatomic, strong)YYLabel *label;
@property(nonatomic, strong)NSMutableSet *spaceList;
@property(nonatomic, strong)MathKeyboardInputView *keyboardView;
@property(nonatomic, assign)NSRange editRange;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _spaceList = [NSMutableSet new];
    
    NSString *text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"math" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    MathInfo *info = [MathInfo modelWithJSON:text];
    
    _label = [[YYLabel alloc]initWithFrame:CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height+10, self.view.bounds.size.width-20, 0)];
    _label.ignoreCommonProperties = YES;
    _label.fadeOnAsynchronouslyDisplay = NO;
    _label.displaysAsynchronously = YES;
    [self.view addSubview:_label];
    
    _label.textLayout = [self loadData:info.title maxSize:CGSizeMake(_label.width, MAXFLOAT)];
    _label.height = _label.textLayout.textBoundingSize.height+5;
    
    @weakify(self);
    _label.textTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self);
        for(NSValue *value in self.spaceList){
            NSRange itemRange = value.rangeValue;
            if(NSIntersectionRange(range, itemRange).length>0){
                self.editRange = itemRange;
                [self showKeyBoard];
                break;
            }
        }
    };
}

-(void)showKeyBoard{
    if(!_keyboardView){
        @weakify(self);
        _keyboardView = [MathKeyboardInputView createMathKeyboard:^(MTMathList *mathList) {
            @strongify(self);
            [self refreshMathData:mathList];
        }];
    }
    [_keyboardView showMathKeyboard];
}

-(void)refreshMathData:(MTMathList *)mathList{
    MTMathUILabel *label = [[MTMathUILabel alloc]init];
    label.mathList = mathList;
    label.textColor = [UIColor colorWithHexString:@"333333"];
    label.fontSize = font_size;
    label.contentInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    label.textAlignment = kMTTextAlignmentCenter;
    label.size = [label sizeThatFits:label.size];
    
    NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:label contentMode:UIViewContentModeScaleAspectFill attachmentSize:label.size alignToFont:[UIFont systemFontOfSize:font_size] alignment:YYTextVerticalAlignmentCenter];
    [attachText setUnderlineStyle:NSUnderlineStyleSingle range:NSMakeRange(0, attachText.length)];
    attachText.color = [UIColor colorWithHexString:@"333333"];
    attachText.lineSpacing = line_space;
    
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithAttributedString:self.label.textLayout.text];
    [attribute deleteCharactersInRange:self.editRange];
    [attribute insertAttributedString:attachText atIndex:self.editRange.location];
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(self.label.width, MAXFLOAT);
    self.label.textLayout = [YYTextLayout layoutWithContainer:container text:attribute];
    
    for(NSValue *value in self.spaceList){
        NSRange itemRange = value.rangeValue;
        if(NSIntersectionRange(self.editRange, itemRange).length>0){
            [self.spaceList removeObject:value];
            NSRange newRange = NSMakeRange(self.editRange.location, attachText.length);
            [self.spaceList addObject:[NSValue valueWithRange:newRange]];
            break;
        }
    }
}

-(YYTextLayout *)loadData:(NSArray *)list maxSize:(CGSize)maxSize{
    
    UIFont *font = [UIFont systemFontOfSize:font_size];
    
    NSMutableAttributedString *attribute = [NSMutableAttributedString new];
    for(MathItemInfo *itemInfo in list){
        if(itemInfo.value.isNotBlank){
            NSString *type = itemInfo.type;
            NSString *text = itemInfo.value;
            if([type isEqualToString:@"tex"] || [type isEqualToString:@"img"]){//公式图片
                if([text rangeOfString:@"#"].location != NSNotFound){
                    NSString *str = [itemInfo.value substringFromIndex:[text rangeOfString:@"#"].location+1];
                    NSArray *sizeList = [str componentsSeparatedByString:@"*"];
                    if(sizeList.count >= 2){
                        CGFloat w = [sizeList.firstObject floatValue];
                        CGFloat h = [sizeList.lastObject floatValue];
                        if([type isEqualToString:@"tex"]){
                            w /= 2;
                            h /= 2;
                        }
                        
                        CGFloat rate = w/h;
                        if(rate >= 1){
                            CGFloat maxWidth = kScreenWidth - 30;
                            if(w > maxWidth){
                                w = maxWidth;
                                h = w / rate;
                            }
                        }else{
                            CGFloat maxHeight = kScreenHeight * 2 / 3;
                            if(h > maxHeight){
                                h = maxHeight;
                                w = h * rate;
                            }
                        }
                        
                        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageView.clipsToBounds = YES;
                        NSString *url = [NSString stringWithFormat:@"%@/%@",TEX_HOST_URL,text];
                        imageView.imageURL = [NSURL URLWithString:url];
                        
                        NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFill attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
                        attachText.lineSpacing = line_space;
                        [attribute appendAttributedString:attachText];
                    }
                }
            }else if([type isEqualToString:@"lex"]){//公式
                MTMathUILabel *label = [[MTMathUILabel alloc]init];
                label.latex = text;
                label.textColor = [UIColor colorWithHexString:@"333333"];
                label.fontSize = font_size;
                label.contentInsets = UIEdgeInsetsMake(0, 2, 0, 2);
                label.textAlignment = kMTTextAlignmentCenter;
                label.size = [label sizeThatFits:label.size];
                
                NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:label contentMode:UIViewContentModeScaleAspectFill attachmentSize:label.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
                attachText.lineSpacing = line_space;
                [attribute appendAttributedString:attachText];
                
            }else if([type isEqualToString:@"space"]){//填空题输入框
                NSMutableAttributedString *spaceAttribute = [[NSMutableAttributedString alloc]initWithString:text];
                spaceAttribute.lineSpacing = line_space;
                spaceAttribute.font = font;
                [attribute appendAttributedString:spaceAttribute];
                
                NSRange range = NSMakeRange(attribute.length-spaceAttribute.length, spaceAttribute.length);
                [_spaceList addObject:[NSValue valueWithRange:range]];
                
            }else{//文本
                NSMutableAttributedString *txtAttribute = [[NSMutableAttributedString alloc]initWithString:text];
                txtAttribute.lineSpacing = line_space;
                if([type isEqualToString:@"b"]){//加粗
                    txtAttribute.font = [UIFont boldSystemFontOfSize:font_size];
                }else if([type isEqualToString:@"i"]){//倾斜
                    txtAttribute.font = [UIFont italicSystemFontOfSize:font_size];
                }else{
                    txtAttribute.font = font;
                    if([type isEqualToString:@"u"] || [type isEqualToString:@"w"] || [type isEqualToString:@"d"]){//统一用下划线(u:下划线 w:波浪线 d:点)
                        [txtAttribute setUnderlineStyle:NSUnderlineStyleSingle range:NSMakeRange(0, txtAttribute.length)];
                    }
                }
                [attribute appendAttributedString:txtAttribute];
            }
        }
    }
    
    attribute.color = UIColorHex(@"333333");
    YYTextContainer *container = [YYTextContainer new];
    container.size = maxSize;
    return [YYTextLayout layoutWithContainer:container text:attribute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
