//
//  DKMapEditor.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKMapEditor.h"

@implementation DKMapEditor

@synthesize background;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] setFill];
	NSRectFill(dirtyRect);
	
	[background drawAtPoint: NSZeroPoint 
				   fromRect: (NSRect) { .origin = NSZeroPoint, .size = background.size }
				  operation: NSCompositeSourceOver fraction: 1.0];
}

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
		
		self.background = [[[NSImage alloc] initWithContentsOfFile: file] autorelease];
		
		[self setNeedsDisplay: YES];
    }
	
    return YES;
}

@end
