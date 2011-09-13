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
	
	// TODO: Draw connections
}

#pragma mark -
#pragma mark Room Zoom View Properties

@synthesize background, backgroundClipRect;

#pragma mark -
#pragma mark Handling User Input

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (void) mouseDown: (NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
	DMExit clickedExit = [self connectionPointFromPoint: p];
	
	if (connectionStart == DMExitNone) {
		connectionStart = clickedExit;
		connectionEnd = DMExitNone;
	} else {
		connectionEnd = clickedExit;
		
		if (connectionStart != DMExitNone && connectionEnd != DMExitNone && connectionStart != connectionEnd) {
			[self makeConnection];
		}
		
		connectionStart = connectionEnd = DMExitNone;
	}
}

//- (void)mouseUp:(NSEvent *) e
//{
//	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
//
//	connectionEnd = [self connectionPointFromPoint: p];
//	
//	if (connectionStart != DMExitNone && connectionEnd != DMExitNone && connectionStart != connectionEnd) {
//		[self makeConnection];
//	}
//}

- (DMExit) connectionPointFromPoint:(NSPoint)p
{
	NSSize size = self.frame.size;
	NSPoint
	top = NSMakePoint(size.width * 0.5f, size.height),
	right = NSMakePoint(size.width, size.height * 0.5f),
	bottom = NSMakePoint(size.width * 0.5f, 0),
	left = NSMakePoint(0, size.height * 0.5f);
	float minDistance = 32;
	
	if (DMPointDistance(p, top) < minDistance) {
		return DMExitNorth;
	} else if (DMPointDistance(p, right) < minDistance) {
		return DMExitEast;
	} else if (DMPointDistance(p, bottom) < minDistance) {
		return DMExitSouth;
	} else if (DMPointDistance(p, left) < minDistance) {
		return DMExitWest;
	} else {
		return DMExitNone;
	}
}

- (void) makeConnection
{
	[delegate roomZoom: self makeConnectionFromExit: connectionStart toExit: connectionEnd];
}

@end
