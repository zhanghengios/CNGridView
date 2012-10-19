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
#import "NSView+Tools.h"
#import "CNGridView.h"
#import "CNGridViewItem.h"




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CNSelectionFrameView

@interface CNSelectionFrameView : NSView
- (id)initWithSelectionFrameColor:(NSColor *)aColor;
@end




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CNGridView

const int CNSingleClick = 1;
const int CNDoubleClick = 2;
const int CNTrippleClick = 3;


struct CNItemPoint {
    NSUInteger column;
    NSUInteger row;
};
typedef struct CNItemPoint CNItemPoint;


@interface CNGridView ()
@property (strong) NSMutableDictionary *keyedVisibleItems;
@property (strong) NSMutableDictionary *reuseableItems;
@property (strong) NSMutableDictionary *selectedItems;
@property (strong) NSMutableDictionary *selectedItemsBySelectionFrame;
@property (strong) NSTrackingArea *gridViewTrackingArea;
@property (assign) BOOL isInitialCall;
@property (assign) NSInteger lastHoveredIndex;
@property (assign) NSInteger lastSelectedIndex;
@property (assign) NSInteger numberOfItems;
@property (strong) NSMutableArray *clickEvents;
@property (strong) NSTimer *clickTimer;
@property (strong) CNSelectionFrameView *selectionFrameView;
@property (assign) CGPoint selectionFrameInitialPoint;
@property (assign) BOOL abortSelection;

- (void)setupDefaults;
- (void)updateVisibleRect;
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
- (NSUInteger)indexForItemAtLocation:(NSPoint)location;
- (CNItemPoint)locationForItemAtIndex:(NSUInteger)itemIndex;
- (void)selectItemAtIndex:(NSUInteger)selectedItemIndex usingModifierFlags:(NSUInteger)modifierFlags;
- (void)handleClicks:(NSTimer *)theTimer;
- (void)handleSingleClickForItemAtIndex:(NSUInteger)selectedItemIndex;
- (void)handleDoubleClickForItemAtIndex:(NSUInteger)selectedItemIndex;
- (void)drawSelectionFrameForMousePointerAtLocation:(NSPoint)location;
- (void)selectItemsCoveredBySelectionFrame:(NSRect)selectionFrame;
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
    _reuseableItems = [[NSMutableDictionary alloc] init];
    _selectedItems = [[NSMutableDictionary alloc] init];
    _selectedItemsBySelectionFrame = [[NSMutableDictionary alloc] init];

    /// public properties
    _gridViewTitle = nil;

    _backgroundColor = [NSColor gridViewBackgroundColor];
    _scrollElasticity = YES;
    _itemSize = [CNGridViewItem defaultItemSize];

    _allowsSelection = YES;
    _allowsMultipleSelection = NO;
    _selectionFrameColor = [NSColor selectionFrameColor];
    _useSelectionRing = YES;
    _useHover = YES;

    _isInitialCall = YES;
    _lastHoveredIndex = NSNotFound;
    _lastSelectedIndex = NSNotFound;
    _clickEvents = [NSMutableArray array];
    _clickTimer = nil;
    _selectionFrameView = nil;
    _selectionFrameInitialPoint = CGPointZero;
    _abortSelection = NO;

    [[self enclosingScrollView] setDrawsBackground:YES];

    NSClipView *clipView = [[self enclosingScrollView] contentView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateVisibleRect)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setItemSize:(NSSize)itemSize
{
    _itemSize = itemSize;
    [self refreshGridViewAnimated:YES];
}

- (void)setScrollElasticity:(BOOL)scrollElasticity
{
    _scrollElasticity = scrollElasticity;
    NSScrollView *scrollView = [self enclosingScrollView];
    if (_scrollElasticity) {
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

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    if (self.selectedItems.count > 1 && !allowsMultipleSelection) {
        NSArray *indexes = [self.selectedItems allKeys];
        [indexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CNGridViewItem *item = [self.selectedItems objectForKey:(NSNumber *)obj];
            item.isSelected = NO;
            [self.selectedItems removeObjectForKey:(NSNumber *)obj];
        }];
        [self updateVisibleRect];
    }
}




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)updateVisibleRect
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

    [[self.keyedVisibleItems allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CNGridViewItem *item = (CNGridViewItem *)obj;
        if (!NSLocationInRange(item.index, currentRange) && item.isReuseable) {
            [self.keyedVisibleItems removeObjectForKey:[NSNumber numberWithUnsignedInteger:item.index]];
            [item removeFromSuperview];
            [item prepareForReuse];

            NSMutableSet *reuseQueue = [self.reuseableItems objectForKey:item.reuseIdentifier];
            if (reuseQueue == nil)
                reuseQueue = [NSMutableSet set];
            [reuseQueue addObject:item];
            [self.reuseableItems setObject:reuseQueue forKey:item.reuseIdentifier];
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
            if (self.isInitialCall) {
                [item setAlphaValue:0.0];
                [item setFrame:[self rectForItemAtIndex:idx]];
            }
            [self.keyedVisibleItems setObject:item forKey:[NSNumber numberWithUnsignedInteger:item.index]];
            [self addSubview:item];
        }
    }];
}

- (NSIndexSet *)indexesForVisibleItems
{
    __block NSMutableIndexSet *indexesForVisibleItems = [[NSMutableIndexSet alloc] init];
    [self.keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [indexesForVisibleItems addIndex:[(CNGridViewItem *)obj index]];
    }];
    return indexesForVisibleItems;
}

- (void)arrangeGridViewItemsAnimated:(BOOL)animated
{
    /// on initial call (aka app startup) we will fade all items (after loading it) in
    if (self.isInitialCall && self.keyedVisibleItems.count > 0) {
        self.isInitialCall = NO;
        animated = YES;
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:(animated ? 0.23 : 0.0)];
        [self.keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[(CNGridViewItem *)obj animator] setAlphaValue:1.0];
        }];
        [NSAnimationContext endGrouping];
    }

    else if (_keyedVisibleItems.count > 0) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [self.keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
    if (clippedRect.origin.y > self.itemSize.height) {
        rangeStart = (ceilf(clippedRect.origin.y / self.itemSize.height) * columns) - columns;
    }
    NSUInteger rangeLength = MIN(self.numberOfItems, (columns * rows) + columns);
    rangeLength = ((rangeStart + rangeLength) > self.numberOfItems ? self.numberOfItems - rangeStart : rangeLength);

    NSRange rangeForVisibleRect = NSMakeRange(rangeStart, rangeLength);
    return rangeForVisibleRect;
}

- (NSRect)rectForItemAtIndex:(NSUInteger)index
{
    NSUInteger columns = [self columnsInGridView];
    NSRect itemRect = NSMakeRect((index % columns) * self.itemSize.width,
                                 ((index - (index % columns)) / columns) * self.itemSize.height,
                                 self.itemSize.width,
                                 self.itemSize.height);
    return itemRect;
}

- (NSUInteger)columnsInGridView
{
    NSRect visibleRect  = [self clippedRect];
    NSUInteger columns = floorf((float)NSWidth(visibleRect) / self.itemSize.width);
    columns = (columns < 1 ? 1 : columns);
    return columns;
}

- (NSUInteger)allOverRowsInGridView
{
    NSUInteger allOverRows = ceilf((float)self.numberOfItems / [self columnsInGridView]);
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

- (NSUInteger)indexForItemAtLocation:(NSPoint)location
{
    NSPoint point = [self convertPoint:location fromView:nil];
    NSUInteger indexForItemAtLocation;
    if (point.x > (self.itemSize.width * [self columnsInGridView])) {
        indexForItemAtLocation = NSNotFound;

    } else {
        NSUInteger currentColumn = floor(point.x / self.itemSize.width);
        NSUInteger currentRow = floor(point.y / self.itemSize.height);
        indexForItemAtLocation = currentRow * [self columnsInGridView] + currentColumn;
        indexForItemAtLocation = (indexForItemAtLocation > self.numberOfItems ? NSNotFound : indexForItemAtLocation);
    }
    return indexForItemAtLocation;
}

- (CNItemPoint)locationForItemAtIndex:(NSUInteger)itemIndex
{
    
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

- (void)updateTrackingAreas
{
    if (self.gridViewTrackingArea)
        [self removeTrackingArea:self.gridViewTrackingArea];

    self.gridViewTrackingArea = nil;
    self.gridViewTrackingArea = [[NSTrackingArea alloc] initWithRect:self.frame
                                                             options:NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                                               owner:self
                                                            userInfo:nil];
    [self addTrackingArea:_gridViewTrackingArea];
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
    NSMutableSet *reuseQueue = [self.reuseableItems objectForKey:identifier];
    if (reuseQueue != nil && reuseQueue.count > 0) {
        reusableItem = [reuseQueue anyObject];
        [reuseQueue removeObject:reusableItem];
        [self.reuseableItems setObject:reuseQueue forKey:identifier];
    }
    return reusableItem;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reloading GridView Data

- (void)reloadData
{
    self.numberOfItems = [self gridView:self numberOfItemsInSection:0];
    [self.keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(CNGridViewItem *)obj removeFromSuperview];
    }];
    [self.keyedVisibleItems removeAllObjects];
    [self.reuseableItems removeAllObjects];
    [self refreshGridViewAnimated:YES];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selection Handling

- (void)scrollToGridViewItem:(CNGridViewItem *)gridViewItem animated:(BOOL)animated
{

}

- (void)scrollToGridViewItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{

}

- (void)selectItemAtIndex:(NSUInteger)selectedItemIndex usingModifierFlags:(NSUInteger)modifierFlags
{
    CNGridViewItem *gridViewItem = nil;

    if (self.lastSelectedIndex != NSNotFound && self.lastSelectedIndex != selectedItemIndex) {
        /// inform the delegate
        [self gridView:self willDeselectItemAtIndex:self.lastSelectedIndex inSection:0];

        gridViewItem = [self.keyedVisibleItems objectForKey:[NSNumber numberWithInteger:self.lastSelectedIndex]];
        gridViewItem.isSelected = NO;
        [self.selectedItems removeObjectForKey:[NSNumber numberWithInteger:gridViewItem.index]];

        /// inform the delegate
        [self gridView:self didDeselectItemAtIndex:self.lastSelectedIndex inSection:0];
    }

    gridViewItem = [self.keyedVisibleItems objectForKey:[NSNumber numberWithInteger:selectedItemIndex]];
    if (gridViewItem) {
        /// inform the delegate
        [self gridView:self willSelectItemAtIndex:selectedItemIndex inSection:0];

        if (self.allowsMultipleSelection) {
            if (!gridViewItem.isSelected) {
                gridViewItem.isSelected = YES;
            } else {
                if (modifierFlags & NSCommandKeyMask) {
                    gridViewItem.isSelected = NO;
                }
            }

        } else {
            if (modifierFlags & NSCommandKeyMask) {
                gridViewItem.isSelected = (gridViewItem.isSelected ? NO : YES);
            } else {
                gridViewItem.isSelected = YES;
            }
        }

        self.lastSelectedIndex = (self.allowsMultipleSelection ? NSNotFound : selectedItemIndex);
        [self.selectedItems setObject:gridViewItem forKey:[NSNumber numberWithInteger:selectedItemIndex]];

        /// inform the delegate
        [self gridView:self didSelectItemAtIndex:selectedItemIndex inSection:0];
    }
}

- (void)handleClicks:(NSTimer *)theTimer
{
    switch ([self.clickEvents count]) {
        case CNSingleClick: {
            NSEvent *theEvent = [self.clickEvents lastObject];
            NSUInteger index = [self indexForItemAtLocation:theEvent.locationInWindow];
            [self handleSingleClickForItemAtIndex:index];
            break;
        }

        case CNDoubleClick: {
            NSUInteger indexClick1 = [self indexForItemAtLocation:[[self.clickEvents objectAtIndex:0] locationInWindow]];
            NSUInteger indexClick2 = [self indexForItemAtLocation:[[self.clickEvents objectAtIndex:1] locationInWindow]];
            if (indexClick1 == indexClick2) {
                [self handleDoubleClickForItemAtIndex:indexClick1];
            } else {
                [self handleSingleClickForItemAtIndex:indexClick1];
                [self handleSingleClickForItemAtIndex:indexClick2];
            }
            break;
        }

        case CNTrippleClick: {
            NSUInteger indexClick1 = [self indexForItemAtLocation:[[self.clickEvents objectAtIndex:0] locationInWindow]];
            NSUInteger indexClick2 = [self indexForItemAtLocation:[[self.clickEvents objectAtIndex:1] locationInWindow]];
            NSUInteger indexClick3 = [self indexForItemAtLocation:[[self.clickEvents objectAtIndex:2] locationInWindow]];
            if (indexClick1 == indexClick2 == indexClick3) {
                [self handleDoubleClickForItemAtIndex:indexClick1];
            }

            else if ((indexClick1 == indexClick2) && (indexClick1 != indexClick3)) {
                [self handleDoubleClickForItemAtIndex:indexClick1];
                [self handleSingleClickForItemAtIndex:indexClick3];
            }

            else if ((indexClick1 != indexClick2) && (indexClick2 == indexClick3)) {
                [self handleSingleClickForItemAtIndex:indexClick1];
                [self handleDoubleClickForItemAtIndex:indexClick3];
            }

            else if (indexClick1 != indexClick2 != indexClick3) {
                [self handleSingleClickForItemAtIndex:indexClick1];
                [self handleSingleClickForItemAtIndex:indexClick2];
                [self handleSingleClickForItemAtIndex:indexClick3];
            }
            break;
        }
    }
    [self.clickEvents removeAllObjects];
}

- (void)handleSingleClickForItemAtIndex:(NSUInteger)selectedItemIndex
{
    /// inform the delegate
    [self gridView:self didClickItemAtIndex:selectedItemIndex inSection:0];
    CNLog(@"handleSingleClick for item at index: %lu", selectedItemIndex);
}

- (void)handleDoubleClickForItemAtIndex:(NSUInteger)selectedItemIndex
{
    /// inform the delegate
    [self gridView:self didDoubleClickItemAtIndex:selectedItemIndex inSection:0];
    CNLog(@"handleDoubleClick for item at index: %lu", selectedItemIndex);
}

- (void)drawSelectionFrameForMousePointerAtLocation:(NSPoint)location
{
    if (!self.selectionFrameView) {
        self.selectionFrameInitialPoint = location;
        self.selectionFrameView = [[CNSelectionFrameView alloc] initWithSelectionFrameColor:self.selectionFrameColor];
        self.selectionFrameView.frame = NSMakeRect(location.x, location.y, 0, 0);
        if (![self containsSubView:self.selectionFrameView])
            [self addSubview:self.selectionFrameView];
    }

    else {
        NSRect newRect = NSMakeRect(ceil((location.x > self.selectionFrameInitialPoint.x ? self.selectionFrameInitialPoint.x: location.x)),
                                    ceil((location.y > self.selectionFrameInitialPoint.y ? self.selectionFrameInitialPoint.y: location.y)),
                                    (location.x > self.selectionFrameInitialPoint.x ? location.x - self.selectionFrameInitialPoint.x: self.selectionFrameInitialPoint.x - location.x),
                                    (location.y > self.selectionFrameInitialPoint.y ? location.y - self.selectionFrameInitialPoint.y: self.selectionFrameInitialPoint.y - location.y));
        self.selectionFrameView.frame = newRect;
        [self.selectionFrameView setNeedsDisplay:YES];
    }
}

- (void)selectItemsCoveredBySelectionFrame:(NSRect)selectionFrame
{
    NSUInteger topLeftItemIndex = [self indexForItemAtLocation:[self convertPoint:NSMakePoint(NSMinX(selectionFrame), NSMinY(selectionFrame)) toView:nil]];
    NSUInteger bottomRightItemIndex = [self indexForItemAtLocation:[self convertPoint:NSMakePoint(NSMaxX(selectionFrame), NSMaxY(selectionFrame)) toView:nil]];

    CNLog(@"topLeftItemIndex: %li", topLeftItemIndex);
    CNLog(@"bottomRightItemIndex: %li", bottomRightItemIndex);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSResponder Methods

- (void)mouseExited:(NSEvent *)theEvent
{
    self.lastHoveredIndex = NSNotFound;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (!self.useHover)
        return;

    NSUInteger hoverItemIndex = [self indexForItemAtLocation:theEvent.locationInWindow];
    if (hoverItemIndex != NSNotFound || hoverItemIndex != self.lastHoveredIndex) {
        CNGridViewItem *gridViewItem = nil;
        /// unhover the last hovered item
        if (self.lastHoveredIndex != NSNotFound) {
            /// inform the delegate
            [self gridView:self willUnhovertemAtIndex:self.lastHoveredIndex inSection:0];

            gridViewItem = [self.keyedVisibleItems objectForKey:[NSNumber numberWithInteger:self.lastHoveredIndex]];
            gridViewItem.isHovered = NO;
        }

        /// inform the delegate
        [self gridView:self willHovertemAtIndex:hoverItemIndex inSection:0];

        self.lastHoveredIndex = hoverItemIndex;
        gridViewItem = [self.keyedVisibleItems objectForKey:[NSNumber numberWithInteger:hoverItemIndex]];
        gridViewItem.isHovered = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (!self.allowsMultipleSelection)
        return;

    if (!self.abortSelection) {
        NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [self drawSelectionFrameForMousePointerAtLocation:location];
        [self selectItemsCoveredBySelectionFrame:self.selectionFrameView.frame];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    /// remove selection frame
    [[self.selectionFrameView animator] setAlphaValue:0];
    self.selectionFrameView = nil;

    self.abortSelection = NO;

    [self.clickEvents addObject:theEvent];
    self.clickTimer = nil;
    self.clickTimer = [NSTimer scheduledTimerWithTimeInterval:[NSEvent doubleClickInterval] target:self selector:@selector(handleClicks:) userInfo:nil repeats:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (!self.allowsSelection)
        return;

    NSPoint location = [theEvent locationInWindow];
    [self selectItemAtIndex:[self indexForItemAtLocation:location] usingModifierFlags:theEvent.modifierFlags];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint location = [theEvent locationInWindow];
    [self gridView:self rightMouseButtonClickedOnItemAtIndex:[self indexForItemAtLocation:location] inSection:0];
}

- (void)keyDown:(NSEvent *)theEvent
{
    CNLog(@"keyDown");
    switch ([theEvent keyCode]) {
        case 53: {  // escape
            self.abortSelection = YES;
            break;
        }
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView Delegate Calls

- (void)gridView:(CNGridView *)gridView willHovertemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willHovertemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView *)gridView willUnhovertemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willUnhovertemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView*)gridView willSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willSelectItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView*)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didSelectItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView*)gridView willDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willDeselectItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView*)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didDeselectItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didClickItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didDoubleClickItemAtIndex:index inSection:section];
    }
}

- (void)gridView:(CNGridView *)gridView rightMouseButtonClickedOnItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView rightMouseButtonClickedOnItemAtIndex:index inSection:section];
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView DataSource Calls

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





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNSelectionFrameView

@interface CNSelectionFrameView () {
    NSColor *selectionFrameColor;
}
@end

@implementation CNSelectionFrameView

- (id)init
{
    self = [super init];
    if (self) {
        selectionFrameColor = [NSColor selectionFrameColor];
    }
    return self;
}

- (id)initWithSelectionFrameColor:(NSColor *)aColor
{
    self = [self init];
    if (self) {
        selectionFrameColor = aColor;
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    NSRect dirtyRect = NSMakeRect(0.5, 0.5, floorf(NSWidth(self.bounds))-1, floorf(NSHeight(self.bounds))-1);
    NSBezierPath *selectionFramePath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:0 yRadius:0];

    [[selectionFrameColor colorWithAlphaComponent:0.35] setFill];
    [selectionFramePath fill];

    [[NSColor whiteColor] set];
    [selectionFramePath stroke];
}

- (void)setSelectionFrameColor:(NSColor *)aColor
{
    selectionFrameColor = aColor;
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped
{
    return YES;
}

@end