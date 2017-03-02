//
//  NSTimer+FXWeakTimer.h
//  FXWeakTimer
//
//  Created by ShawnFoo on 16/6/14.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void (^FXTimerBlock)();
typedef void (^FXLinkBlock)(CADisplayLink *link);

@interface NSTimer (FXWeakTimer)

/**
 *  Creates and returns a new NSTimer object and schedules it on the current run loop in the default mode.
 *
 *  @param interval The number of seconds between firings of the timer
 *  @param target   Associated target. The timer will be invalidated as soon as this object has been deallocated
 *  @param repeats  Repeat or not
 *  @param block    The block will execute when timer firing. (In order to avoid cycle-retained, consider to use weak-strong dance)
 *
 *  @return A new NSTimer object
 */
+ (NSTimer *)fx_scheduledTimerWithInterval:(NSTimeInterval)interval
                                    target:(id)target
                                   repeats:(BOOL)repeats
                                     block:(FXTimerBlock)block;

/**
 *  Creates and returns a new NSTimer object and schedules it on the current run loop in the default mode.
 *
 *  @param interval The number of seconds between firings of the timer
 *  @param target   Associated target. The timer will be invalidated as soon as this object has been deallocated
 *  @param repeats  Repeat or not
 *  @param queue    The queue in which the block exected
 *  @param block    The block will execute when timer firing. (In order to avoid cycle-retained, consider to use weak-strong dance)
 *
 *  @return A new NSTimer object
 */
+ (NSTimer *)fx_scheduledTimerWithInterval:(NSTimeInterval)interval
                                    target:(id)target
                                   repeats:(BOOL)repeats
                                     queue:(dispatch_queue_t)queue
                                     block:(FXTimerBlock)block;

/**
 *  Creates and returns a new NSTimer object.
 *
 *  @param interval The number of seconds between firings of the timer
 *  @param target   Associated target. The timer will be invalidated as soon as this object has been deallocated
 *  @param repeats  Repeat or not
 *  @param block    The block will execute when timer firing. (In order to avoid cycle-retained, consider to use weak-strong dance)
 *
 *  @return A new NSTimer object
 */
+ (NSTimer *)fx_timerWithInterval:(NSTimeInterval)interval
                           target:(id)target
                          repeats:(BOOL)repeats
                            block:(FXTimerBlock)block;

/**
 *  Creates and returns a new NSTimer object.
 *
 *  @param interval The number of seconds between firings of the timer
 *  @param target   Associated target. The timer will be invalidated as soon as this object has been deallocated
 *  @param repeats  Repeat or not
 *  @param queue    The queue in which the block exected
 *  @param block    The block will execute when timer firing. (In order to avoid cycle-retained, consider to use weak-strong dance)
 *
 *  @return A new NSTimer object
 */
+ (NSTimer *)fx_timerWithInterval:(NSTimeInterval)interval
                           target:(id)target
                          repeats:(BOOL)repeats
                            queue:(dispatch_queue_t)queue
                            block:(FXTimerBlock)block;

@end

@interface CADisplayLink (FXWeakLink)

+ (CADisplayLink *)fx_displayLinkWithTarget:(id)target
                                    runloop:(NSRunLoop *)loop
                                       mode:(NSString *)mode
                                      block:(FXLinkBlock)block;

+ (CADisplayLink *)fx_displayLinkWithTarget:(id)target
                                   selector:(SEL)selector
                                    runloop:(NSRunLoop *)loop
                                       mode:(NSString *)mode;

@end
