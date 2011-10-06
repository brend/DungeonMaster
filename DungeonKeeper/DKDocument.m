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
- (NSRect) clipRectForRoom: (NSPoint) roomCoordinates;
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
		self.map = [DMMap map];
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
			roomZoom.background = background;
			[background release];
		} else {
			NSLog(@"Could not load background '%@'", self.map.image);
		}
	}
	
	// Set up room zoom
	[roomZoomPanel setAcceptsMouseMovedEvents: YES];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSString *text = [self.map stringRepresentation];
		
	return [text dataUsingEncoding: NSUTF8StringEncoding];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if (!absoluteURL.isFileURL) {
		if (outError)
			*outError = [NSError errorWithDomain: @"Only file URLs allowed" code: 0 userInfo: nil];
		
		return NO;
	}
	
	NSString *filename = absoluteURL.path;
	
	// Set working directory to file path
	NSString *directory = [absoluteURL.path stringByDeletingLastPathComponent];
	
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: directory];
	
	// Read the map file
	DMMap *mapFromFile = nil;
	
	@try	{
		mapFromFile = [[DMMap alloc] initWithContentsOfFile: filename];
	} @catch (NSException *e) {
		if (outError)
			*outError = [NSError errorWithDomain: [e description] code: 0 userInfo: nil];
		
		return NO;
	}
		
	if (mapFromFile) {
		self.map = mapFromFile;
		[mapFromFile release];
		
		return YES;
	} else {
		if (outError)
			*outError = [NSError errorWithDomain: @"Could not read map file" code: 0 userInfo: nil];
		
		return NO;
	}
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
	
	// Select the room in the editor
	editor.selectedRoom = roomCoordinates;
	
	// Select the room in the zoom view
	roomZoom.backgroundClipRect = [self clipRectForRoom: roomCoordinates];
	roomZoom.connections = [self.map connectionsAtX: x y: y];
	[roomZoom setNeedsDisplay: YES];
	
	// Make action undo-able
	[[self undoManager] registerUndoWithTarget: self selector: @selector(selectRoom:) object: [NSValue valueWithPoint: previousSelection]];
}

- (void) changeBackgroundToFile: (NSString *) filename
{
	// TODO: Check if file exists and is an image
	NSString *previousFilename = self.map.image;
	
	self.map.image = filename;
	editor.background = self.mapBackground;
	roomZoom.background = self.mapBackground;
	
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

- (DMConnections) connectionsAtX: (NSInteger) x y: (NSInteger) y
{
	return [self.map connectionsAtX: x y: y];
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

#pragma mark -
#pragma mark Room Zoom View Delegate
- (void) roomZoom:(DKRoomZoomView *)rzv toggleConnectionFromExit:(DMExit)start toExit:(DMExit)end bidirectional: (BOOL) bidirectional
{
	// TODO: Make this undo-able
	NSPoint selectedRoom = editor.selectedRoom;
	DMConnections connections = [self.map connectionsAtX: selectedRoom.x y: selectedRoom.y];
	
	switch (start) {
		case DMExitNorth:
			connections.north = connections.north ^ end;
			break;
		case DMExitEast:
			connections.east = connections.east ^ end;
			break;
		case DMExitSouth:
			connections.south = connections.south ^ end;
			break;
		case DMExitWest:
			connections.west = connections.west ^ end;
			break;
		default:
			NSLog(@"Unexpected connection start: %d", start);
			break;
	}
	
	if (bidirectional) {
		switch (end) {
			case DMExitNorth:
				connections.north = connections.north ^ start;
				break;
			case DMExitEast:
				connections.east = connections.east ^ start;
				break;
			case DMExitSouth:
				connections.south = connections.south ^ start;
				break;
			case DMExitWest:
				connections.west = connections.west ^ start;
				break;
			default:
				NSLog(@"Unexpected connection start: %d", end);
				break;
		}		
	}
	
	[self.map setConnections: connections atX: selectedRoom.x y: selectedRoom.y];
	
	roomZoom.connections = connections;
	
	[editor setNeedsDisplay: YES];
	[roomZoom setNeedsDisplay: YES];
}

- (void) roomZoomClearConnections: (DKRoomZoomView *) rzv
{
	NSPoint selectedRoom = editor.selectedRoom;
//	DMConnections connections = [self.map connectionsAtX: selectedRoom.x y: selectedRoom.y];
	DMConnections connections = DMMakeEmptyConnections();
	
	[self.map setConnections: connections atX: selectedRoom.x y: selectedRoom.y];
	
	roomZoom.connections = connections;
	
	[editor setNeedsDisplay: YES];
	[roomZoom setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark Display Options
- (BOOL) drawConnectionIndicators
{
	return editor.drawConnectionIndicators;
}

- (void) setDrawConnectionIndicators:(BOOL) flag
{
	editor.drawConnectionIndicators = flag;
}

#pragma mark -
#pragma mark Auxiliary Display Stuff

- (NSRect) clipRectForRoom: (NSPoint) roomCoordinates
{
	NSSize caretSize = [editor caretSize];
	
	return NSMakeRect(roomCoordinates.x * caretSize.width, roomCoordinates.y * caretSize.height, caretSize.width, caretSize.height);
}

@end
