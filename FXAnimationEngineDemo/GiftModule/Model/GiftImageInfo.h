//
//  GiftImageInfo.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftImageInfo : NSObject

@property (nonatomic, readonly) UIImage *listFirstFrame;
@property (nonatomic, readonly) UIImage *listAnimatedImage;

@property (nonatomic, readonly) NSArray<UIImage *> *animationFrames;

+ (instancetype)imageInfoWithGiftId:(NSString *)giftId;

@end
