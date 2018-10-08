//
//  UIImage+FXDecoder.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/1.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (FXDecoder)

@property (nullable, nonatomic, readonly) UIImage *fx_decodedImage;
@property (nonatomic, readonly) BOOL fx_hasDecoded;

@end

NS_ASSUME_NONNULL_END
