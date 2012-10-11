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

#import "CNGridView.h"


static NSSize kDefaultGridViewItemSize;

@interface CNGridView ()
@property (nonatomic, strong) NSMutableArray *visibleItems;

- (void)initPropertiesAndBehavior;
- (void)drawItemsInRect:(NSRect)visibleRect;
@end


@implementation CNGridView

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

+ (void)initialize
{
    kDefaultBackgroundColor = [NSColor controlColor];
    kDefaultGridViewItemSize = NSMakeSize(64.0, 64.0);
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initPropertiesAndBehavior];
        _delegate = nil;
        _dataSource = nil;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPropertiesAndBehavior];
        _delegate = nil;
        _dataSource = nil;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPropertiesAndBehavior];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect gridViewContent:(NSMutableArray *)gridViewContent title:(NSString *)gridViewTitle
{
    self = [self initWithFrame:frameRect];
    if (self) {
        [self initPropertiesAndBehavior];
        _delegate = nil;
        _dataSource = nil;
        _gridViewContent = gridViewContent;
        _gridViewTitle = gridViewTitle;
    }
    return self;
}

- (void)initPropertiesAndBehavior
{
    /// private propteries
    _visibleItems = [[NSMutableArray alloc] init];

    /// public properties
    _maxNumberOfItemsAllowedInGridView = NSUIntegerMax;
    _gridViewContent = [[NSMutableArray alloc] init];
    _gridViewTitle = nil;

    _allowsSelection = YES;
    _allowsMultipleSelection = NO;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ViewDrawing

- (void)drawRect:(NSRect)dirtyRect
{

    [self drawItemsInRect:dirtyRect];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)drawItemsInRect:(NSRect)visibleRect
{

}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring the GridView

- (NSUInteger)numberOfVisibleItems
{
    return self.visibleItems.count;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing Selections



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Inserting, Deleting, and Moving GridView Items

- (void)addItem:(CNGridViewItem *)newItem
{
    
}

- (void)addItems:(NSArray *)newItems
{

}

- (void)insertItem:(CNGridViewItem *)itemToInsert atIndexPath:(NSIndexPath *)indexPath
{

}

- (void)insertItems:(NSArray *)newItems atIndexPath:(NSIndexPath *)indexPath
{

}

- (void)removeItem:(CNGridViewItem *)itemToRemove
{

}

- (void)removeItems:(NSArray *)itemsToRemove
{

}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)removeItemsInRange:(NSRange *)range
{

}

- (void)moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{

}

- (void)moveItem:(CNGridViewItem *)gridViewItem toIndexPath:(NSIndexPath *)toIndexPath
{

}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reloading GridView Data

- (void)reloadData
{
    
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
