//
//  GiftImageInfo.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftImageInfo.h"
#import "GiftResourceLoader.h"

@interface GiftImageInfo ()

@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, readonly) NSTimeInterval listFrameInterval;

@end

@implementation GiftImageInfo

#pragma mark - Factory
+ (instancetype)imageInfoWithGiftId:(NSString *)giftId {
    GiftImageInfo *info = [GiftImageInfo new];
    info.giftId = giftId;
    return info;
}

#pragma mark - Accessor
- (NSTimeInterval)listFrameInterval {
    return 0.1;
}

- (UIImage *)listFirstFrame {
    return [GiftResourceLoader giftListFirstFrameOfGiftId:_giftId];
}

- (UIImage *)listAnimatedImage {
    NSArray *images = [GiftResourceLoader giftListImagesOfGiftId:_giftId];
    return [UIImage animatedImageWithImages:images duration:images.count * self.listFrameInterval];
}

- (NSArray<UIImage *> *)animationFrames {
    return [GiftResourceLoader animationImagesOfGiftId:_giftId];
}

@end
