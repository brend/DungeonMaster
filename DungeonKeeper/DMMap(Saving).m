//
//  DMMap(Saving).m
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DMMap(Saving).h"

@implementation DMMap (Saving)

- (NSData *) toData
{
	NSMutableString *s = [NSMutableString stringWithCapacity: 4 * 1024];
	
	[s appendFormat: @"%@\n", image];
	[s appendFormat: @"%d %d\n", width, height];
	[s appendFormat: @"%d\n", [self indexOfRoom: [self preferredStartRoom]]];
	
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			int i = y * width + x;
			
			// North
			DMExit exitsAvailableFromNorth = [self connectionsAtX: x y: y exit: DMExitNorth];
			
			[s appendFormat: @"%@\n", [self lineForRoomAtIndex: i exit: @"north" availableExits: exitsAvailableFromNorth]];
			
			// South
			DMExit exitsAvailableFromSouth = [self connectionsAtX: x y: y exit: DMExitSouth];
			
			[s appendFormat: @"%@\n", [self lineForRoomAtIndex: i exit: @"south" availableExits: exitsAvailableFromSouth]];
			
			// West
			DMExit exitsAvailableFromWest = [self connectionsAtX: x y: y exit: DMExitWest];
			
			[s appendFormat: @"%@\n", [self lineForRoomAtIndex: i exit: @"west" availableExits: exitsAvailableFromWest]];
			
			// East
			DMExit exitsAvailableFromEast = [self connectionsAtX: x y: y exit: DMExitEast];
			
			[s appendFormat: @"%@\n", [self lineForRoomAtIndex: i exit: @"east" availableExits: exitsAvailableFromEast]];
		}
	}
	
	NSData *data = [s dataUsingEncoding: NSUTF8StringEncoding];
	
	return data;
}

- (NSString *) lineForRoomAtIndex: (int) roomIndex
							 exit: (NSString *) exitName
				   availableExits: (DMExit) exits
{
	NSMutableString *connectionsString = [NSMutableString string];
	
	if ((exits & DMExitNorth) > 0)
		[connectionsString appendString: @"n"];
	if ((exits & DMExitSouth) > 0)
		[connectionsString appendString: @"s"];
	if ((exits & DMExitWest) > 0)
		[connectionsString appendString: @"w"];
	if ((exits & DMExitEast) > 0)
		[connectionsString appendString: @"e"];
	
	return [NSString stringWithFormat: @"%d %@ = %@", roomIndex, exitName, connectionsString];
}

@end
