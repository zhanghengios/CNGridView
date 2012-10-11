//
//  NSColor+CNGridViewPalette.h
//  SieveMail
//
//  Created by cocoa:naut on 11.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 This is the standard `CNGridView` color palette. All colors can be overwritten by using the properties.
 */


@interface NSColor (CNGridViewPalette)


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - GridView Item Colors

/** Returns the standard `CNGridViewItem` background color */
+ (NSColor *)itemBackgroundColor;

/** Returns the standard `CNGridViewItem` background color when the item is in mouse over state (property must be enabled) */
+ (NSColor *)itemBackgroundHoverColor;

/** Returns the standard `CNGridViewItem` background color when the item is selected */
+ (NSColor *)itemBackgroundSelectionColor;

/** Returns the standard `CNGridViewItem` selection ring color when the item is selected */
+ (NSColor *)itemSelectionRingColor;

@end
