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

@interface UIView (FXAnimationEngine)

@property (nonatomic, readonly) BOOL fx_isAnimating;

- (void)fx_startAnimation:(FXAnimation *)animation;
- (void)fx_stopAnimation;

@end
