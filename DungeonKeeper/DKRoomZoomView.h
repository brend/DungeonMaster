//
//  DKRoomZoomView.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 11.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DKRoomZoomView : NSView
{
	NSImage *background;
	NSRect backgroundClipRect;
}

@property (retain) NSImage *background;
@property NSRect backgroundClipRect;

@end
