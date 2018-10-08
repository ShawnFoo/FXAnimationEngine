//
//  FXImageDecodeOperation.h
//  FXAnimationEngineDemo
//
//  Created by fuxiang on 2018/9/27.
//  Copyright © 2018年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FXImageDecodeCompletedBlk)(UIImage *_Nullable decodedImage);

@interface FXImageDecodeOperation : NSOperation

- (instancetype)initWithImage:(UIImage *)image
               completedBlock:(FXImageDecodeCompletedBlk)block;

@end

NS_ASSUME_NONNULL_END
