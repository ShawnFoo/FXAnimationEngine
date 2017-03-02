//
//  FXAnimationGroup.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "FXAnimationGroup.h"
#import "FXKeyframeAnimation_Private.h"
#import "FXAnimationGroup_Private.h"
#import "FXAnimaionEngineMacro.h"

@implementation FXAnimationGroup

#pragma mark - Overrides
+ (instancetype)animation {
    return [FXAnimationGroup new];
}

+ (instancetype)animationWithIdentifier:(NSString *)identifier {
    FXAnimationGroup *group = [self animation];
    group.identifier = identifier;
    return group;
}

#pragma mark - Accessor
- (void)setAnimations:(NSArray<__kindof FXAnimation *> *)animations {
    _animations = [animations copy];
    NSUInteger framesCount = 0;
    for (FXKeyframeAnimation *anim in _animations) {
        framesCount += anim.frameImages.count;
    }
    self.p_framesCount = framesCount;
}

- (NSMutableArray<UIImage *> *)p_reverseFrames {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:self.p_framesCount];
    for (FXKeyframeAnimation *animation in self.animations.reverseObjectEnumerator) {
        for (UIImage *image in animation.frameImages.reverseObjectEnumerator) {
            [frames addObject:image];
        }
        animation.frameImages = nil;
    }
    return frames;
}

@end
