//
//  CADisplayLink+FXWeakTarget.m
//  FXKit
//
//  Created by ShawnFoo on 16/6/14.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "CADisplayLink+FXWeakTarget.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FXDLinkTargetMonitor Interface
@interface FXDLinkTargetMonitor : NSObject

@property (nonatomic, copy) void (^deallocBlock)(void);

+ (void)addMonitorToTarget:(id)target forKey:(id)key withDeallocBlock:(void (^)(void))deallocBlock;

@end


#pragma mark - FXDLinkTargetProxy Interface
@interface FXDLinkTargetProxy : NSObject

@property (nonatomic, weak) id target;
@property (nullable, nonatomic, copy) fx_displayLink_callback callback;
@property (nullable, nonatomic, assign) SEL actionSEL;
@property (nonatomic, weak) CADisplayLink *link;

+ (instancetype)proxyWithTarget:(id)target callback:(fx_displayLink_callback)callback;
+ (instancetype)proxyWithTarget:(id)target actionSEL:(SEL)actionSEL;
- (void)linkCallbackInvoke:(CADisplayLink *)link;
- (void)invalidateDLink;

@end


#pragma mark - CADisplayLink + FXWeakTarget
@implementation CADisplayLink (FXWeakTarget)

+ (CADisplayLink *)fx_addDisplayLinkToCurrentRunloopForDefaultModeWithTarget:(id)target
																	callback:(fx_displayLink_callback)callback {
	return [self fx_addDisplayLinkToRunloop:nil
									forMode:nil
								 withTarget:target
								   callback:callback];
}

+ (CADisplayLink *)fx_addDisplayLinkToCurrentRunloopForDefaultModeWithTarget:(id)target
																   actionSEL:(SEL)actionSEL {
	return [self fx_addDisplayLinkToRunloop:nil
									forMode:nil
								 withTarget:target
								  actionSEL:actionSEL];
}

+ (CADisplayLink *)fx_addDisplayLinkToRunloop:(nullable NSRunLoop *)loop
									  forMode:(nullable NSString *)mode
								   withTarget:(id)target
									 callback:(fx_displayLink_callback)callback {
	FXDLinkTargetProxy *proxy = [FXDLinkTargetProxy proxyWithTarget:target callback:callback];
	return [self fx_addDisplayLinkToRunloop:loop
									forMode:mode
								  withProxy:proxy];
}

+ (CADisplayLink *)fx_addDisplayLinkToRunloop:(nullable NSRunLoop *)loop
									  forMode:(nullable NSString *)mode
								   withTarget:(id)target
									actionSEL:(SEL)actionSEL {
	FXDLinkTargetProxy *proxy = [FXDLinkTargetProxy proxyWithTarget:target actionSEL:actionSEL];
	return [self fx_addDisplayLinkToRunloop:loop
									forMode:mode
								  withProxy:proxy];
}

+ (CADisplayLink *)fx_addDisplayLinkToRunloop:(nullable NSRunLoop *)loop forMode:(nullable NSString *)mode withProxy:(FXDLinkTargetProxy *)proxy {
	[FXDLinkTargetMonitor addMonitorToTarget:proxy.target
									  forKey:proxy
							withDeallocBlock:^
	{
		[proxy invalidateDLink];
	}];
	CADisplayLink *link = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(linkCallbackInvoke:)];
	NSRunLoop *aloop = loop ? loop : [NSRunLoop currentRunLoop];
	NSString *amode = mode ? mode : NSDefaultRunLoopMode;
	[link addToRunLoop:aloop forMode:amode];
	return link;
}

@end


#pragma mark - FXDLinkTargetMonitor IMP
@implementation FXDLinkTargetMonitor

+ (void)addMonitorToTarget:(id)target forKey:(id)key withDeallocBlock:(void (^)(void))deallocBlock {
	FXDLinkTargetMonitor *monitor = [[FXDLinkTargetMonitor alloc] init];
	monitor.deallocBlock = deallocBlock;
	objc_setAssociatedObject(target,
							 (__bridge const void *)(key),
							 monitor,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc {
	_deallocBlock();
}

@end

#pragma mark - FXDLinkTargetProxy IMP
@implementation FXDLinkTargetProxy

+ (instancetype)proxyWithTarget:(id)target callback:(fx_displayLink_callback)callback {
	FXDLinkTargetProxy *proxy = [[FXDLinkTargetProxy alloc] init];
	proxy.target = target;
	proxy.callback = callback;
	return proxy;
}

+ (instancetype)proxyWithTarget:(id)target actionSEL:(SEL)actionSEL {
	FXDLinkTargetProxy *proxy = [[FXDLinkTargetProxy alloc] init];
	proxy.target = target;
	proxy.actionSEL = actionSEL;
	return proxy;
}

- (void)linkCallbackInvoke:(CADisplayLink *)link {
	id strongTarget = self.target;
	if (strongTarget) {
		if (self.callback) {
			self.callback(link);
		} else if ([strongTarget respondsToSelector:self.actionSEL]) {
			id receiver = object_getClass(strongTarget);
			void (*implement)(id, SEL, id)  = (void (*)(id, SEL, id))class_getMethodImplementation(receiver, self.actionSEL);
			if (implement) {
				implement(strongTarget, self.actionSEL, link);
			}
		}
	} else {
		[self invalidateDLink];
	}
}

- (void)invalidateDLink {
	self.callback = nil;
	self.actionSEL = nil;
	[self.link invalidate];
}

@end

NS_ASSUME_NONNULL_END
