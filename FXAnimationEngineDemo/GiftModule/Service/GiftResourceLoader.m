//
//  GiftResourceLoader.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/4.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftResourceLoader.h"
#import "GiftItem.h"
#import "NSObject+FXJSONConvert.h"
#import "GiftAnimationGroup.h"

static NSString *const kRootDirName = @"gifts";
static NSString *const kListDirName = @"list";
static NSString *const kAnimDirName = @"anim";
static NSString *const kGiftPlistName = @"gifts.plist";
static NSString *const kAnimConfigName = @"config.plist";

static NSString *const kGiftsKey = @"gifts";
static NSString *const kVertionKey = @"version";

@implementation GiftResourceLoader

#pragma mark - Path
+ (NSArray<NSString *> *)rootDirPaths {
    static NSArray<NSString *> *sRootDirPaths = nil;
    if (!sRootDirPaths) {
        sRootDirPaths = @[
                          [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:kRootDirName],
                          [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kRootDirName]
                          ];
    }
    return sRootDirPaths;
}

+ (NSArray<NSString *> *)listDirPathsWithGiftId:(NSString *)giftId {
    NSArray<NSString *> *rootDirPaths = [self rootDirPaths];
    NSMutableArray<NSString *> *listDirPaths = [NSMutableArray arrayWithCapacity:rootDirPaths.count];
    for (NSString *rootDirPath in rootDirPaths) {
        [listDirPaths addObject:[[rootDirPath stringByAppendingPathComponent:giftId] stringByAppendingPathComponent:kListDirName]];
    }
    return [listDirPaths copy];
}

+ (NSArray<NSString *> *)animDirPathsWithGiftId:(NSString *)giftId {
    NSArray<NSString *> *rootDirPaths = [self rootDirPaths];
    NSMutableArray<NSString *> *animDirPaths = [NSMutableArray arrayWithCapacity:rootDirPaths.count];
    for (NSString *rootDirPath in rootDirPaths) {
        [animDirPaths addObject:[[rootDirPath stringByAppendingPathComponent:giftId] stringByAppendingPathComponent:kAnimDirName]];
    }
    return [animDirPaths copy];
}

+ (NSArray<NSString *> *)giftPlistPaths {
    NSArray *rootDirPaths = [self rootDirPaths];
    NSMutableArray<NSString *> *giftPlistPaths = [NSMutableArray arrayWithCapacity:rootDirPaths.count];
    for (NSString *rootDirPath in rootDirPaths) {
        [giftPlistPaths addObject:[rootDirPath stringByAppendingPathComponent:kGiftPlistName]];
    }
    return [giftPlistPaths copy];
}

+ (NSArray<NSString *> *)animConfigPathsWithGiftId:(NSString *)giftId {
    NSArray<NSString *> *rootDirPaths = [self rootDirPaths];
    NSMutableArray<NSString *> *animDirPaths = [NSMutableArray arrayWithCapacity:rootDirPaths.count];
    for (NSString *rootDirPath in rootDirPaths) {
        [animDirPaths addObject:[[rootDirPath stringByAppendingPathComponent:giftId] stringByAppendingPathComponent:kAnimDirName]];
    }
    return [animDirPaths copy];
}


#pragma mark - GiftItem
+ (void)loadGiftConfigWithReturnInfoBlock:(void (^)(NSArray<GiftItem *> *items, NSString *version))returnInfoBlock {
    if (!returnInfoBlock) {
        return;
    }
    
    NSArray<GiftItem *> *items = nil;
    NSArray<NSString *> *giftPlistPaths = [self giftPlistPaths];
    for (NSString *giftPlistPath in giftPlistPaths) {
        NSDictionary *giftConfigDic = [NSDictionary dictionaryWithContentsOfFile:giftPlistPath];
        NSArray *giftRawArray = giftConfigDic[kGiftsKey];
        NSString *version = giftConfigDic[kVertionKey];
        if (giftRawArray && version.length) {
            items = [GiftItem fx_instancesWithArray:giftRawArray];
            if (items.count) {
                returnInfoBlock(items, version);
                break;
            }
        }
    }
}

#pragma mark - GiftAnimation
+ (GiftAnimationGroup *)loadAnimationGroupWithGiftId:(NSString *)giftId {
    GiftAnimationGroup *group = nil;
    NSArray<NSString *> *giftAnimDirPaths = [self animDirPathsWithGiftId:giftId];
    for (NSString *giftAnimDirPath in giftAnimDirPaths) {
        NSString *configPath = [giftAnimDirPath stringByAppendingPathComponent:kAnimConfigName];
        NSDictionary *configDictionary = [NSDictionary dictionaryWithContentsOfFile:configPath];
        if (configDictionary.count) {
            group = [GiftAnimationGroup fx_instanceWithDictionary:configDictionary];
            if (group) {
                break;
            }
        }
    }
    return group;
}

#pragma mark - Images
+ (UIImage *)giftListFirstFrameOfGiftId:(NSString *)giftId {
    UIImage *firstFrame = nil;
    NSArray<NSString *> *giftListDirPaths = [self listDirPathsWithGiftId:giftId];
    for (NSString *giftListDirPath in giftListDirPaths) {
        NSString *firstFramePath = [giftListDirPath stringByAppendingPathComponent:@"0.png"];
        if ((firstFrame = [self imageWithPath:firstFramePath])) {
            break;
        }
    }
    return firstFrame;
}

+ (NSArray<UIImage *> *)giftListImagesOfGiftId:(NSString *)giftId {
    NSArray<UIImage *> *giftListImages = nil;
    NSArray<NSString *> *giftListDirPaths = [self listDirPathsWithGiftId:giftId];
    for (NSString *giftListDirPath in giftListDirPaths) {
        if ([self isFileExisted:giftListDirPath]) {
            giftListImages = [self imagesWithDirPath:giftListDirPath];
            if (giftListImages.count) {
                break;
            }
        }
    }
    return giftListImages;
}

+ (NSArray<UIImage *> *)animationImagesOfGiftId:(NSString *)giftId {
    NSArray<UIImage *> *animtionImages = nil;
    NSArray<NSString *> *animDirPaths = [self animDirPathsWithGiftId:giftId];
    for (NSString *animDirPath in animDirPaths) {
        if ([self isFileExisted:animDirPath]) {
            animtionImages = [self imagesWithDirPath:animDirPath];
            if (animtionImages.count) {
                break;
            }
        }
    }
    return animtionImages;
}

#pragma mark - ShortCut
+ (BOOL)isFileExisted:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL];
}

+ (UIImage *)imageWithPath:(NSString *)path {
    return [UIImage imageWithContentsOfFile:path];
}

+ (NSArray<UIImage *> *)imagesWithDirPath:(NSString *)dirPath {
    NSMutableArray *images = [NSMutableArray array];
    NSUInteger index = 0;
    while (true) {
        NSString *imagePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", @(index)]];
        UIImage *image = [self imageWithPath:imagePath];
        if (!image) {
            break;
        }
        [images addObject:image];
    }
    return [images copy];
}


@end
