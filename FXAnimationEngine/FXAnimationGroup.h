//
//  FXAnimationGroup.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXAnimation.h"
#import "FXKeyframeAnimation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An object that allows multiple FXKeyframeAnimations to be grouped and run serially.
 */
@interface FXAnimationGroup : FXAnimation

/** An array of FXAnimation objects. */
@property (nullable, nonatomic, copy) NSArray<__kindof FXAnimation *> *animations;
/** All frames in sequence. If you set this property of animationGroup object, then engine won't access frames from each animation. */
@property (nullable, nonatomic, copy) NSArray<UIImage *> *frames;

@end

NS_ASSUME_NONNULL_END
