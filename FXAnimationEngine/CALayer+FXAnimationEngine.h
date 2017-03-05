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

@property (nonatomic, readonly) BOOL fx_isAnimating;

- (void)fx_playAnimation:(FXAnimation *)animation;
- (void)fx_playAnimationAsyncDecodeImage:(FXAnimation *)animation;
- (void)fx_playAnimation:(FXAnimation *)animation asyncDecodeImage:(BOOL)asyncDecodeImage;

- (void)fx_stopAnimation;

@end
