//
//  NSObject+FXJSONConvert.m
//
//
//  Created by ShawnFoo on 9/22/15.
//  Copyright (c) 2015 ShawnFoo. All rights reserved.
//

#import "NSObject+FXJSONConvert.h"
#import <YYModel/YYModel.h>
#import <objc/runtime.h>

#pragma mark - NSObject + FXJSONConvert

@implementation NSObject (JSONConvert)

+ (id)fx_instanceWithJSON:(NSString *)json {
    return [self yy_modelWithJSON:json];
}

+ (id)fx_instanceWithDictionary:(NSDictionary *)dictionary {
    return [self yy_modelWithDictionary:dictionary];
}

+ (NSArray *)fx_instanceWithArray:(NSArray *)array {
    return [NSArray yy_modelArrayWithClass:self json:array];
}


- (id)fx_toJSONObject {
    return [self yy_modelToJSONObject];
}

- (NSString *)fx_toJSONString {
    return [self yy_modelToJSONString];
}

- (NSDictionary *)fx_toDictionary {
    return [self fx_toDictionaryExcludeNilValues:NO];
}

- (NSDictionary *)fx_toDictionaryExcludeNilValues {
    return [self fx_toDictionaryExcludeNilValues:YES];
}

- (NSDictionary *)fx_toDictionaryExcludeNilValues:(BOOL)excludeNil {
    
    NSDictionary *dictionary = nil;
    @autoreleasepool {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:1];
        Class cls = object_getClass(self);
        void (^mapValues)(Class) = ^(Class __class) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(__class, &count);
            NSSet *excludes = nil;
            if (class_getSuperclass(__class) == [NSObject class]) {
                excludes = [NSSet setWithObjects:@"debugDescription",
                            @"description",
                            @"hash",
                            @"superclass",
                            nil];
            }
            if (properties) {
                for (int i = 0; i <count; i++) {
                    NSString *key = [NSString stringWithFormat:@"%s", property_getName(properties[i])];
                    if (![excludes containsObject:key]) {
                        id value = [self valueForKey:key];
                        if (excludeNil && !value) {
                            continue;
                        }
                        temp[key] = [NSString stringWithFormat:@"%@", value?:@""];
                    }
                }
                free(properties);
            }
        };
        while (cls != [NSObject class]) {
            mapValues(cls);
            cls = class_getSuperclass(cls);
        }
        dictionary = [temp copy];
    }
    return dictionary;
}

- (NSString *)fx_modelDescription {
    return [self fx_toJSONString];
}

@end
