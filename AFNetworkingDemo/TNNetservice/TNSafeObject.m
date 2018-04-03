//
//  TNSafeObject.m

//
//  Created by neon on 2018/4/3.
//  Copyright © 2018年 neon. All rights reserved.
//

#import "TNSafeObject.h"

@implementation TNSafeObject

+ (BOOL)isNull:(id)object {
	if (object == nil) {
		return YES;
	}
	
	if ([object isEqual:[NSNull null]]) {
		return YES;
	}
	
	if ([object isKindOfClass:[NSNull class]]) {
		return  YES;
	}
	
	if ([object isKindOfClass:[NSArray class]]) {
		return ((NSArray *)object).count == 0;
	}
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		return ((NSDictionary *)object).count == 0;
	}
	
	
	if ([object isKindOfClass:[NSString class]]) {
		if (((NSString *)object).length == 0) {
			return YES;
		}
		if ([object isEqualToString:@"(null)"] ||
			[object isEqualToString:@"<null>"] ||
			[object isEqualToString:@"<nil>"] ||
			[object isEqualToString:@""]) {
			return YES;
		}
	}
	
	return NO;
}
	
+ (NSDictionary *)dictionaryInfo:(id)object
	{
		if (!object) {
			return @{};
		}
		if ([object isKindOfClass:[NSDictionary class]]) {
			return object;
		}
		return @{};
	}
	
+ (NSString *)stringInfo:(id)object
	{
		if ([TNSafeObject isNull:object]) {
			return @"";
		}
		if ([object isKindOfClass:[NSString class]]) {
			return object;
		}
		return [object description];
	}
	
+ (NSArray *)ArrayInfo:(id)object
	{
		if ([object isKindOfClass:[NSArray class]]) {
			return object;
		}
		return @[];
	}
	
+ (BOOL)boolValue:(id)object
	{
		if ([TNSafeObject isNull:object]) {
			return NO;
		}
		if ([object intValue] == 0) {
			return NO;
		}
		return YES;
	}

@end
