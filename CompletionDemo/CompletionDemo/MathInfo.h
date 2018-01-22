//
//  MathInfo.h
//  CompletionDemo
//
//  Created by DLZ on 2018/1/22.
//  Copyright © 2018年 DLZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathItemInfo : NSObject
@property(nonatomic, strong)NSString *value;
@property(nonatomic, strong)NSString *type;
@end

@interface MathInfo : NSObject
@property(nonatomic, strong)NSArray *title;
@end
