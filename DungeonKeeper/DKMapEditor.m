//
//  DKMapEditor.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKMapEditor.h"

/*
 * DKMapEditor Private Interface
 */
@interface DKMapEditor ()
- (void) drawConnectionPointsInRect: (NSRect) rect;
- (void) drawConnections: (DMConnections) connections inRect: (NSRect) rect;
- (void) drawConnectionFrom: (NSPoint) p 
					   over: (NSPoint) middle
						 to: (NSPoint) q;
- (void) drawTeleportFrom: (NSPoint) p
					   to: (NSPoint) q;
@end

/*
 * DKMapEditor Implementation
 */
@implementation DKMapEditor

#pragma mark -
#pragma mark Initialization and Deallocation

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    }
    
    return self;
}

- (void)dealloc 
{
    delegate = nil;
	dataSource = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Room Selection

- (NSPoint) selectedRoom
{
	return selectedRoom;
}

- (void) setSelectedRoom:(NSPoint)roomCoordinates
{
	[self willChangeValueForKey: @"selectedRoom"];
	selectedRoom = roomCoordinates;
	[self didChangeValueForKey: @"selectedRoom"];
	[self setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark Drawing the View

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] setFill];
	NSRectFill(dirtyRect);
	
	// Draw the background image
	[background drawAtPoint: NSZeroPoint 
				   fromRect: (NSRect) { .origin = NSZeroPoint, .size = background.size }
				  operation: NSCompositeSourceOver fraction: 1.0];
	
	// Highlight the selected room
	[[NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: 0.5] setFill];
	[NSBezierPath fillRect: [self rectForRoom: self.selectedRoom]];
	
	// Draw the connections
	NSInteger mapWidth = self.mapWidth, mapHeight = self.mapHeight;
	
	for (NSInteger y = 0; y < mapHeight; ++y) {
		for (NSInteger x = 0; x < mapWidth; ++x) {
			NSRect roomRect = [self rectForRoom: NSMakePoint(x, y)];
			DMConnections connections = [dataSource connectionsAtX: x y: y];
			
			// Draw the connection indicators
			if (self.drawConnectionIndicators)
				[self drawConnectionPointsInRect: roomRect];
			
			[self drawConnections: connections inRect: roomRect];
		}
	}
}

- (void) drawConnections: (DMConnections) connections inRect: (NSRect) rect
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
	if (connections.teleportTarget >= 0) {
		NSPoint teleporterEntrance;
		
//		switch (connections.teleportEntrance) {
//			case DMExitNorth:
//				teleporterEntrance = north;
//				break;
//			case DMExitEast:
//				teleporterEntrance = east;
//				break;
//			case DMExitSouth:
//				teleporterEntrance = south;
//				break;
//			case DMExitWest:
//				teleporterEntrance = west;
//				break;
//			default:
//				NSLog(@"Invalid teleporter entrance: %d", connections.teleportEntrance);
//				break;
//		}
//		
//		
		
		teleporterEntrance = NSMakePoint(rect.origin.x + 0.5f * rect.size.width, rect.origin.y + 0.5f * rect.size.height);
		
		NSPoint targetRoom = NSMakePoint(connections.teleportTarget % self.mapWidth, connections.teleportTarget / self.mapWidth);
		NSRect targetRoomRect = [self rectForRoom: targetRoom];
		NSPoint teleporterExit =
			// TODO Make this the correct exit of the target room
			NSMakePoint(targetRoomRect.origin.x + targetRoomRect.size.width * 0.5f, targetRoomRect.origin.y + targetRoomRect.size.height * 0.5f);
//		NSPoint teleportCenter = NSMakePoint(teleporterEntrance.x + 0.5f * (teleporterExit.x - teleporterEntrance.x), 
//											 teleporterEntrance.y + 0.5f * (teleporterExit.y - teleporterEntrance.y));
		
		[self drawTeleportFrom: teleporterEntrance to: teleporterExit];
	}
}

- (void) drawConnectionFrom: (NSPoint) p over: (NSPoint) middle to: (NSPoint) q
{
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[path setLineJoinStyle: NSRoundLineJoinStyle];
	[path setLineCapStyle: NSRoundLineCapStyle];
	[path setLineWidth: 3];
	
	[path moveToPoint: p];
	[path lineToPoint: middle];
	[path lineToPoint: q];
	
	[[NSColor blueColor] setStroke];
	[path stroke];
}

- (void) drawTeleportFrom: (NSPoint) p to: (NSPoint) q
{
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[path setLineJoinStyle: NSRoundLineJoinStyle];
	[path setLineCapStyle: NSRoundLineCapStyle];
	[path setLineWidth: 3];
	
	float dash[] = { 4, 10 };
	
	[path setLineDash: dash count: 2 phase: 0];
	
	[path moveToPoint: p];
	[path lineToPoint: q];
	
	[[NSColor greenColor] setStroke];
	[path stroke];
}

- (void) drawConnectionPointsInRect: (NSRect) rect
{
	float ovalWidth = 16, ovalHeight = 16;
	NSBezierPath *path;
	
	[[NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: 0.5] setFill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.origin.x - 0.5f * ovalWidth, rect.origin.y + 0.5f * (rect.size.height - ovalHeight), ovalWidth, ovalHeight)];
	[path fill];
	
	path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(rect.origin.x + 0.5f * (rect.size.width - ovalWidth), rect.origin.y, ovalWidth, ovalHeight)];
	[path fill];
}

- (BOOL) drawConnectionIndicators
{
	return drawConnectionIndicators;
}

- (void) setDrawConnectionIndicators:(BOOL) flag
{
	if (flag == drawConnectionIndicators)
		return;
	
	[self willChangeValueForKey: @"drawConnectionIndicators"];
	drawConnectionIndicators = flag;
	[self didChangeValueForKey: @"drawConnectionIndicators"];
	[self setNeedsDisplay: YES];
}

- (NSImage *) background
{
	return background;
}

- (void) setBackground:(NSImage *) anImage
{
	[self willChangeValueForKey: @"background"];
	[background autorelease];
	background = [anImage retain];
	self.frame = NSUnionRect(self.frame, (NSRect) { .origin = NSZeroPoint, .size = background.size });
	[self didChangeValueForKey: @"background"];
	[self setNeedsDisplay: YES];
}

- (NSSize)caretSize
{
	if (self.mapWidth == 0 || self.mapHeight == 0 || self.background == nil)
		return NSZeroSize;
	
	return NSMakeSize(self.background.size.width / self.mapWidth, self.background.size.height / self.mapHeight);
}

- (int) mapWidth
{
	return dataSource.mapWidth;
}

- (int) mapHeight
{
	return dataSource.mapHeight;
}

- (NSRect) rectForRoom: (NSPoint) roomCoordinates
{
	NSSize caretSize = self.caretSize;
	
	return NSMakeRect(roomCoordinates.x * caretSize.width, roomCoordinates.y * caretSize.height, caretSize.width, caretSize.height);
}

#pragma mark -
#pragma Drag and Drop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask]; 
	
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }

    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject: NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		NSString *file = [files objectAtIndex: 0];
		
		[delegate mapEditor: self changeBackground: file];
    }
	
    return YES;
}

#pragma mark -
#pragma mark User Interface Events

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (void) mouseDown: (NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
	NSSize caretSize = self.caretSize;
	int x = floor(p.x / caretSize.width), y = floor(p.y / caretSize.height);
	
	[delegate mapEditor: self selectRoom: NSMakePoint(x, y)];
}

- (void)keyDown:(NSEvent *)event
{
	NSPoint roomCoordinates = self.selectedRoom;
	
	switch ([event keyCode]) {
		case kVK_LeftArrow:
			if (roomCoordinates.x > 0)
				roomCoordinates.x -= 1;
			break;
		case kVK_RightArrow:
			if (roomCoordinates.x + 1 < self.mapWidth)
				roomCoordinates.x += 1;
			break;
		case kVK_UpArrow:
			if (roomCoordinates.y + 1 < self.mapHeight)
				roomCoordinates.y += 1;
			break;
		case kVK_DownArrow:
			if (roomCoordinates.y > 0)
				roomCoordinates.y -= 1;
			break;
	}
	
	[delegate mapEditor: self selectRoom: roomCoordinates];
}

@end
