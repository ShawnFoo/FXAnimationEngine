//
//  GiftManager.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftItem.h"
#import "GiftAnimationGroup.h"

@interface GiftManager : NSObject

+ (NSString *)giftVersion;

+ (NSArray<GiftItem *> *)giftItems;
+ (GiftItem *)giftItemWithId:(NSString *)giftId;
+ (GiftAnimationGroup *)loadGiftAnimGroupWithId:(NSString *)giftId;

@end
