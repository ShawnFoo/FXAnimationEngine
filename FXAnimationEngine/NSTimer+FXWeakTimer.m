//
//  NSTimer+FXWeakTimer.m
//  FXWeakTimer
//
//  Created by ShawnFoo on 16/6/14.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "NSTimer+FXWeakTimer.h"
#import <objc/runtime.h>
#import "FXAnimaionEngineMacro.h"

#pragma mark - FXReleaseMonitor
@interface FXReleaseMonitor : NSObject

@property (copy, nonatomic) void (^deallocBlock)(void);

@end

@implementation FXReleaseMonitor

+ (void)addMonitorToObj:(id)obj key:(id)key withDeallocBlock:(void (^)(void))deallocBlock {
    NSParameterAssert(obj);
    NSParameterAssert(deallocBlock);
    FXReleaseMonitor *monitor = [[FXReleaseMonitor alloc] init];
    monitor.deallocBlock = deallocBlock;
    
    objc_setAssociatedObject(obj,
                             (__bridge const void *)(key),
                             monitor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc {
    FXRunBlockSafe(_deallocBlock);
}

@end

#pragma mark - FXWeakTarget
@interface FXWeakTarget : NSObject

@property (weak, nonatomic) id target;

@property (copy, nonatomic) FXTimerBlock timerBlock;
@property (weak, nonatomic) NSTimer *timer;
@property (strong, nonatomic) dispatch_queue_t queue;

@property (copy, nonatomic) FXLinkBlock linkBlock;
@property (weak, nonatomic) CADisplayLink *link;
@property (weak, nonatomic) NSRunLoop *runloop;
@property (copy, nonatomic) NSString *mode;

@property (assign, nonatomic) SEL selector;

@end

@implementation FXWeakTarget

- (void)timerBlockInvoker:(NSTimer *)timer {
    
    if (timer.valid) {
        id strongTarget = self.target;
        if (strongTarget) {
            if (self.queue) {
                dispatch_async(self.queue, ^{
                    FXRunBlockSafe(self.timerBlock);
                });
            }
            else {
                FXRunBlockSafe(self.timerBlock);
            }
        }
        else {
            [self.timer invalidate];
        }
    }
}

- (void)invalidateTimer {
    [self.timer invalidate];
}

- (void)linkBlockInvoker:(CADisplayLink *)link {
    
    id strongTarget = self.target;
    if (strongTarget) {
        FXRunBlockSafe(self.linkBlock, link);
        if ([strongTarget respondsToSelector:self.selector]) {
            id receiver = object_getClass(strongTarget);
            void (*implement)(id, SEL, id) =
            (void (*)(id, SEL, id))class_getMethodImplementation(receiver, self.selector);
            if (implement) {
                implement(strongTarget, self.selector, link);
            }
        }
    }
    else {
        [self invalidateLink];
    }
}

- (void)invalidateLink {
    [self.link invalidate];
}

@end

#pragma mark - NSTimer + FXWeakTimer
@implementation NSTimer (FXWeakTimer)

+ (NSTimer *)fx_scheduledTimerWithInterval:(NSTimeInterval)interval
                                    target:(id)target
                                   repeats:(BOOL)repeats
                                     block:(FXTimerBlock)block
{
    return [self fx_scheduledTimerWithInterval:interval
                                        target:target
                                       repeats:repeats
                                         queue:nil
                                         block:block];
}

+ (NSTimer *)fx_scheduledTimerWithInterval:(NSTimeInterval)interval
                                    target:(id)target
                                   repeats:(BOOL)repeats
                                     queue:(dispatch_queue_t)queue
                                     block:(FXTimerBlock)block
{
    NSParameterAssert(target);
    NSParameterAssert(block);
    
    FXWeakTarget *weakTarget = [[FXWeakTarget alloc] init];
    weakTarget.target = target;
    weakTarget.timerBlock = block;
    weakTarget.queue = queue;
    
    [FXReleaseMonitor addMonitorToObj:target key:weakTarget withDeallocBlock:^{
        [weakTarget invalidateTimer];
    }];
    
    weakTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                        target:weakTarget
                                                      selector:@selector(timerBlockInvoker:)
                                                      userInfo:nil
                                                       repeats:repeats];
    return weakTarget.timer;
}

+ (NSTimer *)fx_timerWithInterval:(NSTimeInterval)interval
                           target:(id)target
                          repeats:(BOOL)repeats
                            block:(FXTimerBlock)block
{
    return [self fx_timerWithInterval:interval
                               target:target
                              repeats:repeats
                                queue:nil
                                block:block];
}

+ (NSTimer *)fx_timerWithInterval:(NSTimeInterval)interval
                           target:(id)target
                          repeats:(BOOL)repeats
                            queue:(dispatch_queue_t)queue
                            block:(FXTimerBlock)block
{
    NSParameterAssert(target);
    NSParameterAssert(block);
    
    FXWeakTarget *weakTarget = [[FXWeakTarget alloc] init];
    weakTarget.target = target;
    weakTarget.timerBlock = block;
    weakTarget.queue = queue;
    
    [FXReleaseMonitor addMonitorToObj:target key:weakTarget withDeallocBlock:^{
        [weakTarget invalidateTimer];
    }];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:weakTarget
                                           selector:@selector(timerBlockInvoker:)
                                           userInfo:nil
                                            repeats:repeats];
    weakTarget.timer = timer;
    return timer;
}

@end


#pragma mark - CADisplayLink + FXWeakLink
@implementation CADisplayLink (FXWeakLink)

+ (CADisplayLink *)fx_displayLinkWithTarget:(id)target
                                    runloop:(NSRunLoop *)loop
                                       mode:(NSString *)mode
                                      block:(FXLinkBlock)block

{
    NSParameterAssert(target);
    NSParameterAssert(loop);
    NSParameterAssert(mode.length > 0);
    NSParameterAssert(block);
    
    FXWeakTarget *weakTarget = [[FXWeakTarget alloc] init];
    weakTarget.target = target;
    weakTarget.linkBlock = block;
    
    [FXReleaseMonitor addMonitorToObj:target key:weakTarget withDeallocBlock:^{
        [weakTarget invalidateLink];
    }];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:weakTarget
                                                      selector:@selector(linkBlockInvoker:)];
    [link addToRunLoop:loop forMode:mode];
    return link;
}

+ (CADisplayLink *)fx_displayLinkWithTarget:(id)target
                                   selector:(SEL)selector
                                    runloop:(NSRunLoop *)loop
                                       mode:(NSString *)mode
{
    NSParameterAssert(target);
    NSParameterAssert(selector);
    NSParameterAssert(loop);
    NSParameterAssert(mode.length > 0);
    
    FXWeakTarget *weakTarget = [[FXWeakTarget alloc] init];
    weakTarget.target = target;
    weakTarget.selector = selector;
    
    [FXReleaseMonitor addMonitorToObj:target key:weakTarget withDeallocBlock:^{
        [weakTarget invalidateLink];
    }];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:weakTarget
                                                      selector:@selector(linkBlockInvoker:)];
    [link addToRunLoop:loop forMode:mode];
    return link;
}

@end
