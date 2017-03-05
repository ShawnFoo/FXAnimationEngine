//
//  FXDataSource.h
//  FXKit
//
//  Created by ShawnFoo on 11/10/15.
//  Copyright © 2015 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FXDataSource <NSObject>

@required
- (NSUInteger)sectionCount;
- (NSUInteger)itemsCountInSection:(NSUInteger)section;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfModel:(id)model;

@end
