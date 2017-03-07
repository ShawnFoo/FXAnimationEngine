//
//  FXDeallocMonitor.h
//  //  FXKit
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^FXDeallocMonitorBlock)(void);

/**
 *  This category can be used to monitor an object's release, to check memory leak(especially when you are using ReactiveCocoa, too many strong weak dances, nested blocks, etc...Xcode Instrument can't detect all retain cycles every time, but FXDeallocMonitor is capable to do it).
 *  Inspired by my mentor DarwinRie(达文哥) 😁
 */
@interface NSObject (DeallocMonitor)

/**
 Print object when it is being deallocated(before object_dispose())
 */
- (void)fx_addDebugMonitor;
/**
 Print object with description when it is being deallocated

 @param desc description
 */
- (void)fx_addDebugMonitorWithDesc:(NSString *)desc;
/**
 Print object and excute deallocBlock when it is being deallocated

 @param deallocBlock a block will run when object is being deallocated.
 */
- (void)fx_addDebugMonitorWithDeallocBlock:(FXDeallocMonitorBlock)deallocBlock;
/**
 Print object with description and and excute deallocBlock when it is being deallocated

 @param desc description
 @param deallocBlock a block will run when object is being deallocated.
 */
- (void)fx_addDebugMonitorWithDesc:(NSString *)desc deallocBlock:(FXDeallocMonitorBlock)deallocBlock;

/** For release version */
- (void)fx_addMonitorWithDeallocBlock:(FXDeallocMonitorBlock)deallocBlock;

@end
