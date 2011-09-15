//
//  DKDocument.h
//  DungeonKeeper
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMMap.h"
#import "DKMapEditor.h"
#import "DKRoomZoomView.h"
#import "DKChangeMapParameters.h"

@interface DKDocument : NSDocument <DKMapEditorDelegate, DKMapEditorDataSource, DKRoomZoomViewDelegate>
{
	DMMap *map;
	IBOutlet DKMapEditor *editor;
	IBOutlet NSPanel *roomZoomPanel;
	IBOutlet DKRoomZoomView *roomZoom;
}

@property (retain) DMMap *map;

#pragma mark -
#pragma mark Map Editor Data Source
@property (assign) int mapWidth, mapHeight;
- (DMConnections) connectionsAtX: (NSInteger) x y: (NSInteger) y;

#pragma mark -
#pragma mark Map Editor Delegate
- (void) mapEditor: (DKMapEditor *) theEditor selectRoom: (NSPoint) roomCoordinates;
- (void) mapEditor:(DKMapEditor *)theEditor changeBackground: (NSString *) filename;

#pragma mark -
#pragma mark Room Zoom View Delegate
- (void) roomZoom:(DKRoomZoomView *)rzv makeConnectionFromExit:(DMExit)start toExit:(DMExit)end;

#pragma mark -
#pragma mark Commands

- (void) selectRoom: (NSPoint) roomCoordinates;
- (void) changeBackgroundToFile: (NSString *) filename;
- (void) changeMapDimensions: (DKChangeMapParameters *) parameters;

#pragma mark -
#pragma mark Display Options
@property BOOL drawConnectionIndicators;

@end
