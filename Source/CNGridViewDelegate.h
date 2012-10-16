//
//  CNGridViewDelegate.h
//  SieveMail
//
//  Created by cocoa:naut on 07.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CNGridView;
@class CNGridViewItem;


@protocol CNGridViewDelegate <NSObject>
@optional

#pragma mark Managing selection
/** @name Managing selection */

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willHovertemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willUnhovertemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView rightMouseButtonClickedOnItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

@end
