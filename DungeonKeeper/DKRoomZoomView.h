//
//  DKRoomZoomView.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 11.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKRoomZoomView;

@protocol DKRoomZoomViewDelegate <NSObject>
- (void) roomZoom: (DKRoomZoomView *) rzv toggleConnectionFromExit: (DMExit) start toExit: (DMExit) end bidirectional: (BOOL) bidirectional;
- (void) roomZoomClearConnections: (DKRoomZoomView *) rzv;
@end

@interface DKRoomZoomView : NSView
{
	NSImage *background;
	NSRect backgroundClipRect;
	
	DMConnections connections;
	
	DMExit connectionStart, connectionEnd;
	
	NSPoint currentMousePosition;
	BOOL isShiftPressed;
	
	IBOutlet id<DKRoomZoomViewDelegate> delegate;
}

@property (retain) NSImage *background;
@property NSRect backgroundClipRect;

@property DMConnections connections;

- (DMExit) connectionPointFromPoint: (NSPoint) p;
- (void) makeConnection;

- (void) exitHasBeenSelected: (DMExit) e;
- (void) clearConnections;

@end
