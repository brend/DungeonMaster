//
//  DKDocument.h
//  DungeonKeeper
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMMap.h"

@interface DKDocument : NSDocument 
{
	DMMap *map;
}

@property (retain) DMMap *map;

@end
