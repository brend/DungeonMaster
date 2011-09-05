//
//  DKMapEditor.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKMapEditor.h"

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
