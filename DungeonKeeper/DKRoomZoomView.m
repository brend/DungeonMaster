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
	[self drawConnectionPointsInRect: self.frame];
	
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
	NSPoint 
	north = NSMakePoint(rect.origin.x + rect.size.width * 0.5f, rect.origin.y + rect.size.height),
	east = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height * 0.5f),
	south = NSMakePoint(rect.origin.x + rect.size.width * 0.5f, rect.origin.y),
	west = NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height * 0.5f),
	middle = NSMakePoint(rect.origin.x + rect.size.width * 0.5f, rect.origin.y + rect.size.height * 0.5f);
	
	DMExit e = 0;
	
	// Connections from northern entrance
	e = connections.north;
	
	if (e & DMExitEast)
		[self drawConnectionFrom: north over: middle to: east];
	if (e & DMExitSouth)
		[self drawConnectionFrom: north over: middle to: south];
	if (e & DMExitWest)
		[self drawConnectionFrom: north over: middle to: west];
	
	// Connections from eastern entrance
	e = connections.east;
	
	if (e & DMExitNorth)
		[self drawConnectionFrom: east over: middle to: north];
	if (e & DMExitSouth)
		[self drawConnectionFrom: east over: middle to: south];
	if (e & DMExitWest)
		[self drawConnectionFrom: east over: middle to: west];
	
	// Connections from southern entrance
	e = connections.south;
	
	if (e & DMExitNorth)
		[self drawConnectionFrom: south over: middle to: north];
	if (e & DMExitEast)
		[self drawConnectionFrom: south over: middle to: east];
	if (e & DMExitWest)
		[self drawConnectionFrom: south over: middle to: west];
	
	// Connections from western entrance
	e = connections.west;
	
	if (e & DMExitNorth)
		[self drawConnectionFrom: west over: middle to: north];
	if (e & DMExitEast)
		[self drawConnectionFrom: west over: middle to: east];
	if (e & DMExitSouth)
		[self drawConnectionFrom: west over: middle to: south];
	
	// Teleporter connection
//	if (connections.teleportTarget >= 0) {
//		NSPoint teleporterEntrance = NSMakePoint(rect.origin.x + 0.5f * rect.size.width, rect.origin.y + 0.5f * rect.size.height);
//		
//		NSPoint targetRoom = NSMakePoint(connections.teleportTarget % self.mapWidth, connections.teleportTarget / self.mapWidth);
//		NSRect targetRoomRect = [self rectForRoom: targetRoom];
//		NSPoint teleporterExit =
//		NSMakePoint(targetRoomRect.origin.x + targetRoomRect.size.width * 0.5f, targetRoomRect.origin.y + targetRoomRect.size.height * 0.5f);
//		
//		[self drawTeleportFrom: teleporterEntrance to: teleporterExit];
//	}
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
	
	[self setNeedsDisplay: YES];
}

- (void)mouseMoved:(NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];

	if (connectionStart != DMExitNone) {
		currentMousePosition = p;
		[self setNeedsDisplay: YES];
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

- (void) makeConnection
{
	[delegate roomZoom: self makeConnectionFromExit: connectionStart toExit: connectionEnd];
}

@end
