//
//  FXDeallocMonitor.h
//
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^FXDeallocBlock)(void);

/**
 *  This class can be used to monitor an object's release, to check memory leak(especially when you are using ReactiveCocoa, too many strong weak dances, nested blocks, etc...Xcode Instrument can't detect all retain cycles every time, but FXDeallocMonitor is capable to do it).
 *  Inspired by my mentor DarwinRie(达文哥) 😁
 */
@interface FXDeallocMonitor : NSObject

/**
 *  Print object when it is being deallocated(before object_dispose())
 */
+ (void)addMonitorToObj:(id)obj;

/**
 *  Print object with description when it is being deallocated
 *
 *  @param obj  object
 *  @param desc description
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc;

/**
 *  Print object and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param deallocBlock a block will run when object is being deallocated. For example, remove KVO in this block
 */
+ (void)addMonitorToObj:(id)obj withDeallocBlock:(FXDeallocBlock)deallocBlock;

/**
 *  Print object with description and and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param desc         description
 *  @param deallocBlock a block will run when object is being deallocated
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(FXDeallocBlock)deallocBlock;

@end
