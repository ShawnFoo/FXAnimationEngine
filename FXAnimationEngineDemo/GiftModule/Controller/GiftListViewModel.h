//
//  GiftListViewModel.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXDataSource.h"
#import "GiftItem.h"

@interface GiftListViewModel : NSObject <FXDataSource>

/**
 0 - success, 1 - empty
 */
@property (nonatomic, readonly) NSUInteger loadGiftListResult;
@property (nonatomic, weak, readonly) GiftItem *selectedGiftItem;

- (void)asyncLoadGiftList;
- (void)setSelected:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath;

@end
