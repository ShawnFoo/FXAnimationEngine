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

#pragma mark - Private Methods
- (void)p_mergeAndReverseAnimationFrames {
    BOOL hasReleaseAnimationFrames = NO;
    if (!self.frames.count) {
        NSMutableArray *allFrames = [NSMutableArray array];
        for (FXKeyframeAnimation *animation in self.animations.reverseObjectEnumerator) {
            for (UIImage *image in animation.frames.reverseObjectEnumerator) {
                [allFrames addObject:image];
            }
            [animation p_emptyFrames];
        }
        self.frames = [allFrames copy];
        hasReleaseAnimationFrames = YES;
    } else {
        self.frames = [[self.frames reverseObjectEnumerator] allObjects];
    }
    
    if (!hasReleaseAnimationFrames) {
        for (FXKeyframeAnimation *animation in self.animations) {
            [animation p_emptyFrames];
        }
    }
    
    self.p_framesCount = self.frames.count;
}

@end
