//
//  FXPage.m
//  FXKit
//
//  Created by ShawnFoo on 3/29/16.
//  Copyright © 2016 ShawnFoo. All rights reserved.
//

#import "FXPage.h"

static dispatch_queue_t kPageSerialQueue;
static NSUInteger kDefaultOnePageRows;

@interface FXPage () {
    NSMutableArray *_models;
}

@end

@implementation FXPage

#pragma mark - LifeCycle
+ (void)initialize {
    if (self == [FXPage class]) {
        kPageSerialQueue = dispatch_queue_create("com.ShawnFoo.Util.model.page.serialQueue", NULL);
        kDefaultOnePageRows = 20;
    }
}

#pragma mark - Accessor
- (void)setModels:(NSArray *)models {
    dispatch_sync(kPageSerialQueue, ^{
        if (models) {
            if (!_models) {
                _models = [NSMutableArray arrayWithCapacity:models.count];
            }
            [_models setArray:models.copy];
        }
        else {
            _models = nil;
        }
    });
}

- (NSArray *)models {
    return [_models copy];
}

- (NSUInteger)startIndex {
    return _models.count;
}

- (NSUInteger)lastIndex {
    __block NSUInteger bLastIndex;
    dispatch_sync(kPageSerialQueue, ^{
        bLastIndex = _models.count > 0 ? (_models.count-1) : 0;
    });
    return bLastIndex;
}

- (id)lastObject {
    __block id bLastObject = nil;
    dispatch_sync(kPageSerialQueue, ^{
        bLastObject = _models.lastObject;
    });
    return bLastObject;
}

- (NSUInteger)onePageRows {
    return !_onePageRows ? kDefaultOnePageRows : _onePageRows;
}

- (NSUInteger)count {
    __block NSUInteger bCount;
    dispatch_sync(kPageSerialQueue, ^{
        bCount = _models.count;
    });
    return bCount;
}

#pragma mark - Operations
#pragma mark Search
- (id)modelAtIndex:(NSUInteger)index {
    __block id bModel = nil;
    dispatch_sync(kPageSerialQueue, ^{
        if (index < _models.count) {
            bModel = _models[index];
        }
    });
    return bModel;
}

- (NSInteger)indexOfModel:(id)model {
    __block NSInteger bIndex = NSNotFound;
    if (model) {
        dispatch_sync(kPageSerialQueue, ^{
            bIndex = [_models indexOfObject:model];
        });
    }
    return bIndex;
}

#pragma mark Add
- (BOOL)insertModelToStart:(id)model {
    if (model) {
        __block BOOL bAddedData = NO;
        dispatch_sync(kPageSerialQueue, ^{
            if (!_models) {
                _models = [NSMutableArray arrayWithCapacity:1];
            }
            if ([_models containsObject:model]) {
                [_models removeObject:model];
            }
            [_models insertObject:model atIndex:0];
            bAddedData = YES;
        });
        return bAddedData;
    }
    return NO;
}

- (BOOL)insertModelsToStart:(NSArray *)models {
    if (models.count) {
        __block BOOL bAddedData = NO;
        dispatch_sync(kPageSerialQueue, ^{
            if (!_models) {
                _models = [NSMutableArray arrayWithCapacity:models.count];
            }
            NSUInteger oldCount = models.count;
            [_models setArray:[models arrayByAddingObjectsFromArray:_models]];
            [_models setArray:[self removeDuplicatedElementsInArray:_models]];
            bAddedData = oldCount != _models.count;
        });
        return bAddedData;
    }
    return NO;
}

- (BOOL)insertModel:(id)model atIndex:(NSUInteger)index {
    if (model && index < _models.count) {
        dispatch_sync(kPageSerialQueue, ^{
            [_models insertObject:model atIndex:index];
        });
        return YES;
    }
    return NO;
}

- (BOOL)appendModel:(id)model {
    if (model) {
        __block BOOL bAddedData = NO;
        dispatch_sync(kPageSerialQueue, ^{
            if ([_models containsObject:model]) { return; }
            if (!_models) {
                _models = [NSMutableArray arrayWithCapacity:1];
            }
            [_models addObject:model];
            bAddedData = YES;
        });
        return bAddedData;
    }
    return NO;
}

- (BOOL)appendModels:(NSArray *)models {
    if (models.count > 0) {
        __block BOOL bAddedData = NO;
        dispatch_sync(kPageSerialQueue, ^{
            if (!_models) {
                _models = [NSMutableArray arrayWithCapacity:models.count];
            }
            NSUInteger oldCount = _models.count;
            [_models addObjectsFromArray:models];
            [_models setArray:[self removeDuplicatedElementsInArray:_models]];
            NSUInteger newCount = _models.count;
            bAddedData = newCount != oldCount;
        });
        return bAddedData;
    }
    return NO;
}

#pragma mark Replace
- (BOOL)replaceModel:(id)model atIndex:(NSUInteger)index {
    if (model && index < _models.count) {
        dispatch_sync(kPageSerialQueue, ^{
            [_models replaceObjectAtIndex:index withObject:model];
        });
    }
    return NO;
}

#pragma mark Remove
- (BOOL)removeModel:(id)model {
    __block BOOL bSuccess = NO;
    if (model) {
        dispatch_sync(kPageSerialQueue, ^{
            if ([_models containsObject:model]) {
                [_models removeObject:model];
                bSuccess = YES;
            }
        });
    }
    return bSuccess;
}

- (BOOL)removeModelAtIndex:(NSUInteger)index {
    __block BOOL bSuccess = NO;
    dispatch_sync(kPageSerialQueue, ^{
        if (index < _models.count) {
            [_models removeObjectAtIndex:index];
            bSuccess = YES;
        }
    });
    return bSuccess;
}

- (void)removeAllModels {
    dispatch_sync(kPageSerialQueue, ^{
        [_models removeAllObjects];
    });
}

#pragma mark Sort
- (void)sortArray:(NSComparisonResult (^)(id obj1, id obj2))compareBlock {
    dispatch_sync(kPageSerialQueue, ^{
        [_models sortUsingComparator:compareBlock];
    });
}

#pragma mark Equal
- (BOOL)modelsEqualTo:(NSArray *)models {
    return [models isEqualToArray:_models];
}

#pragma mark - ShortCuts
- (NSArray *)removeDuplicatedElementsInArray:(NSArray *)array {
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:array];
    return set.array;
}

@end


@implementation FXPage (Factory)

+ (instancetype)page {
    return [FXPage new];
}

+ (instancetype)pageWithModels:(NSArray *)models {
    FXPage *page = [self page];
    [page appendModels:models];
    return page;
}

@end
