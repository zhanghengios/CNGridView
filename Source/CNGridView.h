//
//  CNGridView.h
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

#import "NSDictionary+Tools.h"
#import "CNGridViewDelegate.h"
#import "CNGridViewDataSource.h"
#import "CNGridViewItem.h"


/**
 `CNGridView` is an easy to use (wanna be) `NSCollectionView` replacement. It was completely written from the ground up.
 `CNGridView` is a (wanna be) replacement for NSCollectionView. It has full delegate and dataSource support with method calls like known from NSTableView/UITableView.
 
 The use of `CNGridView` is just simple as possible.
 */


@interface CNGridView : NSView

#pragma mark - Initializing a CNGridView Object
/** @name Initializing a CNGridView Object */


#pragma mark - Managing the Delegate and the Data Source
/** @name Managing the Delegate and the Data Source */

/**
 Property for the receiver's delegate
 */
@property (nonatomic, strong) IBOutlet id<CNGridViewDelegate> delegate;

/**
 Property for the receiver's data source
 */
@property (nonatomic, strong) IBOutlet id<CNGridViewDataSource> dataSource;



#pragma mark - Configuring the GridView
/** @name Configuring the GridView */

/**
 ...
 */
@property (nonatomic, strong) NSString *gridViewTitle;

/**
 ...
 */
@property (nonatomic, strong) NSColor *backgroundColor;

/**
 ...
 */
@property (nonatomic, assign) BOOL elasticity;

/**
 ...
 */
@property (nonatomic, assign) NSSize itemSize;

/**
 ...
 */
- (NSUInteger)numberOfVisibleItems;



#pragma mark - Creating GridView Items
/** @name Creating GridView Items */

/**
 ...
 */
- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier;



#pragma mark - Managing Selections
/** @name Managing Selections */

/**
 ...
 */
@property (nonatomic, assign) BOOL allowsSelection;

/**
 ...
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;



#pragma mark - Reloading GridView Data
/** @name  Reloading GridView Data */

/**
 ...
 */
- (void)reloadData;



#pragma mark - Scrolling to GridView Items
/** @name  Scrolling to GridView Items */

/**
 ...
 */

- (void)scrollToGridViewItem:(CNGridViewItem *)gridViewItem animated:(BOOL)animated;

/**
 ...
 */
- (void)scrollToGridViewItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end
