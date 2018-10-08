//
//  FXImageDecodeOperation.m
//  FXAnimationEngineDemo
//
//  Created by fuxiang on 2018/9/27.
//  Copyright © 2018年 ShawnFoo. All rights reserved.
//

#import "FXImageDecodeOperation.h"
#import "UIImage+FXDecoder.h"

@interface FXImageDecodeOperation ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation FXImageDecodeOperation

- (instancetype)initWithImage:(UIImage *)image
               completedBlock:(FXImageDecodeCompletedBlk)block {
    if (self = [super init]) {
        _image = image;
        [self setCompletedBlockWithCallback:block];
    }
    return self;
}

- (void)setCompletedBlockWithCallback:(FXImageDecodeCompletedBlk)block {
    if (block) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            UIImage *image = weakSelf.image;
            if ([NSThread isMainThread]) {
                block(image);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image);
                });
            }
            weakSelf.image = nil;
        };
    }
}

- (void)cancel {
    [super cancel];
    
    self.image = nil;
    self.completionBlock = nil;
}

- (void)main {
    self.image = [self.image fx_decodedImage];
}

@end
