//
//  CADisplayLink+FXWeakTarget.h
//  FXKit
//
//  Created by ShawnFoo on 16/6/14.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^fx_displayLink_callback)(CADisplayLink *link);

/**
 弱引用Target的CADisplayLink. 当Target释放时, 若CADisplayLink仍在执行, 则会被invalidate掉.
 */
@interface CADisplayLink (FXWeakTarget)

/**
 创建一个新的DisplayLink对象, 并以DefaultMode添加DisplayLink到当前RunLoop中

 @param target 关联目标对象. 当该对象被释放时, 若对应的CADisplayLink仍在执行, 则会调用invlidate使其失效
 @param callback DisplayLink触发时的回调block
 */
+ (CADisplayLink *)fx_addDisplayLinkToCurrentRunloopForDefaultModeWithTarget:(id)target
																	callback:(fx_displayLink_callback)callback;


/**
 创建一个新的DisplayLink对象, 并以DefaultMode添加DisplayLink到当前RunLoop中

 @param target 关联目标对象. 当该对象被释放时, 若对应的CADisplayLink仍在执行, 则会调用invlidate使其失效
 @param actionSEL DisplayLink触发时调用Target的Action Selector
 */
+ (CADisplayLink *)fx_addDisplayLinkToCurrentRunloopForDefaultModeWithTarget:(id)target
																	actionSEL:(SEL)actionSEL;


/**
 创建一个新的DisplayLink对象, 并以指定的Mode添加DisplayLink到指定的RunLoop中

 @param loop CADisplayLink加入的RunLoop
 @param mode CADisplayLink添加到RunLoop中的模式
 @param target 关联目标对象. 当该对象被释放时, 若对应的CADisplayLink仍在执行, 则会调用invlidate使其失效
 @param callback DisplayLink触发时的回调block
 */
+ (CADisplayLink *)fx_addDisplayLinkToRunloop:(nullable NSRunLoop *)loop
									  forMode:(nullable NSString *)mode
								   withTarget:(id)target
									 callback:(fx_displayLink_callback)callback;


/**
 创建一个新的DisplayLink对象, 并以指定的Mode添加DisplayLink到指定的RunLoop中
 
 @param loop CADisplayLink加入的RunLoop
 @param mode CADisplayLink添加到RunLoop中的模式
 @param target 关联目标对象. 当该对象被释放时, 若对应的CADisplayLink仍在执行, 则会调用invlidate使其失效
 @param actionSEL DisplayLink触发时调用Target的Action Selector
 */
+ (CADisplayLink *)fx_addDisplayLinkToRunloop:(nullable NSRunLoop *)loop
									  forMode:(nullable NSString *)mode
								   withTarget:(id)target
									actionSEL:(SEL)actionSEL;

@end

NS_ASSUME_NONNULL_END
