//
//  JCPage.h
//  FXKit
//
//  Created by ShawnFoo on 3/29/16.
//  Copyright © 2016 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页Model的管理模型, 所有方法均线程安全
 */
@interface FXPage<__covariant ObjectType> : NSObject

@property (nullable, copy, nonatomic) NSArray *models;

@property (readonly, nonatomic) NSUInteger startIndex;
@property (readonly, nonatomic) NSUInteger lastIndex;
@property (nullable, readonly, nonatomic) id lastObject;

@property (assign, nonatomic) NSUInteger onePageRows;
@property (readonly, nonatomic) NSUInteger count;

- (nullable ObjectType)modelAtIndex:(NSUInteger)index;
- (NSInteger)indexOfModel:(ObjectType)model;

- (BOOL)insertModelToStart:(ObjectType)model;
- (BOOL)insertModelsToStart:(NSArray<ObjectType> *)models;
- (BOOL)insertModel:(ObjectType)model atIndex:(NSUInteger)index;

- (BOOL)appendModel:(ObjectType)model;
- (BOOL)appendModels:(NSArray<ObjectType> *)models;

- (BOOL)replaceModel:(ObjectType)model atIndex:(NSUInteger)index;

- (BOOL)removeModel:(ObjectType)model;
- (BOOL)removeModelAtIndex:(NSUInteger)index;
- (void)removeAllModels;

- (void)sortArray:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))compareBlock;

- (BOOL)modelsEqualTo:(NSArray<ObjectType> *)models;

@end


@interface FXPage<ObjectType> (Factory)

+ (instancetype)page;
+ (instancetype)pageWithModels:(NSArray<ObjectType> *)models;

@end

NS_ASSUME_NONNULL_END
