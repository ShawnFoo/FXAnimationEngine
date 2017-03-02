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

/** An array of FXAnimation objects. Animations will be run in sequence. */
@property (nullable, nonatomic, copy) NSArray<__kindof FXAnimation *> *animations;

@end

NS_ASSUME_NONNULL_END
