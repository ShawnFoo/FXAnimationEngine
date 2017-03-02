//
//  ViewController.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 16/7/27.
//  Copyright © 2016年 ShawnFoo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+FXAnimationEngine.h"
#import "FXDeallocMonitor.h"

@interface ViewController () <FXAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;

@property (weak, nonatomic) IBOutlet UIView *animDirector;

@end

@implementation ViewController

#pragma mark - Accessor
- (NSString *)resourceDirName {
    return @"Animation";
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.widthCons.constant = [UIScreen mainScreen].bounds.size.width;
//    self.heightCons.constant = [UIScreen mainScreen].bounds.size.width;
}

#pragma mark - Controls
- (IBAction)start:(id)sender {
    
    [self stop:nil];
    [self animation];
//    [self animation2];
//    [self animation3];
//    [self animationYouting];
//    [self animationFeizao];
//    [self animationTianshi];
//    [self animationMhcb];
}

- (IBAction)stop:(id)sender {
    [self.animDirector fx_stopAnimation];
    self.bottomConst.constant = 0;
}

- (IBAction)release:(id)sender {
    
    [self stop:nil];
    self.animDirector = nil;
}

#pragma mark - Animation
- (void)animation {
    
    NSString *const kDirName = @"gifts/10086/anim";
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDirName];
    
    NSMutableArray<UIImage *> *imgs = [NSMutableArray arrayWithCapacity:106];
    for (int i = 0; i <= 105; i++) {
        NSString *imgPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", @(i)]];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        [imgs addObject:image];
    }
    
    /**
     {
     identifier: "feiji",
     asixY: 0.25,  // 离底部距离 占 屏幕高度 的百分比
     animations: [
        {
            count: 29,
            duration: 1.9
        },
        {
            count: 14,
            duration: 0.93,
            repeats: 9
        },
        {
            count: 59,
            duration: 3.93
        }
     ]
     }
     **/
    
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animationWithIdentifier:@"feiji1"];
    animation.delegate = self;
    animation.count = 56;
    animation.duration = 3.8;
    
    FXKeyframeAnimation *animation2 = [FXKeyframeAnimation animationWithIdentifier:@"feiji2"];
    animation2.count = 22;
    animation2.duration = 1.5;
    animation2.repeats = 6;
    animation2.delegate = self;
    
    FXKeyframeAnimation *animation3 = [FXKeyframeAnimation animationWithIdentifier:@"feiji3"];
    animation3.count = 27;
    animation3.duration = 1.8;
    animation3.delegate = self;
    
    FXAnimationGroup *aniamtionGroup = [FXAnimationGroup animationWithIdentifier:@"feiji"];
    aniamtionGroup.frames = [imgs copy];
    aniamtionGroup.animations = @[animation, animation2, animation3];
    aniamtionGroup.delegate = self;
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGSize imageSize = imgs.firstObject.size;
    self.heightConst.constant = viewWidth * (imageSize.height / imageSize.width);
    self.bottomConst.constant = viewHeight * 0.33;
    
    imgs = nil;
    [self playAnimation:aniamtionGroup];
}

- (void)animation2 {
    
    NSString *const kDirName = @"youting";
    NSString *const kImgPrefix = @"youting_";
    NSString *bundlePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.resourceDirName] stringByAppendingPathComponent:kDirName];
    NSMutableArray<UIImage *> *imgs = [NSMutableArray arrayWithCapacity:102];
    for (int i = 0; i <= 128; i++) {
        NSString *imgPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kImgPrefix, @(i)]];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        [imgs addObject:image];
    }
    
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animationWithIdentifier:@"youting"];
    animation.frames = imgs;
    animation.duration = 13;
    animation.delegate = self;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize imageSize = imgs.firstObject.size;
    self.heightConst.constant = width * (imageSize.height / imageSize.width);
    
    [self playAnimation:animation];
}

//- (void)animation {
//    
//    NSString *const kDirName = @"youting";
//    NSString *const kImgPrefix = @"youting_";
//    NSString *bundlePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"10025"] stringByAppendingPathComponent:kDirName];
//    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:102];
//    for (int i = 0; i <= 128; i++) {
//        NSString *imgPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kImgPrefix, @(i)]];
//        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
//        [imgs addObject:(__bridge UIImage*)image.CGImage];
//    }
//    
//    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
//    anim.values = [imgs copy];
//    anim.duration = 16.125;
//    anim.removedOnCompletion = YES;
//    imgs = nil;
//    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    self.heightCons.constant = width * 370 / 360;
//    [self.animDirector.layer addAnimation:anim forKey:nil];
//}
//
//- (void)animation1 {
//    
//    NSString *const kDirName = @"youting";
//    NSString *const kImgPrefix = @"youting_";
//    NSString *bundlePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"10025"] stringByAppendingPathComponent:kDirName];
//    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:102];
//    for (int i = 0; i <= 128; i++) {
//        NSString *imgPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kImgPrefix, @(i)]];
//        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
//        [imgs addObject:image];
//    }
//    self.imageView.animationImages = [imgs copy];
//    self.imageView.animationDuration = 16.125;
//    self.imageView.animationRepeatCount = 1;
//    
//    [self.imageView startAnimating];
//}

//- (void)animation {
//    
//    NSString *const kDirName = @"feiji";
//    NSString *const kImgPrefix = @"feiji_";
//    NSString *bundlePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"10025"] stringByAppendingPathComponent:kDirName];
//    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:102];
//    for (int i = 0; i <= 101; i++) {
//        NSString *imgPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kImgPrefix, @(i)]];
//        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
//        [imgs addObject:(__bridge UIImage*)image.CGImage];
//    }
//
//    CAKeyframeAnimation *firstAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
//    NSArray *imgs1 = [imgs subarrayWithRange:NSMakeRange(0, 28+1)];
//    firstAnim.values = imgs1;
//    firstAnim.duration = 1.9;
//    
//    CAKeyframeAnimation *secondAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
//    NSArray *imgs2 = [imgs subarrayWithRange:NSMakeRange(29, 42+1-29)];
//    secondAnim.values = imgs2;
//    secondAnim.beginTime = 1.9;
//    secondAnim.duration = 0.93;
//    secondAnim.repeatCount = 9;
//    
//    CAKeyframeAnimation *thirdAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
//    NSArray *imgs3 = [imgs subarrayWithRange:NSMakeRange(43, 101+1-43)];
//    thirdAnim.values = imgs3;
//    thirdAnim.beginTime = 10.27;
//    thirdAnim.duration = 3.93;
//    
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.duration = 14.2;
//    group.animations = @[firstAnim, secondAnim, thirdAnim];
//    
//    imgs = nil;
//    [self.imageView.layer addAnimation:group forKey:nil];
//}

//- (void)animation2 {
//    
//    FXKeyframeAnimation *group1 = [[FXKeyframeAnimation alloc] init];
//    group1.duration = 1.9;
//    group1.count = 29;
//    
//    FXKeyframeAnimation *group2 = [[FXKeyframeAnimation alloc] init];
//    group2.duration = 0.93;
//    group2.count = 14;
//    group2.repeats = 9;
//    
//    FXKeyframeAnimation *group3 = [[FXKeyframeAnimation alloc] init];
//    group3.duration = 3.93;
//    group3.count = 59;
//    
//    FXAnimationGroup *giftItem = [[FXAnimationGroup alloc] init];
//    giftItem.path= @"10025/feiji";
//    giftItem.animations = @[group1, group2, group3];
//    
//    [self playAnimation:giftItem];
//}

//- (void)animationTianshi {
//
//    FXKeyframeAnimation *group = [[FXKeyframeAnimation alloc] init];
//    group.duration = 16.75;
//    
//    FXAnimationGroup *giftItem = [[FXAnimationGroup alloc] init];
//    giftItem.path = @"10025/lsyj";
//    giftItem.animations = @[group];
//    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    self.heightCons.constant = width * 525 / 360;
//    
//    [self playAnimation:giftItem];
//}

//- (void)animationMhcb {
//    
//    FXKeyframeAnimation *group = [[FXKeyframeAnimation alloc] init];
//    group.duration = 16.125;
//    group.count = 129;
//    
//    FXAnimationGroup *giftItem = [[FXAnimationGroup alloc] init];
//    giftItem.path = @"10025/mfcb";
//    giftItem.animations = @[group];
//    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    self.heightCons.constant = width * 580 / 360;
//    
//    [self playAnimation:giftItem];
//}


- (void)playAnimation:(__kindof FXAnimation *)item {
    [self.animDirector fx_startAnimation:item];
}

#pragma mark - FXAnimationDelegate
- (void)fxAnimationWillStart:(FXAnimation *)anim {
    NSLog(@"animation(%@)will start.", anim.identifier);
}

- (void)fxAnimationDidStop:(FXAnimation *)anim finished:(BOOL)finished {
    NSLog(@"animation(%@) did stop, finished: %@", anim.identifier, finished ? @"YES" : @"NO");
}

@end
