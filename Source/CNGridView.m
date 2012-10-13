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
    NSMutableDictionary *keyedVisibleItems;
    NSMutableDictionary *_reuseableItems;
    NSMutableArray *_selectedItems;
    NSUInteger _numberOfItems;
}

- (void)setupDefaults;
- (void)refreshLayout;
- (void)queueInvisibleItems;
- (void)updateVisibleItems;
- (NSIndexSet *)indexesForVisibleItems;
- (void)reArrangeLayout;
- (void)queueItemForReuse:(CNGridViewItem *)reuseableItem;
- (NSRange)rangeForVisibleRect;
- (NSRect)rectForItemAtIndex:(NSUInteger)index;
- (NSUInteger)columnsInGridView;
- (NSUInteger)allOverRowsInGridView;
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
    keyedVisibleItems = [[NSMutableDictionary alloc] init];
    _reuseableItems   = [[NSMutableDictionary alloc] init];
    _selectedItems    = [[NSMutableArray alloc] init];

    /// public properties
    _gridViewTitle  = nil;

    _backgroundColor = [NSColor gridViewBackgroundColor];
    _elasticity      = YES;
    _itemSize        = [CNGridViewItem defaultItemSize];

    _allowsSelection         = YES;
    _allowsMultipleSelection = NO;


//    NSClipView *clipView = [[self enclosingScrollView] contentView];
//    [clipView setPostsBoundsChangedNotifications:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLayout) name:NSViewBoundsDidChangeNotification object:clipView];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setItemSize:(NSSize)itemSize
{
    CNLog(@"setItemSize: %f", itemSize.width);
    _itemSize = itemSize;
    [self refreshLayout];
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

- (void)drawRect:(NSRect)dirtyRect
{
//    [self.backgroundColor setFill];
//    NSRectFill(dirtyRect);
    [self refreshLayout];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)refreshLayout
{
    NSRect currentRect = [self frame];
    currentRect.size.width = currentRect.size.width;
    currentRect.size.height = [self allOverRowsInGridView] * self.itemSize.height;
    [super setFrame:currentRect];

    [self queueInvisibleItems];
    [self updateVisibleItems];
    [self reArrangeLayout];
    [self setNeedsDisplay:YES];
}

- (void)queueInvisibleItems
{
    NSRange rangeForVisibleRect = [self rangeForVisibleRect];

    /// remove all now unvisible items from the visible items list, put it to the reuse queue
    /// and remove it from its super view
    NSArray *visibleItems = [keyedVisibleItems allValues];
    [visibleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CNGridViewItem *item = (CNGridViewItem *)obj;
        if (!NSLocationInRange(item.index, rangeForVisibleRect)) {
            [self queueItemForReuse:item];
            [item removeFromSuperview];
            [keyedVisibleItems removeObjectForKey:[NSNumber numberWithInteger:item.index]];
        }
    }];
}

- (void)updateVisibleItems
{
    NSRange rangeForVisibleRect = [self rangeForVisibleRect];
    NSMutableIndexSet *visibleRangeIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:rangeForVisibleRect];

    /// update all visible items
    [visibleRangeIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        CNGridViewItem *item = [self gridView:self itemAtIndex:idx inSection:0];
        if (item != nil && ![keyedVisibleItems containsKey:[NSNumber numberWithInteger:idx]]) {
            item.index = idx;
            [keyedVisibleItems setObject:item forKey:[NSNumber numberWithInteger:item.index]];
            [self addSubview:item];
        }
    }];
}

- (NSIndexSet *)indexesForVisibleItems
{
    __block NSMutableIndexSet *indexesForVisibleItems = [[NSMutableIndexSet alloc] init];
    [keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [indexesForVisibleItems addIndex:[(CNGridViewItem *)obj index]];
    }];
    return indexesForVisibleItems;
}

- (void)reArrangeLayout
{
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:0.2];
//    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

    [keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSRect newRect = [self rectForItemAtIndex:[(CNGridViewItem *)obj index]];
//        [[(CNGridViewItem *)obj animator] setFrame:newRect];
        [(CNGridViewItem *)obj setFrame:newRect];
        [(CNGridViewItem *)obj setNeedsDisplay:YES];
    }];

//    [NSAnimationContext endGrouping];
}

- (void)queueItemForReuse:(CNGridViewItem *)reuseableItem
{
    NSMutableArray *reuseQueue = [_reuseableItems objectForKey:reuseableItem.reuseIdentifier];
    if (reuseQueue == nil)
        reuseQueue = [NSMutableArray array];
    [reuseableItem prepareForReuse];
    [reuseQueue addObject:reuseableItem];
    [_reuseableItems setObject:reuseQueue forKey:reuseableItem.reuseIdentifier];
}

- (NSRange)rangeForVisibleRect
{
    NSRect visibleRect  = [[[self enclosingScrollView] contentView] bounds];
    NSUInteger columns  = [self columnsInGridView];
    NSUInteger rows     = [self visibleRowsInGridView];

    NSUInteger rangeStart, rangeLength;

    if (visibleRect.origin.y >= _itemSize.height) {
        rangeStart = (floorf(fmod((visibleRect.origin.y / _itemSize.height), _itemSize.height))) * columns + 1;
        rangeLength = (columns * rows) + rangeStart;
    } else {
        rangeStart = 0;
        rangeLength = (columns * rows);
    }
    rangeLength = MIN(_numberOfItems, rangeLength);
    NSRange rangeForVisibleRect = NSMakeRange(rangeStart, rangeLength-rangeStart);
    CNLogForRange(rangeForVisibleRect);
    return rangeForVisibleRect;
}

- (NSRect)rectForItemAtIndex:(NSUInteger)index
{
    NSUInteger columns = [self columnsInGridView];
    NSRect itemRect = NSMakeRect((index % columns) * _itemSize.width,
                                 ceilf(index / columns) * _itemSize.height,
                                 _itemSize.width,
                                 _itemSize.height);
    return itemRect;
}

- (NSUInteger)columnsInGridView
{
    NSRect gridViewRect = self.frame;
    NSUInteger columns = floorf((float)NSWidth(gridViewRect) / _itemSize.width);
    columns = (columns < 1 ? 1 : columns);
    return columns;
}

- (NSUInteger)allOverRowsInGridView
{
    NSUInteger allOverRows = ceilf((float)_numberOfItems / [self columnsInGridView]);
//    CNLog(@"allOverRowsInGridView: %lu", allOverRows);
    return allOverRows;
}

- (NSUInteger)visibleRowsInGridView
{
    NSRect visibleRect  = [[[self enclosingScrollView] contentView] frame];
    NSUInteger visibleRows = floorf((float)NSHeight(visibleRect) / self.itemSize.height);
//    CNLog(@"visibleRowsInGridView: %lu", visibleRows);
    CNLogForRect(visibleRect);
    return visibleRows;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSView Methods

- (BOOL)isFlipped
{
    return YES;
}

//- (void)viewWillStartLiveResize
//{
//    [self refreshLayout];
//}

//- (void)viewDidEndLiveResize
//{
//    [self refreshLayout];
//}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring the GridView

- (NSUInteger)numberOfVisibleItems
{
    return keyedVisibleItems.count;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creating GridView Items

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    CNGridViewItem *reusableItem = nil;
    NSMutableArray *reuseQueue = [_reuseableItems objectForKey:identifier];
    if (reuseQueue != nil && reuseQueue.count > 0) {
        reusableItem = [reuseQueue lastObject];
        [reuseQueue removeLastObject];
        [_reuseableItems setObject:reuseQueue forKey:identifier];
    }
    return reusableItem;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reloading GridView Data

- (void)reloadData
{
    _numberOfItems = [self gridView:self numberOfItemsInSection:0];
    [keyedVisibleItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(CNGridViewItem *)obj removeFromSuperview];
    }];
    [keyedVisibleItems removeAllObjects];
    [_reuseableItems removeAllObjects];
    [self refreshLayout];
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
#pragma mark - CNGridView Delegate Callbacks

- (void)gridView:(CNGridView*)gridView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView willDisplayItemAtIndexPath:indexPath];
    }
}

- (void)gridView:(CNGridView*)gridView didDisplayItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate gridView:gridView didDisplayItemAtIndexPath:indexPath];
    }
}

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
