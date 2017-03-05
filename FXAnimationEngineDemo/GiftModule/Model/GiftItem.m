//
//  GiftItem.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftItem.h"

@interface GiftItem ()

@property (nonatomic, strong) GiftImageInfo *imageInfo;

@end

@implementation GiftItem

- (GiftImageInfo *)imageInfo {
    if (!_imageInfo) {
        _imageInfo = [GiftImageInfo imageInfoWithGiftId:_giftId];
    }
    return _imageInfo;
}

- (BOOL)isEqual:(id)object {
    if (![self isKindOfClass:[GiftItem class]]) {
        return NO;
    }
    else if (self == object) {
        return YES;
    }
    else {
        GiftItem *obj = object;
        BOOL equalId = [obj.giftId isEqual:_giftId];
        BOOL equalZipURL = [obj.zipURL isEqual:_zipURL];
        return equalId && equalZipURL;
    }
}

- (NSUInteger)hash {
    return _giftId.hash ^ _zipURL.hash;
}

@end
