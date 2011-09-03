//
//  DKDocument.m
//  DungeonKeeper
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKDocument.h"

//
// Private DKDocument Interface
//
@interface DKDocument ()
- (void) prepareChangeOfMapDimensions: (NSSize) newDimensions;
@end

// 
// DKDocument Implementation
//
@implementation DKDocument

@synthesize map;

- (id)init
{
    self = [super init];
    if (self) {
		// Load a map for debugging
		self.map = [[[DMMap alloc] initWithContentsOfFile: @"/Users/brph0000/Desktop/DM-Test/zelda_castle_1.txt"] autorelease];
    }
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"DKDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];

	if (self.map && self.map.image) {
		NSImage *background = [[NSImage alloc] initWithContentsOfFile: self.map.image];

		if (background) {
			editor.background = background;
			[background release];
		} else {
			NSLog(@"Could not load background '%@'", self.map.image);
		}
	}
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	/*
	 Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
	You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	*/
	if (outError) {
	    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	/*
	Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
	You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
	If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	*/
	if (outError) {
	    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark -
#pragma mark Commands

- (void) selectRoom: (NSPoint) roomCoordinates
{
	int x = roomCoordinates.x, y = roomCoordinates.y;
	
	if (x < 0 || y < 0 || x >= self.mapWidth || y >= self.mapHeight)
		return;
	
	// Save previous selection
	NSPoint previousSelection = editor.selectedRoom;
	
	// Select the room
	editor.selectedRoom = roomCoordinates;
	
	// Make action undo-able
	[[self undoManager] registerUndoWithTarget: self selector: @selector(selectRoom:) object: [NSValue valueWithPoint: previousSelection]];
}

- (void) changeBackgroundToFile: (NSString *) filename
{
	// TODO: Check if file exists and is an image
	NSString *previousFilename = self.map.image;
	
	self.map.image = filename;
	editor.background = self.mapBackground;
	
	[[self undoManager] registerUndoWithTarget: self selector: @selector(changeBackgroundToFile:) object: previousFilename];
}

- (void) changeMapDimensions: (DKChangeMapParameters *) params
{
	NSSize newDimensions = params.dimensions;
	
	if (newDimensions.width <= 0 || newDimensions.height <= 0) {
		NSLog(@"Invalid map dimensions: %d, %d", (int) newDimensions.width, (int) newDimensions.height);
		return;
	}
	
	NSSize previousDimensions = NSMakeSize(self.map.width, self.map.height);
	DKChangeMapParameters *undoParams = [DKChangeMapParameters paramsWithMap: self.map dimensions: previousDimensions];
	
	self.map = params.map;
	
	// Make action undo-able
	[[self undoManager] registerUndoWithTarget: self selector: @selector(changeMapDimensions:) object: undoParams];
	
	// Re-display map editor
	[editor setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark Map Editor Data Source

- (int) mapWidth
{
	return self.map.width;
}

- (void) setMapWidth:(int)mapWidth
{
	if (mapWidth > 0 && mapWidth != self.mapWidth) {
		NSSize newDimensions = NSMakeSize(mapWidth, self.mapHeight);
		
		[self prepareChangeOfMapDimensions: newDimensions];
	}
}

- (int) mapHeight
{
	return self.map.height;
}

- (void) setMapHeight:(int)mapHeight
{
	if (mapHeight > 0 && mapHeight != self.mapHeight) {
		// Create new map with altered dimensions
		NSSize newDimensions = NSMakeSize(self.mapWidth, mapHeight);
		
		[self prepareChangeOfMapDimensions: newDimensions];
	}
}

- (NSImage *) mapBackground
{
	return [[[NSImage alloc] initWithContentsOfFile: self.map.image] autorelease];
}

- (void) prepareChangeOfMapDimensions: (NSSize) newDimensions
{
	// Create new map with altered dimensions	
	DMMap *alteredMap = [self.map mapByChangingDimensions: newDimensions];
	DKChangeMapParameters *params = [DKChangeMapParameters paramsWithMap: alteredMap dimensions: newDimensions];
	
	// Perform the change
	[self changeMapDimensions: params];
}

#pragma mark -
#pragma mark Map Editor Delegate

- (void) mapEditor: (DKMapEditor *) theEditor selectRoom: (NSPoint) roomCoordinates
{
	[self selectRoom: roomCoordinates];
}

- (void) mapEditor:(DKMapEditor *)theEditor changeBackground: (NSString *) filename
{
	[self changeBackgroundToFile: filename];
}

@end
