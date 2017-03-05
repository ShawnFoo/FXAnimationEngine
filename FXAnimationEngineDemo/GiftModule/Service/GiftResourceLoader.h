//
//  GiftResourceLoader.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/4.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GiftItem, GiftAnimationGroup;

@interface GiftResourceLoader : NSObject

+ (void)loadGiftConfigWithReturnInfoBlock:(void (^)(NSArray<GiftItem *> *items, NSString *version))returnInfoBlock;
+ (GiftAnimationGroup *)loadAnimationGroupWithGiftId:(NSString *)giftId;

+ (UIImage *)giftListFirstFrameOfGiftId:(NSString *)giftId;
+ (NSArray<UIImage *> *)giftListImagesOfGiftId:(NSString *)giftId;
+ (NSArray<UIImage *> *)animationImagesOfGiftId:(NSString *)giftId;

@end
