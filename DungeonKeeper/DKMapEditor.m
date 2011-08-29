//
//  DKMapEditor.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKMapEditor.h"

@implementation DKMapEditor

@synthesize selectedRoom;

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
#pragma mark Drawing the View

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] setFill];
	NSRectFill(dirtyRect);
	
	[background drawAtPoint: NSZeroPoint 
				   fromRect: (NSRect) { .origin = NSZeroPoint, .size = background.size }
				  operation: NSCompositeSourceOver fraction: 1.0];
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
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject: NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		NSString *file = [files objectAtIndex: 0];
		
		[delegate mapEditor: self changeBackground: file];
    }
	
    return YES;
}

#pragma mark -
#pragma mark User Interface Events

- (void) mouseDown: (NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
	NSSize caretSize = self.caretSize;
	int x = floor(p.x / caretSize.width), y = floor(p.y / caretSize.height);
	
	[delegate mapEditor: self selectRoom: NSMakePoint(x, y)];
}

@end
