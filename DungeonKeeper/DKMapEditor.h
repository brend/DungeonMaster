//
//  DKMapEditor.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKMapEditor;

@protocol DKMapEditorDelegate <NSObject>
- (void) mapEditor: (DKMapEditor *) theEditor selectRoom: (NSPoint) roomCoordinates;
- (void) mapEditor:(DKMapEditor *)theEditor changeBackground: (NSString *) filename;
@end

@protocol DKMapEditorDataSource <NSObject>
@property (readonly) int mapWidth, mapHeight;
@property (readonly) NSImage *mapBackground;
- (DMConnections) connectionsAtX: (NSInteger) x y: (NSInteger) y;
@end

@interface DKMapEditor : NSView
{
	NSImage *background;
	NSPoint selectedRoom;
	BOOL drawConnectionIndicators;
	
	IBOutlet id<DKMapEditorDelegate> delegate;
	IBOutlet id<DKMapEditorDataSource> dataSource;
	IBOutlet NSWindow *zoomWindow;
}

@property (retain) NSImage *background;
@property BOOL drawConnectionIndicators;
@property (readonly) NSSize caretSize;
- (NSRect) rectForRoom: (NSPoint) roomCoordinates;
@property (readonly) int mapWidth, mapHeight;

@property (assign) NSPoint selectedRoom;

#pragma mark -
#pragma mark Switching Views

- (void) switchToZoom;

@end
