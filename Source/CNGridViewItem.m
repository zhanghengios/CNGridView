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


static NSColor *kDefaultSelectionRingColor, *kDefaultBackgroundColor, *kDefaultBackgroundColorHover;
static CGFloat kDefaultSelectionRingLineWidth;
static CGFloat kDefaultSelectionRingRadius;
static CGFloat kDefaultContentInset;
static NSSize kDefaultItemSize;


@interface CNGridViewItem ()
@property (nonatomic, strong) NSView *currentContentView;
@end

@implementation CNGridViewItem

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

+ (void)initialize
{
    kCNDefaultItemIdentifier        = @"CNGridViewItem";
    kDefaultBackgroundColor         = [NSColor colorWithCalibratedWhite:0.0 alpha:0.05];
    kDefaultBackgroundColorHover    = [NSColor colorWithCalibratedWhite:0.0 alpha:0.1];
    kDefaultSelectionRingColor      = [NSColor colorWithCalibratedRed:0.346 green:0.531 blue:0.792 alpha:1.000];
    kDefaultSelectionRingLineWidth  = 4.0;
    kDefaultSelectionRingRadius     = 6.0;
    kDefaultContentInset            = 3.0;
    kDefaultItemSize                = NSMakeSize(64.0, 64.0);
}

+ (NSImage*)placeHolderImage
{
    static NSImage *placeHolderImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSSize size = kDefaultItemSize;

        placeHolderImage = [[NSImage alloc] initWithSize:size];
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                                 initWithBitmapDataPlanes:NULL
                                 pixelsWide:size.width pixelsHigh:size.height
                                 bitsPerSample:8 samplesPerPixel:4
                                 hasAlpha:YES isPlanar:NO
                                 colorSpaceName:NSCalibratedRGBColorSpace
                                 bytesPerRow:0 bitsPerPixel:0];

        [placeHolderImage addRepresentation:rep];
        [placeHolderImage lockFocus];

        [[NSColor clearColor] setFill];
        NSRectFill(NSMakeRect(0,0,size.width,size.height));

        /// begin: image content drawing
        NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5, 5, size.width-10, size.height-10)
                                                                   xRadius:7.0
                                                                   yRadius:7.0];
        CGFloat borderDash[2];
        borderDash[0] = 10.0;
        borderDash[1] = 6.0;
        [borderPath setLineDash:borderDash count:2 phase:0.0];
        [borderPath setLineWidth:3.0];
        [[NSColor lightGrayColor] setStroke];
        [borderPath stroke];
        /// end: image content drawing

        [placeHolderImage unlockFocus];
	});
    return placeHolderImage;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
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

- (id)initWithImage:(NSImage*)itemImage title:(NSString*)itemTitle
{
    return [self init];
}

- (id)initWithContentView:(NSView*)contentView
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
    _gridViewItemImage = [[self class] placeHolderImage];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ViewDrawing

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
