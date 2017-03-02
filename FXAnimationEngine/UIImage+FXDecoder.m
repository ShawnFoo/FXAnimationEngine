//
//  UIImage+FXDecoder.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/1.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "UIImage+FXDecoder.h"

@implementation UIImage (FXDecoder)

- (nullable CGImageRef)fx_decodedCGImageRefCopy {
    CGImageRef imgRef = self.CGImage;
    if (!imgRef) {
        return NULL;
    }
    size_t imgWidth = CGImageGetWidth(imgRef);
    size_t imgHeight = CGImageGetHeight(imgRef);
    if (0 == imgWidth || 0 == imgHeight) {
        return NULL;
    }
    
    const size_t cBPC = 8;
    const size_t cBytesPR = 0;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imgRef);
    BOOL hasAlpha = (kCGImageAlphaPremultipliedFirst == alphaInfo
                     || kCGImageAlphaPremultipliedLast == alphaInfo
                     || kCGImageAlphaFirst == alphaInfo
                     || kCGImageAlphaLast == alphaInfo);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imgWidth,
                                                 imgHeight,
                                                 cBPC,
                                                 cBytesPR,
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 bitmapInfo);
    if (context) {
        CGContextDrawImage(context,
                           CGRectMake(0, 0, imgWidth, imgHeight),
                           imgRef);
        imgRef = CGBitmapContextCreateImage(context);
        CFRelease(context);
        return imgRef;
    }
    return NULL;
}

@end
