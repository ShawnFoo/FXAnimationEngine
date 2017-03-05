//
//  GiftAnimationConfig.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftAnimation.h"

@interface GiftAnimationGroup : NSObject

@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float bottomY;
@property (nonatomic, copy) NSArray<GiftAnimation *> *animations;

@end
