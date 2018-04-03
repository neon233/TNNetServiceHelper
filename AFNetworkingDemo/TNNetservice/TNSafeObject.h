//
//  TNSafeObject.h
//  
//
//  Created by neon on 2018/4/3.
//  Copyright © 2018年 neon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNSafeObject : NSObject

/**
 *  判断对象是否为空
 *
 *  @param object 传入的实例
 *
 *  @return 返回值,NO表示该对象不为空,YES表示为空
 */
+ (BOOL)isNull:(id)object;


/**
 *  获取字典对象
 */
+ (NSDictionary *)dictionaryInfo:(id)object;

/**
 *  获取字典对象
 */
+ (NSString *)stringInfo:(id)object;

/**
 *  获取字典对象
 */
+ (NSArray *)ArrayInfo:(id)object;

+ (BOOL)boolValue:(id)object;

@end
