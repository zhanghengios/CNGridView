//
//  CNAppDelegate.m
//  CNGridView Example
//
//  Created by cocoa:naut on 12.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNGridViewItem.h"


static NSString *kContentTitleKey, *kContentImageKey;

@implementation CNAppDelegate

+ (void)initialize
{
    kContentTitleKey = @"itemTitle";
    kContentImageKey = @"itemImage";
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /// insert some content
    for (int i=0; i<99; i++) {
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameComputer], kContentImageKey,
                               NSImageNameComputer, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameBonjour], kContentImageKey,
                               NSImageNameBonjour, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameFolderBurnable], kContentImageKey,
                               NSImageNameFolderBurnable, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameNetwork], kContentImageKey,
                               NSImageNameNetwork, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameDotMac], kContentImageKey,
                               NSImageNameDotMac, kContentTitleKey,
                               nil]];
    }

    self.gridView.itemSize = NSMakeSize(96, 96);
    self.gridView.backgroundColor = [NSColor controlColor];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView DataSource

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    static NSString *reuseIdentifier = @"CNGridViewItem";
    CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:reuseIdentifier];

    if (item == nil) {
        item = [[CNGridViewItem alloc] init];
    }

    NSDictionary *contentDict = [self.items objectAtIndex:index];
    item.itemTitle = [contentDict objectForKey:kContentTitleKey];
    item.itemImage = [contentDict objectForKey:kContentImageKey];

    return item;
}

@end
