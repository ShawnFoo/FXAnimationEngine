//
//  GiftFrameAnimationView.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/6.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftFrameAnimationView.h"
#import "FXAnimation.h"
#import "GiftAnimationGroup.h"

@interface GiftFrameAnimationView () <FXAnimationDelegate>

@property (nonatomic, strong) NSMutableArray<GiftAnimationGroup *> *animationGroups;
@property (nonatomic, weak) GiftAnimationGroup *playingAnimationGroup;
@property (nonatomic, weak) CALayer *animtionLayer;

@end

@implementation GiftFrameAnimationView

#pragma mark - Accessor
- (NSMutableArray<GiftAnimationGroup *> *)animationGroups {
    if (!_animationGroups) {
        _animationGroups = [NSMutableArray arrayWithCapacity:1];
    }
    return _animationGroups;
}

- (void)setPlayMode:(GiftFrameAnimationViewPlayMode)playMode {
    
}

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - Views
- (void)commonSetup {
    
}

#pragma mark - Animation Queue

@end
