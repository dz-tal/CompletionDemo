//
//  MathInfo.m
//  CompletionDemo
//
//  Created by DLZ on 2018/1/22.
//  Copyright © 2018年 DLZ. All rights reserved.
//

#import "MathInfo.h"

@implementation MathItemInfo

@end

@implementation MathInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"title" : [MathItemInfo class]};
}

@end
