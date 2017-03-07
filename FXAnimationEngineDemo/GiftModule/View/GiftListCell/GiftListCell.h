//
//  GiftListCell.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GiftItem;

@interface GiftListCell : UICollectionViewCell

+ (CGFloat)cellHeight;
+ (NSString *)identifier;

- (void)setupCellWithGiftItem:(GiftItem *)giftItem selected:(BOOL)selected;
- (void)updateAppearenceWithSelected:(BOOL)selected;

@end
