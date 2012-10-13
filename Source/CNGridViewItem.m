//
//  CNGridViewItem.m
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

#import "CNGridViewItem.h"
#import "NSColor+CNGridViewPalette.h"
#import "CNGridViewItemLayout.h"


static CGSize kDefaultItemSize;


@interface CNGridViewItem ()
@property (strong) NSImageView *itemImageView;
@end

@implementation CNGridViewItem

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

+ (void)initialize
{
    kCNDefaultItemIdentifier = @"CNGridViewItem";
    kDefaultItemSize         = NSMakeSize(96, 96);
}

+ (CGSize)defaultItemSize
{
    return kDefaultItemSize;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithLayout:(CNGridViewItemLayout *)layout reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self init];
    if (self) {
        [self initProperties];
        _standardLayout  = layout;
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)initProperties
{
    /// Reusing Grid View Items
    self.identifier = kCNDefaultItemIdentifier;

    /// Item Default Content
    _itemImage  = nil;
    _itemTitle  = @"";
    _index      = CNItemIndexNoIndex;

    /// Grid View Item Layout
    _standardLayout     = [CNGridViewItemLayout defaultLayout];
    _hoverLayout        = _standardLayout;
    _selectionLayout    = _standardLayout;

    /// Selection and Hovering
    _itemSelected       = NO;
    _itemSelectable     = YES;
    _useHover           = NO;
    _useSelectionRing   = YES;
}

- (BOOL)isFlipped
{
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reusing Grid View Items

- (void)prepareForReuse
{
    _itemImage          = nil;
    _itemTitle          = @"";
    _index              = CNItemIndexNoIndex;
    _itemSelected       = NO;
    _itemSelectable     = YES;
    _useHover           = NO;
    _useSelectionRing   = YES;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Grid View Item Layout




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ViewDrawing

- (void)drawRect:(NSRect)rect
{
    NSRect dirtyRect = self.bounds;
    [NSGraphicsContext saveGraphicsState];
    
    NSRect srcRect = NSZeroRect;
    srcRect.size = self.itemImage.size;
    NSRect imageRect = NSZeroRect;
    NSRect textRect = NSZeroRect;

    if (self.standardLayout.visibleContentMask & (CNGridViewItemVisibleContentImage | CNGridViewItemVisibleContentTitle)) {
        imageRect = NSMakeRect((NSWidth(dirtyRect) - self.itemImage.size.width) / 2,
                               ((NSHeight(dirtyRect) - self.itemImage.size.height) / 2) - 14,
                               self.itemImage.size.width,
                               self.itemImage.size.height);
        [self.itemImage drawInRect:imageRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

        textRect = NSMakeRect(dirtyRect.origin.x + 5,
                              NSHeight(dirtyRect) - 20,
                              NSWidth(dirtyRect) - 10,
                              15);
        [self.itemTitle drawInRect:textRect withAttributes:nil];
    }

    else if (self.standardLayout.visibleContentMask & CNGridViewItemVisibleContentImage) {
        imageRect = NSMakeRect((NSWidth(dirtyRect) - self.itemImage.size.width) / 2,
                                      (NSHeight(dirtyRect) - self.itemImage.size.height) / 2,
                                      self.itemImage.size.width,
                                      self.itemImage.size.height);
    }

    else if (self.standardLayout.visibleContentMask & CNGridViewItemVisibleContentTitle) {
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
