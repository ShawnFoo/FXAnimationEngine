//
//  GiftImageInfo.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftImageInfo.h"

static NSString *const kRootDirName = @"gifts";
static NSString *const kAnimDirName = @"anim";
static NSString *const kListDirName = @"list";

static const NSTimeInterval kListFrameInterval = 0.1;

@interface GiftImageInfo ()

@property (nonatomic, copy) NSString *giftId;

@property (nonatomic, readonly) NSString *resourcePath;
@property (nonatomic, readonly) NSString *giftDirPath;
@property (nonatomic, readonly) NSString *listDirPath;
@property (nonatomic, readonly) NSString *animDirPath;

@end

@implementation GiftImageInfo

#pragma mark - Factory
+ (instancetype)imageInfoWithGiftId:(NSString *)giftId {
    GiftImageInfo *info = [GiftImageInfo new];
    info.giftId = giftId;
    return info;
}

#pragma mark - Accessor
#pragma mark Path
- (NSString *)resourcePath {
    return [[NSBundle mainBundle] resourcePath];
}

- (NSString *)giftDirPath {
    return [[[self resourcePath] stringByAppendingPathComponent:kRootDirName] stringByAppendingPathComponent:self.giftId];
}

- (NSString *)listDirPath {
    return [self.giftDirPath stringByAppendingPathComponent:kListDirName];
}

- (NSString *)animDirPath {
    return [self.giftDirPath stringByAppendingPathComponent:kAnimDirName];
}

#pragma mark Image
- (UIImage *)listFirstFrame {
    NSString *path = [self.listDirPath stringByAppendingPathComponent:@"0.png"];
    return [self imageWithPath:path];
}

- (UIImage *)listAnimatedImage {
    NSArray *images = [self imagesWithDirPath:self.listDirPath];
    return [UIImage animatedImageWithImages:images duration:images.count * kListFrameInterval];
}

- (NSArray<UIImage *> *)animationFrames {
    return [self imagesWithDirPath:self.animDirPath];
}

#pragma mark - ShortCut
- (UIImage *)imageWithPath:(NSString *)path {
    return [UIImage imageWithContentsOfFile:path];
}

- (NSArray<UIImage *> *)imagesWithDirPath:(NSString *)dirPath {
    NSMutableArray *images = [NSMutableArray array];
    NSUInteger index = 0;
    while (true) {
        NSString *imagePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", @(index)]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (!image) {
            break;
        }
        [images addObject:image];
    }
    return [images copy];
}

@end
