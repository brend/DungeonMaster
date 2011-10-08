//
//  DKRoomZoomView.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 11.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKRoomZoomView.h"


/*
 * Room Zoom View Private Interface
 */
@interface DKRoomZoomView ()
- (NSPoint) connectionStartCoordinates;
- (void) drawConnectionsInRect: (NSRect) rect;
- (void) drawConnectionFrom: (NSPoint) p over: (NSPoint) middle to: (NSPoint) q;
- (void) drawConnectionPointsInRect: (NSRect) rect;
@end

/*
 * Room Zoom View Implementation
 */
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
	
	// Draw connection indicators
	// [self drawConnectionPointsInRect: self.frame];
	
	// Draw existing connections
	[self drawConnectionsInRect: self.frame];
	
	// Draw connection currently drawn by user
	if (connectionStart != DMExitNone) {
		NSPoint startPoint = [self connectionStartCoordinates];
		NSBezierPath *path = [NSBezierPath bezierPath];
		
		[[NSColor blueColor] setStroke];
		
		float dash[] = { 8, 10 };
		[path setLineDash: dash count: 2 phase: 0];
		
		[path moveToPoint: startPoint];
		[path lineToPoint: currentMousePosition];
		[path setLineWidth: 5];
		[path stroke];
	}
}

// - (void) drawConnections: (DMConnections) connections inRect: (NSRect) rect
- (void) drawConnectionsInRect: (NSRect) rect
{
	NSImage 
		*cnb = [NSImage imageNamed: @"ConnectionsNorthBackground"],
		*csb = [NSImage imageNamed: @"ConnectionsSouthBackground"],
		*ceb = [NSImage imageNamed: @"ConnectionsEastBackground"],
		*cwb = [NSImage imageNamed: @"ConnectionsWestBackground"];
	NSSize imageSize = cnb.size, frameSize = self.frame.size;
	NSPoint
		north = NSMakePoint((frameSize.width - imageSize.width) * 0.5f, frameSize.height - imageSize.height),
		south = NSMakePoint((frameSize.width - imageSize.width) * 0.5f, 0),
		east = NSMakePoint(frameSize.width - imageSize.width, (frameSize.height - imageSize.height) * 0.5f),
		west = NSMakePoint(0, (frameSize.height - imageSize.height) * 0.5f);
	
	// North
	[cnb drawAtPoint: north fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	
	for (NSInteger i = 0; i < 4; ++i) {
		DMExit e = 1 << i;
		
		if (connections.north & e) {
			NSImage *overlay = [NSImage imageNamed: [NSString stringWithFormat: @"ConnectionsNorth%d", i]];
			
			[overlay drawAtPoint: north fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
		}
	}
	
	if (connectionStart == DMExitNorth) {
		NSImage *highlight = [NSImage imageNamed: @"ConnectionsNorthHighlight"];
		
		[highlight drawAtPoint: north fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	}
	
	// South
	[csb drawAtPoint: south fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	
	for (NSInteger i = 0; i < 4; ++i) {
		DMExit e = 1 << i;
		
		if (connections.south & e) {
			NSImage *overlay = [NSImage imageNamed: [NSString stringWithFormat: @"ConnectionsSouth%d", i]];
			
			[overlay drawAtPoint: south fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
		}
	}
	
	if (connectionStart == DMExitSouth) {
		NSImage *highlight = [NSImage imageNamed: @"ConnectionsSouthHighlight"];
		
		[highlight drawAtPoint: south fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	}
	
	// East
	[ceb drawAtPoint: east fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	
	for (NSInteger i = 0; i < 4; ++i) {
		DMExit e = 1 << i;
		
		if (connections.east & e) {
			NSImage *overlay = [NSImage imageNamed: [NSString stringWithFormat: @"ConnectionsEast%d", i]];
			
			[overlay drawAtPoint: east fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
		}
	}
	
	if (connectionStart == DMExitEast) {
		NSImage *highlight = [NSImage imageNamed: @"ConnectionsEastHighlight"];
		
		[highlight drawAtPoint: east fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	}
	
	// West
	[cwb drawAtPoint: west fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	
	for (NSInteger i = 0; i < 4; ++i) {
		DMExit e = 1 << i;
		
		if (connections.west & e) {
			NSImage *overlay = [NSImage imageNamed: [NSString stringWithFormat: @"ConnectionsWest%d", i]];
			
			[overlay drawAtPoint: west fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
		}
	}
	
	if (connectionStart == DMExitWest) {
		NSImage *highlight = [NSImage imageNamed: @"ConnectionsWestHighlight"];
		
		[highlight drawAtPoint: west fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1];
	}
}

- (void) drawConnectionFrom: (NSPoint) p over: (NSPoint) middle to: (NSPoint) q
{
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[path setLineJoinStyle: NSRoundLineJoinStyle];
	[path setLineCapStyle: NSRoundLineCapStyle];
	[path setLineWidth: 5];
	
	[path moveToPoint: p];
	[path lineToPoint: middle];
	[path lineToPoint: q];
	
	[[NSColor blueColor] setStroke];
	[path stroke];
}

- (void) drawConnectionPointsInRect: (NSRect) rect
{
	float ovalWidth = 16, ovalHeight = 16;
	NSBezierPath *path;
	
	[[NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: 0.5] setFill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.origin.x, rect.origin.y + 0.5f * (rect.size.height - ovalHeight), ovalWidth, ovalHeight)];
	[path fill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.origin.x + 0.5f * (rect.size.width - ovalWidth), rect.origin.y, ovalWidth, ovalHeight)];
	[path fill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.origin.x + 0.5f * (rect.size.width - ovalWidth), rect.size.height - ovalHeight, ovalWidth, ovalHeight)];
	[path fill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.size.width - ovalWidth, rect.origin.y + 0.5f * (rect.size.height - ovalHeight), ovalWidth, ovalHeight)];
	[path fill];
}

#pragma mark -
#pragma mark Room Zoom View Properties

@synthesize background, backgroundClipRect;

- (DMConnections) connections
{
	return connections;
}

- (void) setConnections:(DMConnections) c
{
	[self willChangeValueForKey: @"connections"];
	connections = c;
	[self didChangeValueForKey: @"connections"];
	[self setNeedsDisplay: YES];
}

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
	
	[self exitHasBeenSelected: clickedExit];
}

- (void)mouseMoved:(NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];

	if (connectionStart != DMExitNone) {
		currentMousePosition = p;
		[self setNeedsDisplay: YES];
	}
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	isShiftPressed = (theEvent.modifierFlags & NSShiftKeyMask) > 0;
}

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

- (NSPoint) connectionStartCoordinates
{
	NSSize size = self.frame.size;
	
	switch (connectionStart) {
		case DMExitNorth:
			return NSMakePoint(size.width * 0.5f, size.height);
		case DMExitEast:
			return NSMakePoint(size.width, size.height * 0.5f);
		case DMExitSouth:
			return NSMakePoint(size.width * 0.5f, 0);
		case DMExitWest:
			return NSMakePoint(0, size.height * 0.5f);
		default:
			NSLog(@"Unexpected value for connectionStart: %d", connectionStart);
			return NSZeroPoint;
	}
}

- (void) moveLeft:(id)sender
{
	[self exitHasBeenSelected: DMExitWest];
}

- (void) moveRight:(id)sender
{
	[self exitHasBeenSelected: DMExitEast];
}

- (void) moveUp:(id)sender
{
	[self exitHasBeenSelected: DMExitNorth];
}

- (void) moveDown:(id)sender
{
	[self exitHasBeenSelected: DMExitSouth];
}

- (void) deleteBackward:(id)sender
{
	[self clearConnections];
}

- (void) keyDown:(NSEvent *)theEvent
{
	if (theEvent.keyCode == 36) {
		[self switchToMap];
	} else {
		[self interpretKeyEvents: [NSArray arrayWithObject: theEvent]];
	}
}

#pragma mark -
#pragma mark Making and Breaking Connections

- (void) makeConnection
{
	[delegate roomZoom: self toggleConnectionFromExit: connectionStart
				toExit: connectionEnd
		 bidirectional: !(isShiftPressed)];
}

- (void) exitHasBeenSelected: (DMExit) selectedExit
{
	if (connectionStart == DMExitNone) {
		connectionStart = selectedExit;
		connectionEnd = DMExitNone;
	} else {
		connectionEnd = selectedExit;
		
		if (connectionStart != DMExitNone && connectionEnd != DMExitNone && connectionStart != connectionEnd) {
			[self makeConnection];
		}
		
		connectionStart = connectionEnd = DMExitNone;
	}
	
	[self setNeedsDisplay: YES];
}

- (void) clearConnections
{
	[delegate roomZoomClearConnections: self];
}

#pragma mark -

#pragma mark Switching Views

- (void) switchToMap
{
	[mapWindow makeKeyAndOrderFront: self];
}

@end
