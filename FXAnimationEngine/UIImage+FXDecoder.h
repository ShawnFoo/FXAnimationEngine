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

- (nullable CGImageRef)fx_decodedCGImageRefCopy;

@end

NS_ASSUME_NONNULL_END
