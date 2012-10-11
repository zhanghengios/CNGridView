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

#pragma mark Displaying
/** @name Displaying */


/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDisplayItemAtIndexPath:(NSIndexPath *)indexPath;


#pragma mark Managing selection
/** @name Managing selection */


/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
