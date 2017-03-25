//
//  GiftFrameAnimationView.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/6.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftFrameAnimationView.h"
#import <objc/runtime.h>
#import "CALayer+FXAnimationEngine.h"
#import "RACEXTScope.h"
#import "GiftAnimationGroup.h"
#import "GiftItem.h"
#import "GiftResourceLoader.h"

@interface GiftItem (PlayMode)

@property (nonatomic, assign) GiftFrameAnimationViewPlayMode fx_playMode;

@end

@implementation GiftItem (PlayMode)

- (void)setFx_playMode:(GiftFrameAnimationViewPlayMode)fx_playMode {
    objc_setAssociatedObject(self,
                             @selector(fx_playMode),
                             fx_playMode == 0 ? nil : @(fx_playMode),
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (GiftFrameAnimationViewPlayMode)fx_playMode {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

@end


@interface GiftFrameAnimationView ()
<
FXAnimationDelegate
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
, CAAnimationDelegate
#endif
>

@property (nonatomic, strong) NSMutableArray<GiftItem *> *giftItems;
@property (nonatomic, weak) GiftItem *displayingGiftItem;
@property (nonatomic, weak) CALayer *animtionLayer;

@property (nonatomic, readonly) GiftItem *nextGiftItem;
@property (nonatomic, readonly) NSString *caAnimIdentifierKey;

@end

@implementation GiftFrameAnimationView

#pragma mark - Accessor
- (NSMutableArray<GiftItem *> *)giftItems {
    if (!_giftItems) {
        _giftItems = [NSMutableArray arrayWithCapacity:1];
    }
    return _giftItems;
}

- (GiftItem *)nextGiftItem {
    GiftItem *item = [_giftItems firstObject];
    if (item) {
        [_giftItems removeObjectAtIndex:0];
    }
    return item;
}

- (NSString *)caAnimIdentifierKey {
    return @"caAnimIdentifierKey";
}

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && !self.animtionLayer) {
        [self setupAniamtionLayer];
    }
}

#pragma mark - Setup
- (void)commonSetup {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)setupAniamtionLayer {
    CALayer *animationLayer = [CALayer layer];
    animationLayer.frame = self.bounds;
    [self.layer addSublayer:animationLayer];
    self.animtionLayer = animationLayer;
}

- (void)setupLayerPositionForGroup:(GiftAnimationGroup *)group {
    NSAssert(group.width > 0, @"group.width must bigger than zero!");
    
    CGSize viewSize = self.frame.size;
    CGRect toFrame = self.animtionLayer.frame;
    toFrame.size = viewSize;
    toFrame.size.height = (group.height / group.width) * viewSize.width;
    toFrame.origin.y = viewSize.height - group.bottomY * viewSize.height - toFrame.size.height;
    
    self.animtionLayer.frame = toFrame;
}

#pragma mark - Animation Queue
- (void)addGiftItem:(GiftItem *)item withPlayMode:(GiftFrameAnimationViewPlayMode)playMode {
    if (![item isKindOfClass:[GiftItem class]]) {
        return;
    }
    item.fx_playMode = playMode;
    if (!self.displayingGiftItem) {
        [self playAnimationOfGiftItem:item];
    }
    else {
        [self.giftItems addObject:item];
    }
}

#pragma mark - Play Animation
- (void)playAnimationOfGiftItem:(GiftItem *)giftItem {
    self.displayingGiftItem = giftItem;
    GiftFrameAnimationViewPlayMode playMode = giftItem.fx_playMode;
    giftItem.fx_playMode = 0;
    
    NSString *identifier = giftItem.name;
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // put io ops、 convert group ops in global queue
        GiftAnimationGroup *group = [GiftResourceLoader loadAnimationGroupWithGiftId:giftItem.giftId];
        NSArray<UIImage *> *frames = giftItem.imageInfo.animationFrames;
        id fxOrCAAnimationGroup = nil;
        SEL playMethodSEL = NULL;
        switch (playMode) {
            case GiftFrameAnimationViewPlayFXAnimationMode:
                fxOrCAAnimationGroup = [self_weak_ toFXAnimationGroupFrom:group withFrames:frames identifier:identifier];
                playMethodSEL = @selector(playFXAnimationGroup:);
                break;
            case GiftFrameAnimationViewPlayCAAnimationMode:
                fxOrCAAnimationGroup = [self_weak_ toCAAnimationGroupFrom:group withFrames:frames identifier:identifier];
                playMethodSEL = @selector(playCAAnimationGroup:);
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (self) {
                [self setupLayerPositionForGroup:group];
                
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:playMethodSEL]];
                invocation.selector = playMethodSEL;
                [invocation setArgument:(void *)&fxOrCAAnimationGroup atIndex:2];
                [invocation invokeWithTarget:self];
            }
        });
    });
}

- (void)playFXAnimationGroup:(FXAnimationGroup *)group {

    [self.animtionLayer fx_playAnimationAsyncDecodeImage:group];
    // equal to method above
//    [self.animtionLayer fx_playAnimation:group asyncDecodeImage:YES];
}

- (void)playCAAnimationGroup:(CAAnimationGroup *)group {
    [self.animtionLayer addAnimation:group forKey:NSStringFromSelector(_cmd)];
    self.animtionLayer.contents = nil;
}

- (void)didFinishLastAnimation {
    self.displayingGiftItem = nil;
    [self playNextAnimation];
}

- (void)playNextAnimation {
    GiftItem *nextItem = self.nextGiftItem;
    if (nextItem) {
        [self playAnimationOfGiftItem:nextItem];
    }
}

#pragma mrak - AnimtaionType Convert
- (FXAnimationGroup *)toFXAnimationGroupFrom:(GiftAnimationGroup *)group
                                  withFrames:(NSArray<UIImage *> *)frames
                                  identifier:(NSString *)identifier {
    NSMutableArray *animations = [NSMutableArray arrayWithCapacity:group.animations.count];
    for (GiftAnimation *animation in group.animations) {
        FXKeyframeAnimation *fxAnim = [FXKeyframeAnimation animation];
        fxAnim.count = animation.count;
        fxAnim.duration = animation.duration;
        fxAnim.repeats = animation.repeats;
        [animations addObject:fxAnim];
    }
    
    FXAnimationGroup *fxGroup = [FXAnimationGroup animationWithIdentifier:identifier];
    fxGroup.delegate = self;
    fxGroup.frames = frames;
    fxGroup.animations = animations;
    
    return fxGroup;
}

- (CAAnimationGroup *)toCAAnimationGroupFrom:(GiftAnimationGroup *)group
                                  withFrames:(NSArray<UIImage *> *)frames
                                  identifier:(NSString *)identifier {
    // convert to CGImage for CAAnimation contents
    NSMutableArray *cgImages = [NSMutableArray arrayWithCapacity:frames.count];
    for (UIImage *frame in frames) {
        [cgImages addObject:(__bridge id)frame.CGImage];
    }
    
    NSMutableArray *animations = [NSMutableArray arrayWithCapacity:group.animations.count];
    NSUInteger frameIndex = 0;
    NSTimeInterval duration = 0;
    
    for (GiftAnimation *animation in group.animations) {
        NSRange range = NSMakeRange(frameIndex, animation.count);
        if (range.location+range.length > cgImages.count) {
            break;
        }
        NSUInteger repeats = animation.repeats ?: 1;
        CAKeyframeAnimation *caAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        caAnim.values = [cgImages subarrayWithRange:range];
        caAnim.duration = animation.duration;
        caAnim.repeatCount = repeats;
        caAnim.beginTime = duration;
//        caAnim.calculationMode = kCAAnimationDiscrete;
        [animations addObject:caAnim];
        
        frameIndex += animation.count;
        duration += animation.duration * repeats;
    }
    CAAnimationGroup *caGroup = [CAAnimationGroup animation];
    [caGroup setValue:identifier forKey:self.caAnimIdentifierKey];
    caGroup.animations = animations;
    caGroup.duration = duration;
    caGroup.delegate = self;
    
    return caGroup;
}

#pragma mark - FXAnimationDelegate
- (void)fxAnimationDidStart:(FXAnimation *)anim {
    NSLog(@"fxAnimationDidStart: %@", anim.identifier);
}

- (void)fxAnimationDidStop:(FXAnimation *)anim finished:(BOOL)finished {
    NSLog(@"fxAnimationDidStop: %@, finished: %@", anim.identifier, @(finished));
    [self didFinishLastAnimation];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"caAnimationDidStart: %@", [anim valueForKey:self.caAnimIdentifierKey]);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"caAnimationDidStop: %@, finished: %@", [anim valueForKey:self.caAnimIdentifierKey], @(flag));
    
    [self.animtionLayer removeAllAnimations];
    [self didFinishLastAnimation];
}

@end
