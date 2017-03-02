//
//  FXDeallocMonitor.h
//
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import "FXDeallocMonitor.h"
#import <objc/runtime.h>

#define RunBlock_Safe(block) {\
    if (block) {\
        block();\
    }\
}\

@interface FXDeallocMonitor ()

@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) FXDeallocBlock deallocBlock;

@end

@implementation FXDeallocMonitor

#pragma mark - Public Class Methods

+ (void)addMonitorToObj:(id)obj {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc {
    [self addMonitorToObj:obj withDesc:desc deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDeallocBlock:(FXDeallocBlock)deallocBlock {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:deallocBlock];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(FXDeallocBlock)deallocBlock {
#ifdef DEBUG
    NSParameterAssert(obj);
    FXDeallocMonitor *monitor = [[FXDeallocMonitor alloc] init];
    if (desc.length > 0) {
        monitor.desc = [NSString stringWithFormat:@"%@: %@", obj, desc];
    }
    else {
        monitor.desc = [NSString stringWithFormat:@"%@ has been deallocated", obj];
    }
    if (deallocBlock) {
        monitor.deallocBlock = deallocBlock;
    }
    
    int randomKey;
    
    // It is true that swizzle method of dealloc in NSObject Category can do the same thing, but that will cause method polluted!
    objc_setAssociatedObject(obj, &randomKey, monitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
}

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"%@", _desc);
    RunBlock_Safe(_deallocBlock);
}

@end
