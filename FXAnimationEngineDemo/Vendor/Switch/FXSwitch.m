//
//  FXSwitch.m
//  FXKit
//
//  Created by ShawnFoo on 4/12/16.
//  Copyright © 2016 ShawnFoo. All rights reserved.
//

#import "FXSwitch.h"

@interface FXSwitch ()

@property (nonatomic, copy) FXSwitchValueChangedHandler handler;

@property (nonatomic, assign) BOOL didLayout;
@property (nonatomic, assign) CGSize oldSize;

@property (nonatomic, assign) CGFloat touchedOriginX;
@property (nonatomic, assign) BOOL valueChangedWhenMoved;

@property (nonatomic, strong) UIView *thumb;
@property (nonatomic, strong) UILabel *textLb;

@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, readonly, assign) CGRect onThumbRect;
@property (nonatomic, readonly, assign) CGRect offThumbRect;

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation FXSwitch

@synthesize onFontColor = _onFontColor;
@synthesize offFontColor = _offFontColor;
@synthesize onTintColor = _onTintColor;
@synthesize offTintColor = _offTintColor;
@synthesize onText = _onText;
@synthesize offText = _offText;
@synthesize thumbHorizRatio = _thumbHorizRatio;
@synthesize thumbMargin = _thumbMargin;

#pragma mark - Setter
- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self switchTo:on animated:animated];
    if (_handler) {
        _handler(on);
    }
}

- (void)setSwitchValueChangedHandler:(FXSwitchValueChangedHandler)handler {
    self.handler = handler;
}

- (void)setOnText:(NSString *)onText {
    _onText = onText;
    if (_on) {
        self.textLb.text = onText;
    }
}

- (void)setOffText:(NSString *)offText {
    _offText = offText;
    if (!_on) {
        self.textLb.text = offText;
    }
}

- (void)setOnFontColor:(UIColor *)onFontColor {
    _onFontColor = onFontColor;
    if (_on) {
        self.textLb.textColor = onFontColor;
    }
}

- (void)setOffFontColor:(UIColor *)offFontColor {
    _offFontColor = offFontColor;
    if (!_on) {
        self.textLb.textColor = offFontColor;
    }
}

- (void)setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    if (_on) {
        self.backgroundColor = onTintColor;
    }
}

- (void)setOffTintColor:(UIColor *)offTintColor {
    _offFontColor = offTintColor;
    if (!_on) {
        self.backgroundColor = offTintColor;
    }
}

- (void)setThumbHorizRatio:(CGFloat)thumbHRatio {
    if (thumbHRatio > 0.0 && thumbHRatio < 1.0) {
        _thumbHorizRatio = thumbHRatio;
        [self appearenceDidChange];
    }
}

- (void)setThumbMargin:(CGFloat)thumbMargin {
    _thumbMargin = thumbMargin;
    [self appearenceDidChange];
}

#pragma mark - Getter
#pragma mark LazyLoading
- (UIView *)thumb {
    if (!_thumb) {
        _thumb = [UIView new];
        _thumb.backgroundColor = self.thumbColor;
        _thumb.layer.cornerRadius = self.thumbRadius;
        _thumb.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.24].CGColor;
        _thumb.layer.shadowOffset = CGSizeMake(0, 2);
        _thumb.layer.shadowOpacity = 2.0;
    }
    return _thumb;
}

- (UILabel *)textLb {
    if (!_textLb) {
        _textLb = [UILabel new];
        _textLb.textAlignment = NSTextAlignmentCenter;
        _textLb.font = self.textFont;
        _textLb.text = _on ? _onText : _offText;
        _textLb.textColor = _on ? self.onFontColor : self.offFontColor;
    }
    return _textLb;
}

#pragma mark Computed Property
- (CGSize)thumbSize {
    CGSize size = self.frame.size;
    return CGSizeMake(floorf(size.width*self.thumbHorizRatio), floor(size.height - 2*self.thumbMargin));
}

- (CGRect)onThumbRect {
    CGSize size = self.thumbSize;
    CGFloat thumbX = floorf(self.frame.size.width-size.width-self.thumbMargin);
    CGFloat thumbY = self.thumbMargin;
    
    return CGRectMake(thumbX, thumbY, self.thumbSize.width, self.thumbSize.height);
}

- (CGRect)offThumbRect {
    
    CGFloat thumbX = self.thumbMargin;
    CGFloat thumbY = self.thumbMargin;
    
    return CGRectMake(thumbX, thumbY, self.thumbSize.width, self.thumbSize.height);
}

#pragma mark DefaultValue
- (UIFont *)textFont {
    return _textFont ?: [self lightSystemFontWithSize:14];
}

- (UIColor *)onFontColor {
    return _onFontColor ?: [self colorWithHexRGB:0x84DA48];
}

- (UIColor *)offFontColor {
    return _offFontColor ?: [self colorWithHexRGB:0xEDF0F0];
}

- (UIColor *)onTintColor {
    return _onTintColor ?: self.onFontColor;
}

- (UIColor *)offTintColor {
    return _offFontColor ?: self.offFontColor;
}

- (CGFloat)thumbHorizRatio {
    return _thumbHorizRatio > 0 ? _thumbHorizRatio : 0.7;
}

- (CGFloat)thumbMargin {
    return _thumbMargin > 0 ? _thumbMargin : 2;
}

- (UIColor *)thumbColor {
    return _thumbColor ?: [UIColor whiteColor];
}

- (CGFloat)thumbRadius {
    return _thumbRadius > 0 ? _thumbRadius : 2;
}

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}

- (void)commonSetup {
    self.backgroundColor = self.offTintColor;
    self.layer.cornerRadius = 4.0;
    
    [self addSubview:self.thumb];
    [self.thumb addSubview:self.textLb];
}

- (void)appearenceDidChange {
    self.didLayout = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.frame.size.width || !self.frame.size.height) {
        return;
    }
    
    if (!self.didLayout || CGSizeEqualToSize(self.oldSize, self.frame.size)) {
        self.oldSize = self.frame.size;
        self.thumb.frame = self.isOn ? self.onThumbRect : self.offThumbRect;
        CGSize thumbSize = self.thumb.frame.size;
        self.textLb.frame = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
        self.didLayout = YES;
    }
}

#pragma mark - Animation
- (void)switchTo:(BOOL)status animated:(BOOL)animated {
    if (status == self.isOn || self.isAnimating) { return; };
    void (^colorAnimBlock)(void) = ^{
        self.backgroundColor = status ? self.onTintColor : self.offTintColor;
        self.textLb.textColor = status ? self.onFontColor : self.offFontColor;
        self.textLb.text = status ? self.onText : self.offText;
    };
    
    _on = status;
    if (animated) {
        self.isAnimating = YES;
        const CGFloat kAnimDuration = 0.4;
        const CGFloat kEnlargeScale = 0.1;
        
        CGFloat enlargeWidth = floor(self.thumbSize.width*kEnlargeScale);

        CGRect frame1, frame2, frame3 = CGRectZero;
        if (status) {// off -> on
            frame1 = self.offThumbRect;
            frame1.size.width += enlargeWidth;
            
            frame2 = self.onThumbRect;
            frame2.size.width += enlargeWidth;
            frame2.origin.x -= enlargeWidth;
            
            frame3 = self.onThumbRect;
        }
        else {// on -> off
            frame1 = self.onThumbRect;
            frame1.origin.x -= enlargeWidth;
            frame1.size.width += enlargeWidth;
            
            frame2 = self.offThumbRect;
            frame2.size.width += enlargeWidth;
            
            frame3 = self.offThumbRect;
        }
        
        [UIView animateKeyframesWithDuration:kAnimDuration
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:^
        {
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
                self.thumb.frame = frame1;
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
                self.thumb.frame = frame2;
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
                self.thumb.frame = frame3;
            }];
        } completion:nil];
        
        [UIView animateWithDuration:kAnimDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:colorAnimBlock
                         completion:^(BOOL finished) {
                             self.isAnimating = NO;
                         }];
    }
    else {
        CGRect toRect = status ? self.onThumbRect : self.offThumbRect;
        self.thumb.frame = toRect;
        colorAnimBlock();
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchedOriginX = [touch locationInView:self].x;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat swipeOffsetX = [touch locationInView:self].x - self.touchedOriginX;
    BOOL turnOn = swipeOffsetX > 0;
    swipeOffsetX = fabs(swipeOffsetX);
    
    CGFloat swipeDisplacement = self.frame.size.width - self.thumbSize.width - self.thumbMargin;
    if (swipeOffsetX >= swipeDisplacement) {
        self.valueChangedWhenMoved = YES;
        // 移动过程中只出现动画而不 调用handler, 结束时才调用
        [self switchTo:turnOn animated:YES];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.valueChangedWhenMoved) {// 点击处理
        [self switchTo:!self.isOn animated:YES];
    }
    if (self.handler) {
        self.handler(self.isOn);
    }
    self.valueChangedWhenMoved = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.valueChangedWhenMoved = NO;
}

#pragma mark - ShortCuts
- (UIFont *)lightSystemFontWithSize:(CGFloat)size {
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.2) {
        return [UIFont systemFontOfSize:size];
    }
    else {
        return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
    }
}

- (UIColor *)colorWithHexRGB:(NSUInteger)hexRGB {
    return ([UIColor colorWithRed:((CGFloat)((hexRGB&0xFF0000)>>16))/255.0
                            green:((CGFloat)((hexRGB&0xFF00)>>8))/255.0
                             blue:((CGFloat)(hexRGB&0xFF))/255.0
                            alpha:1]);
}

@end
