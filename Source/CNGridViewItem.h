//
//  CNGridViewItem.h
//
//  Created by cocoa:naut on 06.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2012 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>


__unused static NSString *kCNDefaultItemIdentifier;


@interface CNGridViewItem : NSView

#pragma mark - Initialization
/** @name Initialization */


/**
 Initializes and returns a `CNGridView` item object having the given image and title as visible content.
 */
- (id)initWithImage:(NSImage*)itemImage title:(NSString*)itemTitle;

/**
 Initializes and returns a `CNGridView` item object having the given `NSView` as content.
 */
- (id)initWithContentView:(NSView*)contentView;



#pragma mark - Item Default Content
/** @name Item Default Content */

/**
 ...
 */
@property (strong) IBOutlet NSImage *itemImage;

/**
 ...
 */
@property (strong) IBOutlet NSString *itemTitle;



#pragma mark - Item external Content
/** @name Item external Content */

/**
 ...
 */
@property (strong) NSView *contentView;



#pragma mark - Appearance
/** @name Appearance */

/**
 ...
 */
@property (nonatomic, strong) NSColor *backgroundColor;

/**
 ...
 */
@property (nonatomic, assign) NSUInteger contentInset;

/**
 ...
 */
@property (nonatomic, assign) NSUInteger itemBorderRadius;

/**
 ...
 */
@property (nonatomic, assign) BOOL useHover;

/**
 ...
 */
@property (nonatomic, strong) NSColor *hoverBackgroundColor;

/**
 ...
 */
@property (nonatomic, assign) BOOL useSelectionRing;

/**
 ...
 */
@property (nonatomic, strong) NSColor *selectionRingColor;

/**
 ...
 */
@property (nonatomic, strong) NSColor *selectionRingLineWidth;

/**
 ...
 */
@property (nonatomic, strong) NSColor *selectionBackgroundColor;



#pragma mark - Selection and Hovering
/** @name Selection and Hovering */

/**
 ...
 */
@property (nonatomic, assign, getter = isItemSelected) BOOL itemSelected;

/**
 ...
 */
@property (nonatomic, assign, getter = isItemSelectable) BOOL itemSelectable;

@end
