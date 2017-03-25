//
//  UIView+FXAnimationEngine.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXKeyframeAnimation.h"
#import "FXAnimationGroup.h"

@interface CALayer (FXAnimationEngine)

/**
 Is playing FXAnimation in this layer.
 */
@property (nonatomic, readonly) BOOL fx_isAnimating;

/**
 Play FXAnimation and decode all image frames asynchronously.

 @param animation FXAnimationGroup or FXKeyframeAnimation objcet
 */
- (void)fx_playAnimationAsyncDecodeImage:(FXAnimation *)animation;

/**
 Play FXAnimation, but all image frames will all decode in main-thread, same as the thread in which CAAnimation decode image.

 @param animation FXAnimationGroup or FXKeyframeAnimation objcet
 */
- (void)fx_playAnimation:(FXAnimation *)animation;

/**
 Play FXAnimation

 @param animation FXAnimationGroup or FXKeyframeAnimation objcet
 @param asyncDecodeImage Decode image in asynchronous thread or main thread.
 */
- (void)fx_playAnimation:(FXAnimation *)animation asyncDecodeImage:(BOOL)asyncDecodeImage;

/**
 Stop FXAnimation that is playing in this layer.
 */
- (void)fx_stopAnimation;

@end
