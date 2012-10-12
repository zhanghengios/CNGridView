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

#import "NSColor+CNGridViewPalette.h"
#import "CNGridView.h"
#import "CNGridViewItem.h"



@interface CNGridView () {
    NSMutableArray *_visibleItems;
    NSMutableArray *_reuseableItems;
    NSMutableArray *_selectedItems;
}

- (void)setupDefaults;
- (void)refreshLayout;
- (void)updateVisibleItemsForRect:(CGRect)visibleRect;
- (void)drawVisibleItems;
- (void)removeUnvisibleItems;
- (NSRange)rangeForVisibleRect:(CGRect)visibleRect;
- (NSRect)rectForItemAtIndex:(NSUInteger)index;
- (NSUInteger)columnsInGridViewForRect:(NSRect)gridViewRect;
- (NSUInteger)rowsInGridViewForRect:(NSRect)gridViewRect;
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
    _visibleItems   = [[NSMutableArray alloc] init];
    _reuseableItems = [[NSMutableArray alloc] init];
    _selectedItems  = [[NSMutableArray alloc] init];

    /// public properties
    _gridViewTitle  = nil;

    _backgroundColor    = [NSColor gridViewBackgroundColor];
    _elasticity         = YES;
    _itemSize           = [CNGridViewItem defaultItemSize];

    _allowsSelection            = YES;
    _allowsMultipleSelection    = NO;

//    [self setPostsBoundsChangedNotifications:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLayout) name:NSViewBoundsDidChangeNotification object:nil];


    CNLog(@"Result is: %f", floor((0/163) % 163));
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    CNLog(@"setBackgroundColor");
    _backgroundColor = backgroundColor;
//    [self refreshLayout];
}

- (void)setItemSize:(NSSize)itemSize
{
    CNLog(@"setItemSize");
    _itemSize = itemSize;
    [self refreshLayout];
}

//- (void)setNeedsLayout:(BOOL)flag
//{
//    CNLog(@"setNeedsLayout");
//    [super setNeedsLayout:flag];
//    [self refreshLayout];
//}

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



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)refreshLayout
{
    CNLog(@"refreshLayout");
    CGRect visibleRect = [self visibleRect];

    [self updateVisibleItemsForRect:visibleRect];
    [self drawVisibleItems];
//    NSUInteger numberOfItems = [self gridView:self numberOfItemsInSection:0];
//    for (NSUInteger idx = 0; idx < numberOfItems; idx++) {
//        NSRect itemRect = [self rectForItemAtVisibleIndex:idx];
//        CNGridViewItem *currentItem = [self gridView:self itemAtIndex:idx inSection:0];
//        currentItem.frame = itemRect;
//        [self addSubview:currentItem];
//        [currentItem setNeedsDisplay:YES];
//    }
}

- (void)updateVisibleItemsForRect:(CGRect)visibleRect
{
    NSRange rangeForVisibleRect = [self rangeForVisibleRect:visibleRect];
    for (NSUInteger idx = rangeForVisibleRect.location; idx < rangeForVisibleRect.length; idx++) {
        CNGridViewItem *item = [self gridView:self itemAtIndex:idx inSection:0];
        item.index = idx;
        [_visibleItems addObject:item];
        [_reuseableItems addObject:item];
    }
}

- (void)drawVisibleItems
{
    CNLog(@"drawVisibleItems");
    [_visibleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CNGridViewItem *currentItem = (CNGridViewItem *)obj;
        currentItem.frame = [self rectForItemAtIndex:idx];
        [self addSubview:currentItem];
    }];
}

- (void)removeUnvisibleItems
{
}

- (NSRange)rangeForVisibleRect:(CGRect)visibleRect
{
    NSUInteger columns = [self columnsInGridViewForRect:visibleRect];
    NSUInteger rows = [self rowsInGridViewForRect:visibleRect];

    NSUInteger rangeStart, rangeLength;

    if (visibleRect.origin.y > _itemSize.height) {
        rangeStart = (floor(fmod((visibleRect.origin.y / _itemSize.height), _itemSize.height)) -1) * columns + 1;
        rangeLength = (rangeStart * rows) - rangeStart;
    } else {
        rangeStart = 0;
        rangeLength = (columns * rows);
    }
    return NSMakeRange(rangeStart, rangeLength);
}

- (NSRect)rectForItemAtIndex:(NSUInteger)index
{
    NSRect visibleRect = [self visibleRect];
    NSUInteger columns = [self columnsInGridViewForRect:visibleRect];
    NSUInteger rowForIndex = floor(fmod((visibleRect.origin.y / _itemSize.height), _itemSize.height));

    NSRect itemRect = NSMakeRect((index % columns) * _itemSize.width,
                                 ceil(index / columns) * _itemSize.height,
                                 _itemSize.width,
                                 _itemSize.height);
    CNLogForRect(itemRect);
    return itemRect;
}

- (NSUInteger)columnsInGridViewForRect:(NSRect)gridViewRect
{
    return ceil(NSWidth(gridViewRect) / _itemSize.width);
}

- (NSUInteger)rowsInGridViewForRect:(NSRect)gridViewRect
{
    return ceil(NSHeight(gridViewRect) / _itemSize.height);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSView Methods

- (BOOL)isFlipped
{
    return YES;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [_backgroundColor setFill];
//    NSRectFill(dirtyRect);
//}

- (void)viewDidEndLiveResize
{
    CNLog(@"viewDidEndLiveResize");
    [self refreshLayout];
    [self drawVisibleItems];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring the GridView

- (NSUInteger)numberOfVisibleItems
{
    return _visibleItems.count;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creating GridView Items

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    CNGridViewItem *item = [[CNGridViewItem alloc] init];
    return item;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reloading GridView Data

- (void)reloadData
{
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
