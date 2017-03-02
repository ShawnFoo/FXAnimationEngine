//
//  FXKeyframeAnimation_Private.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/2/10.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "FXKeyframeAnimation.h"

@interface FXKeyframeAnimation ()

@property (nonatomic, assign) NSTimeInterval p_interval;
@property (nonatomic, readonly) NSTimeInterval p_repeatsDuration;

- (void)p_emptyFrames;

@end
