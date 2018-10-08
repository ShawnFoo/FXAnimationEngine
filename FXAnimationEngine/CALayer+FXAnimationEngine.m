//
//  UIView+FXAnimationEngine.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/28.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import <objc/runtime.h>

#import "CADisplayLink+FXWeakTarget.h"
#import "CALayer+FXAnimationEngine.h"
#import "FXAnimaionEngineMacro.h"
#import "FXAnimationGroup_Private.h"
#import "FXImageDecodeOperation.h"
#import "FXKeyframeAnimation_Private.h"
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
@property (nonatomic, assign, getter=isAsyncDecodeImage) BOOL asyncDecodeImage;
@property (nonatomic, strong) NSOperationQueue *imageDecodeQueue;

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
    } else if ([animation isKindOfClass:[FXAnimationGroup class]]) {
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

#pragma mark Action
- (void)start {
    [self.animationGroup p_mergeAndReverseAnimationFrames];
    self.frameImages = [self.animationGroup.frames mutableCopy];
    self.animationGroup.frames = nil;
    
    self.accumulator = 0;
    self.displayLink =
    [CADisplayLink fx_addDisplayLinkToRunloop:[NSRunLoop mainRunLoop]
                                      forMode:NSRunLoopCommonModes
                                   withTarget:self
                                    actionSEL:@selector(updateKeyframe:)];
    [self notifyDelegateAnimationDidStart:self.animationGroup];
}

- (void)stop {
    [self.imageDecodeQueue cancelAllOperations];
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
    __block BOOL bIsLastRepeat = NO;
    __block NSInteger bImgIndex = -1;
    __block FXKeyframeAnimation *bPlayingAnimation = nil;
    [self calcImageIndexAtTime:self.accumulator
                    returnInfo:^(FXKeyframeAnimation *animation, BOOL lastRepeat, NSInteger reversedImageIndex)
     {
         bPlayingAnimation = animation;
         bIsLastRepeat = lastRepeat;
         bImgIndex = reversedImageIndex;
     }];
    
    self.accumulator += link.duration * link.frameInterval;
    
    if (self.playingAnimation != bPlayingAnimation) {
        [self notifyDelegateAnimationDidStop:self.playingAnimation finished:YES];
        [self notifyDelegateAnimationDidStart:bPlayingAnimation];
    }
    
    self.playingAnimation = bPlayingAnimation;
    if (bImgIndex >= 0) {
        if (bImgIndex != self.currentFrameIndex) {
            self.currentFrameIndex = bImgIndex;
            UIImage *frame = self.frameImages[bImgIndex];
            if (bIsLastRepeat) {
                [self.frameImages removeLastObject];
            }
            if (frame.fx_hasDecoded) { // has decoded image
                self.actor.contents = (__bridge id)frame.CGImage;
            } else {
                __weak typeof(self) weakSelf = self;
                FXImageDecodeCompletedBlk blk = ^(UIImage *decodedImage) {
                    if (!bIsLastRepeat && weakSelf.frameImages.count) {
                        // need repeat, replace raw image with decoded image
                        NSInteger lastIndex = weakSelf.frameImages.count - 1;
                        weakSelf.frameImages[lastIndex] = decodedImage;
                    }
                    weakSelf.actor.contents = (__bridge id)decodedImage.CGImage;
                };
                
                if (self.isAsyncDecodeImage) {
                    // cancel timeout ops
                    [self.imageDecodeQueue cancelAllOperations];
                    [self.imageDecodeQueue addOperation:[[FXImageDecodeOperation alloc] initWithImage:frame completedBlock:blk]];
                } else {
                    blk(frame.fx_decodedImage);
                }
            }
        }
    } else {
        [self notifyDelegateAnimationDidStop:self.playingAnimation finished:YES];
        [self notifyDelegateAnimationDidStop:self.animationGroup finished:YES];
        [self stop];
    }
}

- (void)calcImageIndexAtTime:(NSTimeInterval)time
                  returnInfo:(void (^)(FXKeyframeAnimation *animation, BOOL isLastRepeat, NSInteger reversedImageIndex))returnInfo {
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
            [self calcFrameIndexAtTime:timeDiff
                           inAnimation:animation
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
        self.playedFrames += animation.count;
        self.playedAnimTime += repeatsDuration;
        timeDiff -= repeatsDuration;
        animation = self.nextAnimation;
    } while (animation != nil);
    
    FXRunBlockSafe(returnInfo, nil, YES, -1);
}

- (void)calcFrameIndexAtTime:(NSTimeInterval)time
                 inAnimation:(FXKeyframeAnimation *)animation
                  returnInfo:(void (^)(BOOL isLastRepeat, NSUInteger frameIndex))returnInfo {
    NSUInteger framesCount = animation.count;
    NSUInteger repeat = floor(time / animation.duration);
    NSUInteger frameIndex = floor((time - repeat * animation.duration) / animation.p_interval);
    frameIndex = frameIndex < framesCount ? frameIndex : framesCount-1;
    FXRunBlockSafe(returnInfo, repeat >= animation.repeats-1, frameIndex);
}

#pragma mark Notify Delegate
- (void)notifyDelegateAnimationDidStart:(FXAnimation *)animation {
    id<FXAnimationDelegate> strongDelegate = animation.delegate;
    if (animation && [strongDelegate respondsToSelector:@selector(fxAnimationDidStart:)]) {
        [strongDelegate fxAnimationDidStart:animation];
    }
}

- (void)notifyDelegateAnimationDidStop:(FXAnimation *)animation finished:(BOOL)finished {
    id<FXAnimationDelegate> strongDelegate = animation.delegate;
    if (animation && [strongDelegate respondsToSelector:@selector(fxAnimationDidStop:finished:)]) {
        [strongDelegate fxAnimationDidStop:animation finished:finished];
    }
}

- (void)notifyDelegateEngineDidEndAnimation:(FXAnimation *)animation {
    id<FXAnimationEngineDelegate> strongDelegate = self.delegate;
    if (animation && [strongDelegate respondsToSelector:@selector(engine:didEndFXAnimation:)]) {
        [strongDelegate engine:self didEndFXAnimation:animation];
    }
}

#pragma mark Accessor
- (FXKeyframeAnimation *)nextAnimation {
    NSArray *animations = self.animationGroup.animations;
    NSInteger index = self.playingAnimation ? [animations indexOfObject:self.playingAnimation] + 1 : 0;
    return index < animations.count ? animations[index] : nil;
}

#pragma mark - LazyLoading
- (NSOperationQueue *)imageDecodeQueue {
    if (!_imageDecodeQueue) {
        _imageDecodeQueue = [[NSOperationQueue alloc] init];
        _imageDecodeQueue.maxConcurrentOperationCount = 1;
        _imageDecodeQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    return _imageDecodeQueue;
}

@end


#pragma mark - CALayer + FXAnimationEngine
@implementation CALayer (FXAnimationEngine)

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
- (void)fx_playAnimation:(FXAnimation *)animation {
    [self fx_playAnimation:animation asyncDecodeImage:NO];
}

- (void)fx_playAnimationAsyncDecodeImage:(FXAnimation *)animation {
    [self fx_playAnimation:animation asyncDecodeImage:YES];
}

- (void)fx_playAnimation:(FXAnimation *)animation asyncDecodeImage:(BOOL)asyncDecodeImage {
    [self fx_stopAnimation];
    
    self.fx_engine = [FXAnimationEngine engineWithAnimation:animation actor:self];
    self.fx_engine.asyncDecodeImage = asyncDecodeImage;
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
