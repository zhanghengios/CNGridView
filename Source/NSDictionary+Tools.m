//
//  NSDictionary+Tools.m
//  CNGridView Example
//
//  Created by cocoa:naut on 12.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "NSDictionary+Tools.h"

@implementation NSDictionary (Tools)

- (BOOL)containsKey:(id)key
{
    __block BOOL containsKey = NO;
    [self.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:key]) {
            containsKey = YES;
            *stop = YES;
        }
    }];
    return containsKey;
}

@end
