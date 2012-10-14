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


static NSString *kContentTitleKey, *kContentImageKey;

@interface CNAppDelegate ()
@property (strong) CNGridViewItemLayout *hoverLayout;
@end

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
        _items = [[NSMutableArray alloc] init];
        _hoverLayout = [CNGridViewItemLayout defaultLayout];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.itemSizeSlider.title = @"GridView Item Size";
    self.hoverLayout.backgroundColor = [[NSColor grayColor] colorWithAlphaComponent:0.42];
    
    NSDate *methodStart = [NSDate date];
    /// insert some content
    for (int i=0; i<50000; i++) {
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

    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
    self.gridView.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"BackgroundDust"]];
    self.gridView.elasticity = YES;
    [self.gridView reloadData];

    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    CNLog(@"executionTime: %f", executionTime);
}

- (IBAction)itemSizeSliderAction:(id)sender
{
    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
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
    item.hoverLayout = self.hoverLayout;

    if (item == nil) {
        item = [[CNGridViewItem alloc] initWithLayout:[CNGridViewItemLayout defaultLayout] reuseIdentifier:reuseIdentifier];
    }

    NSDictionary *contentDict = [self.items objectAtIndex:index];
    item.itemTitle = [NSString stringWithFormat:@"Index: %lu", index];
    item.itemImage = [contentDict objectForKey:kContentImageKey];

    return item;
}

@end
