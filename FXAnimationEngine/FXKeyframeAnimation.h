//
//  FXKeyframeAnimation.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXAnimation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An object that provides keyframe animation capabilities for engine.
 */
@interface FXKeyframeAnimation : FXAnimation

/** Array of frame images. */
@property (nullable, nonatomic, copy) NSArray<UIImage *> *frameImages;
/** Duration of animation */
@property (nonatomic, assign) NSTimeInterval duration;
/** The repeat count of animation  */
@property (nonatomic, assign) NSUInteger repeats;

@end

NS_ASSUME_NONNULL_END
