//
//  CNAppDelegate.h
//  CNGridView Example
//
//  Created by cocoa:naut on 12.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CNGridView.h"

@interface CNAppDelegate : NSObject <NSApplicationDelegate, CNGridViewDataSource, CNGridViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet CNGridView *gridView;

@property (strong) NSMutableArray *items;

@end
