//
//  GiftListCell.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftListCell.h"

@interface GiftListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMaskImageView;

@end

@implementation GiftListCell

#pragma mark - Accessor
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedMaskImageView.hidden = !selected;
}

#pragma mark - LifeCycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)commonSetup {
    
}

@end
