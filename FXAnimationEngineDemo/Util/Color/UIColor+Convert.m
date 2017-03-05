//
//  UIColor+Convert.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 2017/3/4.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "UIColor+Convert.h"

@implementation UIColor (Convert)

+ (UIColor *)fx_colorWithHexRGBValue:(NSUInteger)hexValue {
    return [UIColor colorWithRed:((CGFloat)((hexValue&0xFF0000)>>16))/255.0
                           green:((CGFloat)((hexValue&0xFF00)>>8))/255.0
                            blue:((CGFloat)(hexValue&0xFF))/255.0
                           alpha:1];
}

@end
