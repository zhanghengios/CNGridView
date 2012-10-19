//
//  NSView+Tools.h
//  CNGridView Example
//
//  Created by cocoa:naut on 18.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Tools)
- (BOOL)isSubviewOfView:(NSView *)theView;
- (BOOL)containsSubView:(NSView *)subview;
@end
