//
//  CNAppDelegate.m
//  CNGridView Example
//
//  Created by cocoa:naut on 12.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNGridViewItem.h"
#import "CNGridViewItemLayout.h"


static NSString *kContentTitleKey, *kContentImageKey, *kItemSizeSliderPositionKey;

@interface CNAppDelegate ()
@property (strong) CNGridViewItemLayout *hoverLayout;
@property (strong) CNGridViewItemLayout *selectionLayout;
@end

@implementation CNAppDelegate

+ (void)initialize
{
    kContentTitleKey = @"itemTitle";
    kContentImageKey = @"itemImage";
    kItemSizeSliderPositionKey = @"ItemSizeSliderPosition";
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _hoverLayout = [CNGridViewItemLayout defaultLayout];
        _selectionLayout = [CNGridViewItemLayout defaultLayout];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hoverLayout.backgroundColor = [[NSColor grayColor] colorWithAlphaComponent:0.42];
    self.selectionLayout.backgroundColor = [NSColor colorWithCalibratedRed:0.542 green:0.699 blue:0.807 alpha:0.420];

    /// insert some content
    for (int i=0; i<500; i++) {
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameComputer], kContentImageKey,
                               NSImageNameComputer, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameNetwork], kContentImageKey,
                               NSImageNameNetwork, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameDotMac], kContentImageKey,
                               NSImageNameDotMac, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameFolderSmart], kContentImageKey,
                               NSImageNameFolderSmart, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameBonjour], kContentImageKey,
                               NSImageNameBonjour, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:@"AppleLogo"], kContentImageKey,
                               @"AppleLogo", kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameFolderBurnable], kContentImageKey,
                               NSImageNameFolderBurnable, kContentTitleKey,
                               nil]];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:kItemSizeSliderPositionKey]) {
        self.itemSizeSlider.integerValue = [defaults integerForKey:kItemSizeSliderPositionKey];
    }
    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
    self.gridView.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"BackgroundDust"]];
    self.gridView.scrollElasticity = YES;
    [self.gridView reloadData];
}

- (IBAction)itemSizeSliderAction:(id)sender
{
    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
    [[NSUserDefaults standardUserDefaults] setInteger:self.itemSizeSlider.integerValue forKey:kItemSizeSliderPositionKey];
}

- (IBAction)allowMultipleSelectionCheckboxAction:(id)sender
{
    self.gridView.allowsMultipleSelection = (self.allowMultipleSelectionCheckbox.state == NSOnState ? YES : NO);
}

- (IBAction)deleteButtonAction:(id)sender
{
    
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
        item = [[CNGridViewItem alloc] initWithLayout:[CNGridViewItemLayout defaultLayout] reuseIdentifier:reuseIdentifier];
    }
    item.hoverLayout = self.hoverLayout;
    item.selectionLayout = self.selectionLayout;

    NSDictionary *contentDict = [self.items objectAtIndex:index];
    item.itemTitle = [NSString stringWithFormat:@"Item: %lu", index];
    item.itemImage = [contentDict objectForKey:kContentImageKey];

    return item;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView Delegate

- (void)gridView:(CNGridView *)gridView willHovertemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
{
}

- (void)gridView:(CNGridView *)gridView rightMouseButtonClickedOnItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    CNLog(@"rightMouseButtonClickedOnItemAtIndex: %li", index);
}

@end
