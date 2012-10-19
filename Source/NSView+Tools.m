//
//  NSView+Tools.m
//  CNGridView Example
//
//  Created by cocoa:naut on 18.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "NSView+Tools.h"

@implementation NSView (Tools)

- (BOOL)isSubviewOfView:(NSView *)theView
{
    __block BOOL isSubView = NO;
    [[theView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self isEqualTo:(NSView *)obj]) {
            isSubView = YES;
            *stop = YES;
        }
    }];
    return isSubView;
}

- (BOOL)containsSubView:(NSView *)subview
{
    __block BOOL containsSubView = NO;
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([subview isEqualTo:(NSView *)obj]) {
            containsSubView = YES;
            *stop = YES;
        }
    }];
    return containsSubView;
}

@end
