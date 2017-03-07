//
//  FXAnimation.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/2/10.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FXAnimation;

NS_ASSUME_NONNULL_BEGIN

@protocol FXAnimationDelegate <NSObject>

@optional
/**
 Tells the delegate the animation has started.
 */
- (void)fxAnimationDidStart:(FXAnimation *)anim;

/**
 FXAnimation did stop.

 @param anim The FXAnimation's subclass object that has ended.
 @param finished True if animation reached the end of its active duration without being removed.
 */
- (void)fxAnimationDidStop:(FXAnimation *)anim finished:(BOOL)finished;

@end

/**
 This is an abstrct base class, You should use its subclass.
 */
@interface FXAnimation : NSObject

@property (nullable, nonatomic, weak) id<FXAnimationDelegate> delegate;
@property (nullable, nonatomic, copy) NSString *identifier;

+ (instancetype)animation;
/**
 Creates a new animation object with its `identifier' property set to identifier. No need to call super!
 */
+ (instancetype)animationWithIdentifier:(nullable NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
