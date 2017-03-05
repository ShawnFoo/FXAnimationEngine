//
//  NSObject+FXJSONConvert.h
//  FXKit
//
//  Created by ShawnFoo on 9/22/15.
//  Copyright (c) 2015 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONConvert)

+ (id)fx_instanceWithJSON:(NSString *)json;
+ (id)fx_instanceWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)fx_instancesWithArray:(NSArray *)array;

- (id)fx_toJSONObject;
- (NSString *)fx_toJSONString;
- (NSDictionary *)fx_toDictionary;
- (NSDictionary *)fx_toDictionaryExcludeNilValues;

- (NSString *)fx_modelDescription;

@end

