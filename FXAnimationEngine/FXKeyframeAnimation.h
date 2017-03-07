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

/** Array of images. If you set image frames, you don't need to set count any more. */
@property (nullable, nonatomic, copy) NSArray<UIImage *> *frames;
/** The images count. If you set all frames in animationGroup, then you have to set this property. */
@property (nonatomic, assign) NSUInteger count;
/** Duration of animation */
@property (nonatomic, assign) NSTimeInterval duration;
/** The repeat count of animation  */
@property (nonatomic, assign) float repeats;

@end

NS_ASSUME_NONNULL_END
