//
//  NSObject+Protect.h

//
//  Created by neon on 2017/11/13.
//  Copyright © 2017年 MGLive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Protect)
- (NSDictionary *)deleteEmpty:(NSDictionary *)dic;
- (NSArray *)deleteEmptyArr:(NSArray *)arr;
@end
