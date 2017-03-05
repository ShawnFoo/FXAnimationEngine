//
//  GiftListCell.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftListCell.h"
#import "GiftItem.h"

@interface GiftListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMaskImageView;

@property (nonatomic, weak) GiftItem *giftItem;

@end

@implementation GiftListCell

#pragma mark - Accessor
+ (CGFloat)cellHeight {
    return 64;
}

+ (NSString *)identifier {
    return @"GiftListCellIdentifier";
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedMaskImageView.hidden = !selected;
    self.giftImageView.image = selected ? self.giftItem.imageInfo.listAnimatedImage : self.giftItem.imageInfo.listFirstFrame;
}

#pragma mark - Setup
- (void)setupCellWithGiftItem:(GiftItem *)giftItem selected:(BOOL)selected {
    self.giftItem = giftItem;
    self.selected = selected;
    self.giftNameLabel.text = giftItem.name;
}

@end
