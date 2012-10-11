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

#import "CNGridViewDelegate.h"
#import "CNGridViewDataSource.h"
#import "CNGridViewItem.h"


/**
 `CNGridView` is an easy to use (wanna be) `NSCollectionView` replacement. It was completely written from the ground up.

 */



__unused static NSColor *kDefaultBackgroundColor;



@interface CNGridView : NSView

#pragma mark - Initializing a CNGridView Object
/** @name Initializing a CNGridView Object */

/**
 Creates and returns an initialized `CNGridView` object with the given frame and grid view content array.
 
 This is the designated initializer.
 */
- (id)initWithFrame:(NSRect)frameRect gridViewContent:(NSMutableArray *)gridViewContent title:(NSString *)gridViewTitle;


#pragma mark - Managing the Delegate and the Data Source
/** @name Managing the Delegate and the Data Source */

/**
 ...
 */
@property (nonatomic, strong) IBOutlet id<CNGridViewDelegate> delegate;

/**
 ...
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
@property (nonatomic, strong) NSView *headerView;

/**
 ...
 */
@property (nonatomic, strong) NSView *footerView;

/**
 ...
 */
@property (nonatomic, strong) NSView *backgroundView;

/**
 ...
 */
- (NSUInteger)numberOfVisibleItems;



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
