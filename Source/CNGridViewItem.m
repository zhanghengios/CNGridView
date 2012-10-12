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


static NSColor *kDefaultSelectionRingColor, *kDefaultBackgroundColor, *kDefaultBackgroundColorHover, *kDefaultBackgroundColorSelection;
static CGFloat kDefaultSelectionRingLineWidth;
static CGFloat kDefaultSelectionRingRadius;
static CGFloat kDefaultContentInset;
static CGSize kDefaultItemSize;


@interface CNGridViewItem ()
@property (nonatomic, strong) NSView *currentContentView;
@property (strong) NSImageView *itemImageView;
@end

@implementation CNGridViewItem

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

+ (void)initialize
{
    kCNDefaultItemIdentifier            = @"CNGridViewItem";
    kDefaultBackgroundColor             = [NSColor itemBackgroundColor];
    kDefaultBackgroundColorHover        = [NSColor itemBackgroundHoverColor];
    kDefaultBackgroundColorSelection    = [NSColor itemBackgroundSelectionColor];
    kDefaultSelectionRingColor          = [NSColor itemSelectionRingColor];
    kDefaultSelectionRingLineWidth      = 4.0;
    kDefaultSelectionRingRadius         = 6.0;
    kDefaultContentInset                = 3.0;
    kDefaultItemSize                    = [[self class] defaultItemSize];
}

+ (CGSize)defaultItemSize
{
    return NSMakeSize(136, 163);
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
    }
    return self;
}

- (void)initProperties
{
    _currentContentView = self;

    _itemImage = nil;
    _itemTitle = @"";
    
    _backgroundColor = kDefaultBackgroundColor;
    _hoverBackgroundColor = kDefaultBackgroundColorHover;
    _selectionBackgroundColor = kDefaultBackgroundColorSelection;

    _index = CNItemIndexNoIndex;
    self.identifier = kCNDefaultItemIdentifier;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reusing Grid View Items

- (void)prepareForReuse
{
    
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ViewDrawing

- (void)drawRect:(NSRect)dirtyRect
{
//    [[[NSColor grayColor] colorWithAlphaComponent:0.2] setFill];
//    NSRectFill(dirtyRect);

//    if (self.itemTitle == nil || [self.itemTitle isEqualToString:@""]) {
        NSRect imageRect = NSMakeRect((NSWidth(dirtyRect) - self.itemImage.size.width) / 2,
                                      (NSHeight(dirtyRect) - self.itemImage.size.height) / 2,
                                      self.itemImage.size.width,
                                      self.itemImage.size.height);
        NSImageView *itemImageView = [[NSImageView alloc] initWithFrame:imageRect];
        itemImageView.image = self.itemImage;
        itemImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        [self addSubview:itemImageView];
        [itemImageView setNeedsDisplay];
//    } else {
//
//    }
}

@end
