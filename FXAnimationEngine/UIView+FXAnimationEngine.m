//
//  UIView+FXAnimationEngine.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "UIView+FXAnimationEngine.h"
#import <objc/runtime.h>
#import "FXAnimaionEngineMacro.h"
#import "FXAnimationGroup_Private.h"
#import "FXKeyframeAnimation_Private.h"
#import "NSTimer+FXWeakTimer.h"
#import "UIImage+FXDecoder.h"

#pragma mark - FXAnimationEngineDelegate
@class FXAnimationEngine;
@protocol FXAnimationEngineDelegate <NSObject>

- (void)engine:(FXAnimationEngine *)engine didEndFXAnimation:(FXAnimation *)animation;

@end

#pragma mark - FXAnimationEngine
@interface FXAnimationEngine : NSObject

@property (nonatomic, weak) CALayer *actor;
@property (nonatomic, weak) id<FXAnimationEngineDelegate> delegate;

@property (nonatomic, strong) FXAnimationGroup *animationGroup;
@property (nonatomic, weak) FXKeyframeAnimation *playingAnimation;
@property (nonatomic, strong) NSMutableArray<UIImage *> *frameImages;

@property (nonatomic, weak) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval accumulator;
@property (nonatomic, assign) NSUInteger currentFrameIndex;

@property (nonatomic, readonly) FXKeyframeAnimation *nextAnimation;
@property (nonatomic, assign) NSTimeInterval lastQueryTime;
@property (nonatomic, assign) NSTimeInterval playedAnimTime;
@property (nonatomic, assign) NSUInteger playedFrames;

@end

@implementation FXAnimationEngine

#pragma mark Factory
+ (instancetype)engineWithAnimation:(__kindof FXAnimation *)animation actor:(CALayer *)actor {
    NSAssert(actor != nil, @"Actor can't be nil!");
    
    FXAnimationGroup *animGroup = nil;
    if ([animation isMemberOfClass:[FXKeyframeAnimation class]]) {
        animGroup = [FXAnimationGroup animation];
        animGroup.animations = @[animation];
    }
    else if ([animation isKindOfClass:[FXAnimationGroup class]]) {
        animGroup = animation;
    }
    if (animGroup) {
        FXAnimationEngine *engine = [FXAnimationEngine new];
        engine.animationGroup = animGroup;
        engine.actor = actor;
        return engine;
    }
    FXException(@"The pass-in animation(%s) is not kind of FXAnimation. (FXAnimation is an abstrct base class, You should use its subclass.)", class_getName([animation class]));
    return nil;
}

#pragma mark Accessor
- (FXKeyframeAnimation *)nextAnimation {
    NSArray *animations = self.animationGroup.animations;
    NSInteger index = self.playingAnimation ? [animations indexOfObject:self.playingAnimation] : NSNotFound;
    if (NSNotFound == index) {
        return animations.firstObject;
    }
    else if (index+1 >= animations.count) {
        return nil;
    }
    return animations[index+1];
}

#pragma mark Action
- (void)start {
    self.frameImages = self.animationGroup.p_reverseFrames;
    self.accumulator = 0;
    self.displayLink =
    [CADisplayLink fx_displayLinkWithTarget:self
                                   selector:@selector(updateKeyframe:)
                                    runloop:[NSRunLoop mainRunLoop]
                                       mode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.displayLink invalidate];
    self.displayLink = nil;
    
    self.frameImages = nil;
    self.actor.contents = nil;
    
    if (self.playingAnimation) {
        NSUInteger indexOfPlayingAnim = [self.animationGroup.animations indexOfObject:self.playingAnimation];
        for (NSUInteger i = indexOfPlayingAnim; i < self.animationGroup.animations.count; i++) {
            FXAnimation *anim = self.animationGroup.animations[i];
            [self notifyDelegateAnimationDidStop:anim finished:NO];
        }
        [self notifyDelegateAnimationDidStop:self.animationGroup finished:NO];
        self.playingAnimation = nil;
    }
    [self notifyDelegateEngineDidEndAnimation:self.animationGroup];
    
    self.animationGroup = nil;
    self.currentFrameIndex = 0;
    self.playedAnimTime = 0;
    self.playedFrames = 0;
}

#pragma mark Keyframe Update
- (void)updateKeyframe:(CADisplayLink *)link {
    self.accumulator += link.duration * link.frameInterval;
    
    __block BOOL bIsLastRepeat = NO;
    __block NSInteger bImgIndex = -1;
    __block FXKeyframeAnimation *bPlayingAnimation = nil;
    [self imageIndexAtTime:self.accumulator
                returnInfo:^(FXKeyframeAnimation *animation, BOOL lastRepeat, NSInteger reversedImageIndex)
     {
         bPlayingAnimation = animation;
         bIsLastRepeat = lastRepeat;
         bImgIndex = reversedImageIndex;
     }];
    
    if (self.playingAnimation != bPlayingAnimation) {
        [self notifyDelegateAnimationDidStop:self.playingAnimation finished:YES];
        [self notifyDelegateAnimationWillStart:bPlayingAnimation];
    }
    
    self.playingAnimation = bPlayingAnimation;
    if (bImgIndex >= 0) {
        if (bImgIndex != self.currentFrameIndex) {
            CALayer *strongActor = self.actor;
            if (strongActor) {
                self.currentFrameIndex = bImgIndex;
                CGImageRef copyImageRef = [self.frameImages[bImgIndex] fx_decodedCGImageRefCopy];
                strongActor.contents = (__bridge id)copyImageRef;
                if (bIsLastRepeat) {
                    [self.frameImages removeLastObject];
                }
            }
            else {
                [self stop];
            }
        }
    }
    else {
        [self notifyDelegateAnimationDidStop:self.playingAnimation finished:YES];
        [self notifyDelegateAnimationDidStop:self.animationGroup finished:YES];
        self.playingAnimation = nil;
        [self stop];
    }
}

- (void)imageIndexAtTime:(NSTimeInterval)time
              returnInfo:(void (^)(FXKeyframeAnimation *animation, BOOL isLastRepeat, NSInteger reversedImageIndex))returnInfo
{
    if (time < self.lastQueryTime) {
        self.playedFrames = 0;
        self.playedAnimTime = 0;
    }
    
    NSTimeInterval timeDiff = time - self.playedAnimTime;
    if (timeDiff < 0) {
        timeDiff = time;
    }
    
    NSUInteger framesCount = self.animationGroup.p_framesCount;
    FXKeyframeAnimation *animation = self.playingAnimation ?: self.nextAnimation;
    NSTimeInterval repeatsDuration = animation.p_repeatsDuration;
    do {
        if (timeDiff < repeatsDuration) {
            __block BOOL bIsLastRepeat;
            __block NSUInteger bFrameIndex;
            [self frameIndexAtTime:timeDiff
                       ofAnimation:animation
                        returnInfo:^(BOOL isLastRepeat, NSUInteger frameIndex)
             {
                 bIsLastRepeat = isLastRepeat;
                 bFrameIndex = frameIndex;
             }];
            self.lastQueryTime = time;
            NSUInteger reversedIndex = framesCount - (self.playedFrames+bFrameIndex) - 1;
            FXRunBlockSafe(returnInfo, animation, bIsLastRepeat, reversedIndex);
            return;
        }
        self.playedFrames += animation.p_count;
        self.playedAnimTime += repeatsDuration;
        timeDiff -= repeatsDuration;
        animation = self.nextAnimation;
    } while (animation != nil);
    
    FXRunBlockSafe(returnInfo, nil, YES, -1);
}

- (void)frameIndexAtTime:(NSTimeInterval)time
             ofAnimation:(FXKeyframeAnimation *)animation
              returnInfo:(void (^)(BOOL isLastRepeat, NSUInteger frameIndex))returnInfo {
    
    NSUInteger framesCount = animation.p_count;
    NSUInteger repeat = floor(time / animation.duration);
    NSUInteger frameIndex = floor((time - repeat * animation.duration) / animation.p_interval);
    frameIndex = frameIndex < framesCount ? frameIndex : framesCount-1;
    FXRunBlockSafe(returnInfo, repeat >= animation.repeats-1, frameIndex);
}

#pragma mark Notify Delegate
- (void)notifyDelegateAnimationWillStart:(FXAnimation *)animation {
    id<FXAnimationDelegate> strongDelegate = animation.delegate;
    if ([strongDelegate respondsToSelector:@selector(fxAnimationWillStart:)]) {
        [strongDelegate fxAnimationWillStart:animation];
    }
}

- (void)notifyDelegateAnimationDidStop:(FXAnimation *)animation finished:(BOOL)finished {
    id<FXAnimationDelegate> strongDelegate = animation.delegate;
    if ([strongDelegate respondsToSelector:@selector(fxAnimationDidStop:finished:)]) {
        [strongDelegate fxAnimationDidStop:animation finished:finished];
    }
}

- (void)notifyDelegateEngineDidEndAnimation:(FXAnimation *)animation {
    id<FXAnimationEngineDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(engine:didEndFXAnimation:)]) {
        [strongDelegate engine:self didEndFXAnimation:animation];
    }
}

@end


#pragma mark - UIView + FXAnimationEngine
@implementation UIView (FXAnimationEngine)

#pragma mark Accessor
- (void)setFx_engine:(FXAnimationEngine *)fx_engine {
    objc_setAssociatedObject(self,
                             @selector(fx_engine),
                             fx_engine,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FXAnimationEngine *)fx_engine {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)fx_isAnimating {
    return self.fx_engine != nil;
}

#pragma mark Animation
- (void)fx_startAnimation:(FXAnimation *)animation {
    [self fx_stopAnimation];
    
    self.fx_engine = [FXAnimationEngine engineWithAnimation:animation actor:self.layer];
    self.fx_engine.delegate = (id<FXAnimationEngineDelegate>)self;
    [self.fx_engine start];
}

- (void)fx_stopAnimation {
    if (self.fx_engine) {
        [self.fx_engine stop];
        self.fx_engine = nil;
    }
}

#pragma mark FXAnimationEngineDelegate
- (void)engine:(FXAnimationEngine *)engine didEndFXAnimation:(FXAnimation *)animation {
    self.fx_engine = nil;
}

@end
