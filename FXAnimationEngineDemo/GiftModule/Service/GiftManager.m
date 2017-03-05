//
//  GiftManager.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftManager.h"
#import "GiftResourceLoader.h"

static dispatch_queue_t kSerialQueue;
static NSArray<GiftItem *> *kGiftItems;
static NSCache<NSString *, GiftItem *> *kGiftItemsCache;
static NSString *kGiftVersion;

@implementation GiftManager

#pragma mark - LifeCycle
+ (void)initialize {
    if (self == [GiftManager class]) {
        kSerialQueue = dispatch_queue_create("com.ShawnFoo.GiftService.serialQueue", NULL);
        kGiftItems = nil;
        kGiftItemsCache = nil;
        kGiftVersion = nil;
    }
}

#pragma mark - Load Method
+ (NSArray<GiftItem *> *)loadGiftConfig {
    if (!kGiftItems) {
        [GiftResourceLoader loadGiftConfigWithReturnInfoBlock:^(NSArray<GiftItem *> *items, NSString *version) {
            kGiftItems = items;
            kGiftVersion = version;
        }];
    }
    return kGiftItems;
}

+ (GiftItem *)loadGiftItemWithId:(NSString *)giftId {
    if (!giftId.length) {
        return nil;
    }
    GiftItem *item = [kGiftItemsCache objectForKey:giftId];
    if (!item) {
        NSArray<GiftItem *> *giftItems = [self loadGiftConfig];
        for (GiftItem *giftItem in giftItems) {
            if ([giftId isEqualToString:giftItem.giftId]) {
                item = giftItem;
                break;
            }
        }
        if (item) {
            if (!kGiftItemsCache) {
                kGiftItemsCache = [[NSCache alloc] init];
            }
            [kGiftItemsCache setObject:item forKey:giftId];
        }
    }
    return item;
}

+ (GiftAnimationGroup *)loadGiftAnimGroupWithId:(NSString *)giftId {
    return [GiftResourceLoader loadAnimationGroupWithGiftId:giftId];
}

#pragma mark - Public Method
+ (NSString *)giftVersion {
    __block NSString *bVersion = nil;
    dispatch_sync(kSerialQueue, ^{
        [self loadGiftConfig];
        bVersion = kGiftVersion;
    });
    return bVersion;
}

+ (GiftItem *)giftItemWithId:(NSString *)giftId {
    __block GiftItem *bItem = nil;
    if (giftId.length) {
        dispatch_sync(kSerialQueue, ^{
            bItem = [self loadGiftItemWithId:giftId];
        });
    }
    return bItem;
}

+ (NSArray<GiftItem *> *)giftItems {
    __block NSArray<GiftItem *> *bItems = nil;
    dispatch_sync(kSerialQueue, ^{
        bItems = [self loadGiftConfig];
    });
    return bItems;
}

+ (GiftAnimationGroup *)giftAnimConfigWithId:(NSString *)giftId {
    __block GiftAnimationGroup *bConfig = nil;
    dispatch_sync(kSerialQueue, ^{
        bConfig = [self loadGiftAnimGroupWithId:giftId];
    });
    return bConfig;
}

@end
