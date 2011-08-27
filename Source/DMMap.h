//
//  DMMap.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMDefinitions.h"

@interface DMMap : NSObject {
	int width, height;
	DMRoom preferredStartRoom;
	DMConnections *rooms;
	
	NSString *image;
}

- (id) init;
- (id) initWithContentsOfFile: (NSString *) filename;

- (DMExit) connectionsAtX: (int) x
						y: (int) y
					 exit: (DMExit) e;
- (DMConnections) connectionsAtX: (int) x
							  y: (int) y;

- (int) width;
- (int) height;
- (DMRoom) preferredStartRoom;
- (DMRoom) roomWithIndex: (int) i;
- (int) indexOfRoom: (DMRoom) room;

- (NSString *) image;

+ (void) createBlankMapFile: (NSString *) filename 
					  width: (int) w
					 height: (int) h
					  image: (NSString *) image;
+ (DMExit) parseExitString: (NSString *) s;
+ (BOOL) parseLine: (NSString *) l
		   forRoom: (int *) i 
		  entrance: (DMExit *) en
			 exits: (DMExit *) ex
  teleportEntrance: (DMExit *) ten
	teleportTarget: (int *) ttg
	  teleportExit: (DMExit *) tex;

+ (BOOL) parseLine: (NSString *) l forWidth: (int *) w height: (int *) h;

@end
