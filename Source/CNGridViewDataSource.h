//
//  CNGridViewDataSource.h
//  SieveMail
//
//  Created by cocoa:naut on 07.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CNGridView;

@protocol CNGridViewDataSource <NSObject>
@required

/**
 ...
 */
- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section;

/**
 ...
 */
- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section;


@optional
/**
 ...
 */
- (NSUInteger)numberOfSectionsInGridView:(CNGridView *)gridView;

/**
 ...
 */
- (NSString *)gridView:(CNGridView *)gridView titleForHeaderInSection:(NSInteger)section;

/**
 ...
 */
- (NSArray *)sectionIndexTitlesForGridView:(CNGridView *)gridView;

@end
