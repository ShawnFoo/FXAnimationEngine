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

- (NSUInteger)repeats {
    return _repeats > 0 ? _repeats : 1;
}

- (void)setFrameImages:(NSArray<UIImage *> *)frameImages {
    _frameImages = [frameImages copy];
    if (_frameImages) {
        self.p_count = _frameImages.count;
    }
    if (0 == self.duration) {
        self.duration = _frameImages.count * _p_interval;
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    self.p_interval = _duration / self.frameImages.count;
}

#pragma mark - Initilizer
- (instancetype)init {
    if (self = [super init]) {
        _p_interval = 1 / 30.0;
    }
    return self;
}

@end
