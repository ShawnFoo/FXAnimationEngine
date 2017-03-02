//
//  GiftService.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftService.h"

static dispatch_queue_t sSerialQueue;
static NSArray<GiftItem *> *sGiftItems;

@implementation GiftService

+ (void)initialize {
    if (self == [GiftService class]) {
        sSerialQueue = dispatch_queue_create("com.ShawnFoo.GiftService.serialQueue", NULL);
        sGiftItems = nil;
    }
}

+ (void)asyncLoadGifts {
    
}

@end
