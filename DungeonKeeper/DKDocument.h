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
#import "DKChangeMapParameters.h"

@interface DKDocument : NSDocument <DKMapEditorDelegate, DKMapEditorDataSource>
{
	DMMap *map;
	IBOutlet DKMapEditor *editor;
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
#pragma mark Commands

- (void) selectRoom: (NSPoint) roomCoordinates;
- (void) changeBackgroundToFile: (NSString *) filename;
- (void) changeMapDimensions: (DKChangeMapParameters *) parameters;

@end
