//
//  FXKeyframeAnimation.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "FXKeyframeAnimation.h"
#import "FXKeyframeAnimation_Private.h"
#import "FXAnimaionEngineMacro.h"

@implementation FXKeyframeAnimation

#pragma mark - Overrides
+ (instancetype)animation {
    return [FXKeyframeAnimation new];
}

+ (instancetype)animationWithIdentifier:(NSString *)identifier {
    FXKeyframeAnimation *anim = [self animation];
    anim.identifier = identifier;
    return anim;
}

#pragma mark - Accessor
- (NSTimeInterval)p_repeatsDuration {
    return self.repeats * self.duration;
}

- (float)repeats {
    return _repeats > 0 ? _repeats : 1;
}

- (void)setFrames:(NSArray<UIImage *> *)frames {
    _frames = [frames copy];
    self.count = _frames.count;
}

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self updateInterval];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self updateInterval];
}

- (void)updateInterval {
    if (_count > 0) {
        _p_interval = _duration / _count;
    }
}

#pragma mark - Initilizer
- (instancetype)init {
    if (self = [super init]) {
        _p_interval = 1 / 30.0;
    }
    return self;
}

#pragma mark - 
- (void)p_emptyFrames {
    _frames = nil;
}

@end
