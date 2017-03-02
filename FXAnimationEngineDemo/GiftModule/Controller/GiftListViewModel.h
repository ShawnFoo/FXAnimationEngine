//
//  GiftListViewModel.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftItem.h"

@interface GiftListViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray<GiftItem *> *items;

- (void)asyncLoadGiftList;

@end
