//
//  FXDeallocMonitor.h
//  FXKit
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import "FXDeallocMonitor.h"
#import <objc/runtime.h>

@interface FXDeallocMonitor: NSObject

@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) FXDeallocMonitorBlock deallocBlock;

@end

@implementation FXDeallocMonitor

#pragma mark - Public Class Methods
+ (void)addDebugMonitorToObject:(id)object {
    [self addDebugMonitorToObject:object withDesc:nil deallocBlock:nil];
}

+ (void)addDebugMonitorToObject:(id)object withDesc:(NSString *)desc {
    [self addDebugMonitorToObject:object withDesc:desc deallocBlock:nil];
}

+ (void)addDebugMonitorToObject:(id)object withDeallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    [self addDebugMonitorToObject:object withDesc:nil deallocBlock:deallocBlock];
}

+ (void)addDebugMonitorToObject:(id)object withDesc:(NSString *)desc deallocBlock:(FXDeallocMonitorBlock)deallocBlock {
#if DEBUG
    [self addToObject:object withDesc:desc deallocBlock:deallocBlock];
#endif
}

+ (void)addMonitorToObject:(id)object withDesc:(NSString *)desc deallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    [self addToObject:object withDesc:desc deallocBlock:deallocBlock];
}

+ (void)addToObject:(id)object withDesc:(NSString *)desc deallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    if (object) {
        FXDeallocMonitor *monitor = [[FXDeallocMonitor alloc] init];
        if (desc.length > 0) {
            monitor.desc = [NSString stringWithFormat:@"%@(%@) has been deallocated", desc, object];
        }
        else {
            monitor.desc = [NSString stringWithFormat:@"%@ has been deallocated", object];
        }
        if (deallocBlock) {
            monitor.deallocBlock = deallocBlock;
        }
        
        int randomKey;
        
        // It is true that swizzle method of dealloc in NSObject Category can do the same thing, but that will cause method polluted!
        objc_setAssociatedObject(object, &randomKey, monitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - LifeCycle
- (void)dealloc {
    if (_desc.length > 0) {
        NSLog(@"%@", _desc);
    }
    if (_deallocBlock) {
        _deallocBlock();
    }
}

@end

@implementation NSObject (DeallocMonitor)

- (void)fx_addDebugMonitor {
    [FXDeallocMonitor addDebugMonitorToObject:self];
}

- (void)fx_addDebugMonitorWithDesc:(NSString *)desc {
    [FXDeallocMonitor addDebugMonitorToObject:self withDesc:desc];
}

- (void)fx_addDebugMonitorWithDeallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    [FXDeallocMonitor addDebugMonitorToObject:self withDeallocBlock:deallocBlock];
}

- (void)fx_addDebugMonitorWithDesc:(NSString *)desc deallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    [FXDeallocMonitor addDebugMonitorToObject:self withDesc:desc deallocBlock:deallocBlock];
}

- (void)fx_addMonitorWithDeallocBlock:(FXDeallocMonitorBlock)deallocBlock {
    [FXDeallocMonitor addMonitorToObject:self
                                withDesc:nil
                            deallocBlock:deallocBlock];
}

@end
