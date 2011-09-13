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
- (void) roomZoom: (DKRoomZoomView *) rzv makeConnectionFromExit: (DMExit) start toExit: (DMExit) end;
@end

@interface DKRoomZoomView : NSView
{
	NSImage *background;
	NSRect backgroundClipRect;
	
	DMExit connectionStart, connectionEnd;
	
	IBOutlet id<DKRoomZoomViewDelegate> delegate;
}

@property (retain) NSImage *background;
@property NSRect backgroundClipRect;

- (DMExit) connectionPointFromPoint: (NSPoint) p;
- (void) makeConnection;

@end
