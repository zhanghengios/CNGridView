//
//  NSColor+CNGridViewPalette.m
//  SieveMail
//
//  Created by cocoa:naut on 11.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "NSColor+CNGridViewPalette.h"

@implementation NSColor (CNGridViewPalette)

+ (NSColor *)itemBackgroundColor
{
    return [NSColor colorWithCalibratedWhite:0.0 alpha:0.05];
}

+ (NSColor *)itemBackgroundHoverColor
{
    return [NSColor colorWithCalibratedWhite:0.0 alpha:0.1];
}

+ (NSColor *)itemBackgroundSelectionColor
{
    return [NSColor colorWithCalibratedWhite:0.000 alpha:0.250];
}

+ (NSColor *)itemSelectionRingColor
{
    return [NSColor colorWithCalibratedRed:0.346 green:0.531 blue:0.792 alpha:1.000];
}

@end
