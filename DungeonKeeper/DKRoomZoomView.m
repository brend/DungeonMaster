//
//  DKRoomZoomView.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 11.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKRoomZoomView.h"

@implementation DKRoomZoomView

#pragma mark -
#pragma mark Initialization and Deallocation

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
	[self.background drawInRect: self.frame fromRect: self.backgroundClipRect operation: NSCompositeSourceOver fraction: 1];
}

#pragma mark -
#pragma mark Room Zoom View Properties

@synthesize background, backgroundClipRect;

@end
