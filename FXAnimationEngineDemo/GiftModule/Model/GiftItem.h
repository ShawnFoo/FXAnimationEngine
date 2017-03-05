//
//  GiftItem.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftImageInfo.h"

@interface GiftItem : NSObject

@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *zipURL;

@property (nonatomic, readonly) GiftImageInfo *imageInfo;

@end
