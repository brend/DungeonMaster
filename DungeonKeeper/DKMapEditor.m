//
//  DKMapEditor.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKMapEditor.h"

@implementation DKMapEditor

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] setFill];
	NSRectFill(dirtyRect);
}

@end
