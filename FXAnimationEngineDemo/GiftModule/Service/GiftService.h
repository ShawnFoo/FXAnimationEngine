//
//  GiftService.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftItem.h"
#import "GiftAnimationConfig.h"

@interface GiftService : NSObject

+ (void)asyncLoadGifts;

+ (GiftItem *)giftItemWithId:(NSString *)giftId;
+ (NSArray<GiftItem *> *)giftItems;

+ (GiftAnimationConfig *)giftAnimConfigWithId:(NSString *)giftId;

@end
