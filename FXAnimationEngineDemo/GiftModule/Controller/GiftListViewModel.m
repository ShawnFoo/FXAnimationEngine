//
//  GiftListViewModel.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftListViewModel.h"
#import "FXPage.h"
#import "GiftManager.h"
#import "RACEXTScope.h"

@interface GiftListViewModel ()

@property (nonatomic, assign) NSUInteger loadGiftListResult;
@property (nonatomic, strong) FXPage<GiftItem *> *giftsPage;
@property (nonatomic, weak) GiftItem *selectedGiftItem;

@end

@implementation GiftListViewModel

#pragma mark - Properties
- (void)asyncLoadGiftList {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        @strongify(self);
        NSArray<GiftItem *> *items = [GiftManager giftItems];
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.giftsPage = [FXPage pageWithModels:items];
            self.loadGiftListResult = items.count ? 0 : 1;
        });
    });
}

#pragma mark - FXDataSource
- (NSUInteger)sectionCount {
    return 1;
}

- (NSUInteger)itemsCountInSection:(NSUInteger)section {
    return !section ? self.giftsPage.count : 0;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    return !indexPath.section ? [self.giftsPage modelAtIndex:indexPath.row] : nil;
}

- (NSIndexPath *)indexPathOfModel:(id)model {
    NSIndexPath *indexPath = nil;
    if (model) {
        NSInteger index = [self.giftsPage indexOfModel:model];
        if (NSNotFound != index) {
            return [NSIndexPath indexPathForItem:index inSection:0];
        }
    }
    return indexPath;
}

- (void)setSelected:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath {
    GiftItem *item = nil;
    if ((item = [self modelAtIndexPath:indexPath])) {
        if (selected && item != self.selectedGiftItem) {
            self.selectedGiftItem = item;
        }
        else if (item == self.selectedGiftItem) {
            self.selectedGiftItem = nil;
        }
    }
}

@end
