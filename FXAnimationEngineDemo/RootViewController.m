//
//  ViewController.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/27.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "RootViewController.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"
#import "CALayer+FXAnimationEngine.h"
#import "GiftListViewController.h"
#import "GiftFrameAnimationView.h"
#import "GiftItem.h"

static NSString *const kAnimationIdentifier = @"kAnimationIdentifier";

@interface RootViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) CGFloat giftBtShowingBottom;
@property (nonatomic, readonly) CGFloat giftBtHiddenBottom;

@property (nonatomic, weak) IBOutlet GiftFrameAnimationView *frameAnimationView;

@property (nonatomic, weak) UIButton *giftButton;
@property (nonatomic, readonly) BOOL isGiftButtonShowing;
@property (nonatomic, readonly) NSString *giftButtonAnimKeyPath;

@property (nonatomic, strong) GiftListViewController *giftListVC;

@property (nonatomic, weak) UIImageView *giftGuideMaskView;

@end

@implementation RootViewController

#pragma mark - Accessor
- (CGFloat)giftBtShowingBottom {
    return 20;
}

- (CGFloat)giftBtHiddenBottom {
    return -60;
}

- (NSString *)giftButtonAnimKeyPath {
    return @"giftButtonAnimKeyPath";
}

- (BOOL)isGiftButtonShowing {
    CGSize viewSize = self.view.frame.size;
    CGRect btRect = self.giftButton.frame;
    CGFloat bottomSpace = viewSize.height - (btRect.origin.y + btRect.size.height);
    return bottomSpace == self.giftBtShowingBottom;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackground];
    [self addTapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupGiftButton];
    [self setupGiftGuideMaskView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showGiftButton];
}

#pragma mark - MemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.giftListVC.parentViewController != self) {
        self.giftListVC = nil;
    }
}

#pragma mark - StatusBar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Gesture
- (void)addTapGesture {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(userDidTapViewInBlank:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view || touch.view == self.giftGuideMaskView;
}

#pragma mark - Setup Background
- (void)setupBackground {
    NSString *const cBgImageName = @"living_room_bg";
    NSString *const cSubdirectory = @"background";
    
    NSString *bgFilePath = [[NSBundle mainBundle] pathForResource:cBgImageName ofType:@"png" inDirectory:cSubdirectory];
    UIImage *background = nil;
    if ((background = [UIImage imageWithContentsOfFile:bgFilePath])) {
        self.view.layer.contents = (__bridge id)background.CGImage;
    }
    
    self.view.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - Guide MaskView
- (void)setupGiftGuideMaskView {
    if (!self.giftGuideMaskView) {
        CGRect btFrame = self.giftButton.frame;// hidden giftBt frame
        btFrame.origin.y -= fabs(self.giftBtHiddenBottom) + fabs(self.giftBtShowingBottom);
        UIColor *maskBgColor = [UIColor colorWithWhite:0.2 alpha:0.75];
        
        UIImageView *guideMaskView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        guideMaskView.image = [self guideImageInViewWithMaskCenterRect:btFrame
                                                               bgColor:maskBgColor];
        [self.view insertSubview:guideMaskView belowSubview:self.giftButton];
        self.giftGuideMaskView = guideMaskView;
    }
}

- (void)removeGiftGuideMaskView {
    [self.giftGuideMaskView removeFromSuperview];
}

- (UIImage *)guideImageInViewWithMaskCenterRect:(CGRect)centerRect bgColor:(UIColor *)bgColor {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    [bgColor setFill];
    UIRectFill(self.view.bounds);
    UIBezierPath *centerPath = [UIBezierPath bezierPathWithRoundedRect:centerRect
                                                          cornerRadius:centerRect.size.width / 2.0];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationOut);
    [centerPath fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Gift Button
- (void)setupGiftButton {
    if (!self.giftButton) {
        UIImage *giftBtImage = [UIImage imageNamed:@"gift_bt"];
        
        UIButton *giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [giftButton setImage:giftBtImage forState:UIControlStateNormal];
        [giftButton setImage:giftBtImage forState:UIControlStateHighlighted];
        [giftButton addTarget:self
                       action:@selector(userDidClickGiftButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        CGSize viewSize = self.view.frame.size;
        CGSize btSize = giftBtImage.size;
        CGFloat btCenterX = viewSize.width / 2.0;
        CGFloat btCenterY = viewSize.height - self.giftBtHiddenBottom - btSize.height/2.0;
        giftButton.bounds = CGRectMake(0, 0, btSize.width, btSize.height);
        giftButton.center = CGPointMake(btCenterX, btCenterY);
        
        [self.view addSubview:giftButton];
        self.giftButton = giftButton;
    }
}

#pragma mark  Animation
- (void)showGiftButton {
    const CGFloat cYMovement = fabs(self.giftBtShowingBottom) + fabs(self.giftBtHiddenBottom);
    const NSTimeInterval cFirstGroupDuration = 0.45;
    const NSTimeInterval cSecondGroupDuration = 0.15;
    
    CGPoint fromPoint = self.giftButton.layer.position;
    CGPoint toPoint = fromPoint;
    toPoint.y -= cYMovement;
    CABasicAnimation *moveUpAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    moveUpAnim.fromValue = [NSNumber valueWithCGPoint:fromPoint];
    moveUpAnim.toValue = [NSNumber valueWithCGPoint:toPoint];
    moveUpAnim.duration = cFirstGroupDuration;
    
    CABasicAnimation *enlargeAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    enlargeAnim.fromValue = [NSNumber valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1)];
    enlargeAnim.toValue = [NSNumber valueWithCATransform3D:CATransform3DIdentity];
    enlargeAnim.duration = cFirstGroupDuration;
    
    CASpringAnimation *quakeAnim = [CASpringAnimation animationWithKeyPath:@"transform"];
    quakeAnim.fromValue = [NSNumber valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)];
    quakeAnim.toValue = [NSNumber valueWithCATransform3D:CATransform3DIdentity];
    quakeAnim.duration = cSecondGroupDuration;
    quakeAnim.beginTime = cFirstGroupDuration;
    quakeAnim.damping = 1;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = cFirstGroupDuration + cSecondGroupDuration;
    group.animations = @[moveUpAnim, enlargeAnim, quakeAnim];
    
    [self.giftButton.layer addAnimation:group forKey:self.giftButtonAnimKeyPath];
    self.giftButton.layer.position = toPoint;
}

- (void)hideGiftButton {
    const CGFloat cYMovement = fabs(self.giftBtShowingBottom) + fabs(self.giftBtHiddenBottom);
    const NSTimeInterval cSpinDuration = 0.1;
    const NSTimeInterval cMoveDuration = 0.45;
    const NSTimeInterval cGroupDuration = cSpinDuration + cMoveDuration;
    
    CABasicAnimation *spinAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnim.fromValue = @0.0;
    spinAnim.toValue = @(360 / 180 * M_PI);
    spinAnim.duration = cSpinDuration;
    spinAnim.repeatCount = HUGE_VALF;
    spinAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CGPoint fromPoint = self.giftButton.layer.position;
    CGPoint toPoint = fromPoint;
    toPoint.y += cYMovement;
    CABasicAnimation *moveDownAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    moveDownAnim.fromValue = [NSNumber valueWithCGPoint:fromPoint];
    moveDownAnim.toValue = [NSNumber valueWithCGPoint:toPoint];
    moveDownAnim.duration = cMoveDuration;
    moveDownAnim.beginTime = cSpinDuration;
    
    CABasicAnimation *shrinkAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    shrinkAnim.toValue = [NSNumber valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)];
    shrinkAnim.duration = cMoveDuration;
    shrinkAnim.beginTime = cSpinDuration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = cGroupDuration;
    group.animations = @[spinAnim, moveDownAnim, shrinkAnim];
    
    [self.giftButton.layer addAnimation:group forKey:self.giftButtonAnimKeyPath];
    self.giftButton.layer.position = toPoint;
}

#pragma mark - GiftListVC
- (void)presentGiftListVC {
    if (!self.giftListVC) {
        self.giftListVC = [[GiftListViewController alloc] init];
        [self registerGiftListVCEvents];
    }
    
    [self addChildViewController:self.giftListVC];
    [self.view insertSubview:self.giftListVC.view belowSubview:self.frameAnimationView];
    [self.giftListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.giftListVC.view.superview);
        make.height.equalTo(self.giftListVC.preferredContentSize.height);
    }];
    [self.giftListVC didMoveToParentViewController:self];
}

#pragma mark Events
- (void)registerGiftListVCEvents {
    @weakify(self);
    [[self.giftListVC rac_signalForSelector:@selector(userDidClickSendButtonWithGiftItem:playFXAnimation:)]
     subscribeNext:^(RACTuple *x) {
         @strongify(self);
         RACTupleUnpack(GiftItem *giftItem, NSNumber *playFXAnimation) = x;
         GiftFrameAnimationViewPlayMode playMode = playFXAnimation.boolValue ? GiftFrameAnimationViewPlayFXAnimationMode : GiftFrameAnimationViewPlayCAAnimationMode;
         [self.frameAnimationView addGiftItem:giftItem withPlayMode:playMode];
     }];
}

#pragma mark Click
- (void)userDidTapViewInBlank:(UITapGestureRecognizer *)recognizer {
    [self removeGiftGuideMaskView];
    
    if (self.giftListVC.parentViewController == self) {
        [self.giftListVC dismissGiftListViewController];
    }
    if (!self.isGiftButtonShowing) {
        [self showGiftButton];
    }
}

- (IBAction)userDidClickGiftButton:(id)sender {
    [self removeGiftGuideMaskView];
    [self hideGiftButton];
    [self presentGiftListVC];
}

@end
