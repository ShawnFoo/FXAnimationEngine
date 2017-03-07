//
//  GiftListViewController.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GiftItem;

@interface GiftListViewController : UIViewController

- (void)dismissGiftListViewController;
#pragma mark - For Delegate
- (void)userDidClickSendButtonWithGiftItem:(GiftItem *)item playFXAnimation:(BOOL)playFXAnimation;

@end
