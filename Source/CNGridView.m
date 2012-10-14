//
//  CNGridView.m
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

#import <QuartzCore/QuartzCore.h>
#import "NSColor+CNGridViewPalette.h"
#import "CNGridView.h"
#import "CNGridViewItem.h"



@interface CNGridView () {
    NSMutableDictionary *_keyedVisibleItems;
    NSMutableDictionary *_reuseableItems;
    NSMutableArray *_selectedItems;
    NSUInteger _numberOfItems;
    NSTrackingArea *_gridViewTrackingArea;
    BOOL _isInitialCall;
}

- (void)setupDefaults;
- (void)boundsOfViewDidChanged;
- (void)refreshGridViewAnimated:(BOOL)animated;
- (void)updateReuseableItems;
- (void)updateVisibleItems;
- (NSIndexSet *)indexesForVisibleItems;
- (void)arrangeGridViewItemsAnimated:(BOOL)animated;
- (NSRange)currentRange;
- (NSRect)rectForItemAtIndex:(NSUInteger)index;
- (NSUInteger)columnsInGridView;
- (NSUInteger)allOverRowsInGridView;
- (NSUInteger)visibleRowsInGridView;
- (NSRect)clippedRect;
@end


@implementation CNGridView

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        _delegate = nil;
        _dataSource = nil;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults];
        _delegate = nil;
        _dataSource = nil;
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

- (void)setupDefaults
{
    /// private properties
    _keyedVisibleItems = [[NSMutableDictionary alloc] init];
    _reuseableItems    = [[NSMutableDictionary alloc] init];
    _selectedItems     = [[NSMutableArray alloc] init];

    /// public properties
    _gridViewTitle  = nil;

    _backgroundColor = [NSColor gridViewBackgroundColor];
    _elasticity      = YES;
    _itemSize        = [CNGridViewItem defaultItemSize];

    _allowsSelection         = YES;
    _allowsMultipleSelection = NO;

    _isInitialCall = YES;

    [[self enclosingScrollView] setDrawsBackground:YES];
    
    NSClipView *clipView = [[self enclosingScrollView] contentView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsOfViewDidChanged) name:NSViewBoundsDidChangeNotification object:clipView];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setItemSize:(NSSize)itemSize
{
    _itemSize = itemSize;
    [self refreshGridViewAnimated:YES];
}

- (void)setElasticity:(BOOL)elasticity
{
    _elasticity = elasticity;
    NSScrollView *scrollView = [self enclosingScrollView];
    if (_elasticity) {
        [scrollView setHorizontalScrollElasticity:NSScrollElasticityAllowed];
        [scrollView setVerticalScrollElasticity:NSScrollElasticityAllowed];
    } else {
        [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
        [scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [[self enclosingScrollView] setBackgroundColor:_backgroundColor];
}




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)boundsOfViewDidChanged
{
    [self updateReuseableItems];
    [self updateVisibleItems];
    [self arrangeGridViewItemsAnimated:NO];
}

- (void)refreshGridViewAnimated:(BOOL)animated
{
    NSRect scrollRect = [self frame];
    scrollRect.size.width = scrollRect.size.width;
    scrollRect.size.height = [self allOverRowsInGridView] * self.itemSize.height;
    [super setFrame:scrollRect];

    [self updateReuseableItems];
    [self updateVisibleItems];
    [self arrangeGridViewItemsAnimated:animated];
}

- (void)updateReuseableItems
{
    NSRange currentRange = [self currentRange];

    [[_keyedVisibleItems allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CNGridViewItem *item = (CNGridViewItem *)obj;
        if (!NSLocationInRange(item.index, currentRange)) {
            [_keyedVisibleItems removeObjectForKey:[NSNumber numberWithUnsignedInteger:item.index]];
            [item removeFromSuperview];
            [item prepareForReuse];

            NSMutableSet *reuseQueue = [_reuseableItems objectForKey:item.reuseIdentifier];
            if (reuseQueue == nil)
                reuseQueue = [NSMutableSet set];
            [reuseQueue addObject:item];
            [_reuseableItems setObject:reuseQueue forKey:item.reuseIdentifier];
        }
    }];
}

- (void)updateVisibleItems
{
    NSRange currentRange = [self currentRange];
    NSMutableIndexSet *visibleItemIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:currentRange];

    [visibleItemIndexes removeIndexes:[self indexesForVisibleItems]];

    /// update all visible items
    [visibleItemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        CNGridViewItem *item = [self gridView:self itemAtIndex:idx inSection:0];
        if (item) {
            item.index = idx;
            if (_isInitialCall) {
                [item setAlphaValue:0.0];
                [item setFrame:[self rectForItemAtIndex:idx]];
            }
            [_keyedVisibleItems setObject:item forKey:[NSNumber numberWithUnsignedInteger:item.index]];
            [self addSubview:item];
        }
    }];
}

- (NSIndexSet *)indexesForVisibleItems
{
    __block NSMutableIndexSet *indexesForVisibleItems = [[NSMutableIndexSet alloc] init];
    [_keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [indexesForVisibleItems addIndex:[(CNGridViewItem *)obj index]];
    }];
    return indexesForVisibleItems;
}

- (void)arrangeGridViewItemsAnimated:(BOOL)animated
{
    if (_isInitialCall && _keyedVisibleItems.count > 0) {
        _isInitialCall = NO;
        animated = YES;
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:(animated ? 0.23 : 0.0)];
        [_keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[(CNGridViewItem *)obj animator] setAlphaValue:1.0];
        }];
        [NSAnimationContext endGrouping];
    }

    else if (_keyedVisibleItems.count > 0) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [_keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSRect newRect = [self rectForItemAtIndex:[(CNGridViewItem *)obj index]];
            [[(CNGridViewItem *)obj animator] setFrame:newRect];
        }];
        [NSAnimationContext endGrouping];
    }
}

- (NSRange)currentRange
{
    NSRect clippedRect  = [self clippedRect];
    NSUInteger columns  = [self columnsInGridView];
    NSUInteger rows     = [self visibleRowsInGridView];

    NSUInteger rangeStart = 0;
    if (clippedRect.origin.y > _itemSize.height) {
        rangeStart = (ceilf(clippedRect.origin.y / _itemSize.height) * columns) - columns;
    }
    NSUInteger rangeLength = MIN(_numberOfItems, (columns * rows) + columns);
    rangeLength = ((rangeStart + rangeLength) > _numberOfItems ? _numberOfItems - rangeStart : rangeLength);

    NSRange rangeForVisibleRect = NSMakeRange(rangeStart, rangeLength);
    return rangeForVisibleRect;
}

- (NSRect)rectForItemAtIndex:(NSUInteger)index
{
    NSUInteger columns = [self columnsInGridView];
    NSRect itemRect = NSMakeRect((index % columns) * _itemSize.width,
                                 ((index - (index % columns)) / columns) * _itemSize.height,
                                 _itemSize.width,
                                 _itemSize.height);
    return itemRect;
}

- (NSUInteger)columnsInGridView
{
    NSRect visibleRect  = [self clippedRect];
    NSUInteger columns = floorf((float)NSWidth(visibleRect) / _itemSize.width);
    columns = (columns < 1 ? 1 : columns);
    return columns;
}

- (NSUInteger)allOverRowsInGridView
{
    NSUInteger allOverRows = ceilf((float)_numberOfItems / [self columnsInGridView]);
    return allOverRows;
}

- (NSUInteger)visibleRowsInGridView
{
    NSRect visibleRect  = [self clippedRect];
    NSUInteger visibleRows = ceilf((float)NSHeight(visibleRect) / self.itemSize.height);
    return visibleRows;
}

- (NSRect)clippedRect
{
    return [[[self enclosingScrollView] contentView] bounds];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSView Methods

- (BOOL)isFlipped
{
    return YES;
}

- (void)setFrame:(NSRect)frameRect
{
    BOOL animated = (self.frame.size.width == frameRect.size.width ? NO: YES);
    [super setFrame:frameRect];
    [self refreshGridViewAnimated:animated];
    [[self enclosingScrollView] setNeedsDisplay:YES];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring the GridView

- (NSUInteger)numberOfVisibleItems
{
    return _keyedVisibleItems.count;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creating GridView Items

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    CNGridViewItem *reusableItem = nil;
    NSMutableSet *reuseQueue = [_reuseableItems objectForKey:identifier];
    if (reuseQueue != nil && reuseQueue.count > 0) {
        reusableItem = [reuseQueue anyObject];
        [reuseQueue removeObject:reusableItem];
        [_reuseableItems setObject:reuseQueue forKey:identifier];
    }
    return reusableItem;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reloading GridView Data

- (void)reloadData
{
    _numberOfItems = [self gridView:self numberOfItemsInSection:0];
    [_keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(CNGridViewItem *)obj removeFromSuperview];
    }];
    [_keyedVisibleItems removeAllObjects];
    [_reuseableItems removeAllObjects];
    [self refreshGridViewAnimated:YES];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Scrolling to GridView Items

- (void)scrollToGridViewItem:(CNGridViewItem *)gridViewItem animated:(BOOL)animated
{

}

- (void)scrollToGridViewItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{

}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Tracking Events

- (void)updateTrackingAreas
{
    if (_gridViewTrackingArea)
        [self removeTrackingArea:_gridViewTrackingArea];

    _gridViewTrackingArea = nil;
    _gridViewTrackingArea = [[NSTrackingArea alloc] initWithRect:self.frame
                                                         options:NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                                           owner:self
                                                        userInfo:nil];
    [self addTrackingArea:_gridViewTrackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint location = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:location fromView:nil];
    CNLog(@"location with x: %f; y: %f", point.x, point.y);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView Delegate Callbacks

- (void)gridView:(CNGridView*)gridView willSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willSelectItemAtIndexPath:indexPath];
    }
}

- (void)gridView:(CNGridView*)gridView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)gridView:(CNGridView*)gridView willDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willDeselectItemAtIndexPath:indexPath];
    }
}

- (void)gridView:(CNGridView*)gridView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didDeselectItemAtIndexPath:indexPath];
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView DataSource Callbacks

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:_cmd]) {
        return [self.dataSource gridView:gridView numberOfItemsInSection:section];
    }
    return NSNotFound;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:_cmd]) {
        return [self.dataSource gridView:gridView itemAtIndex:index inSection:section];
    }
    return nil;
}

- (NSUInteger)numberOfSectionsInGridView:(CNGridView *)gridView
{
    if ([self.dataSource respondsToSelector:_cmd]) {
        return [self.dataSource numberOfSectionsInGridView:gridView];
    }
    return NSNotFound;
}

- (NSString *)gridView:(CNGridView *)gridView titleForHeaderInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:_cmd]) {
        return [self.dataSource gridView:gridView titleForHeaderInSection:section];
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForGridView:(CNGridView *)gridView
{
    if ([self.dataSource respondsToSelector:_cmd]) {
        return [self.dataSource sectionIndexTitlesForGridView:gridView];
    }
    return nil;
}

@end
