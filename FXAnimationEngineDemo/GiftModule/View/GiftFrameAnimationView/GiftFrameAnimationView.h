//
//  GiftFrameAnimationView.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/6.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GiftItem;

typedef NS_ENUM(char, GiftFrameAnimationViewPlayMode) {
    GiftFrameAnimationViewPlayFXAnimationMode,
    GiftFrameAnimationViewPlayCAAnimationMode
};

@interface GiftFrameAnimationView : UIView

- (void)addGiftItem:(GiftItem *)item withPlayMode:(GiftFrameAnimationViewPlayMode)playMode;
- (void)stopAnimation;

@end
