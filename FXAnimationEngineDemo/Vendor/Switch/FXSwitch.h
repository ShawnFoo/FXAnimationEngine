//
//  FXSwitch.h
//  FXKit
//
//  Created by ShawnFoo on 4/12/16.
//  Copyright © 2016 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FXSwitchValueChangedHandler)(BOOL isOn);

@interface FXSwitch : UIView

@property (assign, nonatomic, getter=isOn) BOOL on;

/** on状态 下的文字! 必须设置, 默认为空 */
@property (copy, nonatomic) NSString *onText;
/** off状态 下的文字! 必须设置, 默认为空 */
@property (copy, nonatomic) NSString *offText;
/** 文字字体, 默认为lightFont, Size: 12pt */
@property (copy, nonatomic) UIFont *textFont;

/** on状态 的字体颜色, 默认为 绿 */
@property (copy, nonatomic) UIColor *onFontColor;
/** off状态 的字体颜色, 默认为 灰 */
@property (copy, nonatomic) UIColor *offFontColor;
/** on状态 背景颜色 */
@property (copy, nonatomic) UIColor *onTintColor;
/** off状态 背景颜色 */
@property (copy, nonatomic) UIColor *offTintColor;

/** 滑块颜色, 默认白色 */
@property (copy, nonatomic) UIColor *thumbColor;
/** 滑块宽度占总长的比例, 默认0.7 */
@property (assign, nonatomic) CGFloat thumbHorizRatio;
/** 滑块外边距, 默认 2.0 */
@property (assign, nonatomic) CGFloat thumbMargin;
/** 滑块圆角半径, 默认 2.0 */
@property (assign, nonatomic) CGFloat thumbRadius;

- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (void)setSwitchValueChangedHandler:(FXSwitchValueChangedHandler)handler;

@end
