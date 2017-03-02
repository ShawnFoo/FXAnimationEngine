//
//  FXAnimationGroup_Private.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/2/10.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "FXAnimationGroup.h"

@interface FXAnimationGroup ()

@property (nonatomic, assign) NSUInteger p_framesCount;

- (void)p_mergeAndReverseAnimationFrames;

@end
