//
//  GiftAnimationConfig.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftAnimationGroup.h"

@implementation GiftAnimationGroup

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"animations": [GiftAnimation class]
             };
}

@end
