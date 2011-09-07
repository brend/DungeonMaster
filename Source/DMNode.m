//
//  DMNode.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import "DMNode.h"


@implementation DMNode

- (id) initWithMap: (DMMap *) m room: (DMRoom) r entrance: (DMExit) e goal: (DMRoom) g goalEntrance: (DMExit) ge warped: (BOOL) w predecessor: (DMNode *) p
{
	if (self = [super init]) {
		map = [m retain];
		room = r;
		entrance = e;
		goal = g;
		goalEntrance = ge;
		predecessor = [p retain];
		didWarpHere = w;
		
		depth = predecessor == nil ? 0 : 1 + [predecessor depth];
		cost = depth + abs(goal.x - room.x) + abs(goal.y - room.y);
	}
	
	return self;
}

+ (id) nodeWithMap: (DMMap *) m room: (DMRoom) r entrance: (DMExit) e goal: (DMRoom) g goalEntrance: (DMExit) ge warped: (BOOL) w predecessor: (DMNode *) p
{
	return [[[DMNode alloc] initWithMap: m room: r entrance: e goal: g goalEntrance: ge warped: w predecessor: p] autorelease];
}

- (void) dealloc
{
	[map release];
	[predecessor release];
	[super dealloc];
}

- (DMNode *) predecessor
{
	return predecessor;
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"(%d, %d, %@)", room.x, room.y, DMGetExitName(entrance), nil];
}

- (NSString *) pathDescription
{
	NSString *s = DMGetExitName(DMGetOppositeExit(entrance));
	
	if (predecessor == nil)
		return s;
	else
		return [NSString stringWithFormat: @"%@, %@", [predecessor pathDescription], s, nil];
}

- (NSArray *) path
{
	NSMutableArray *a = [NSMutableArray arrayWithCapacity: [self depth]];
	DMNode *n = self;

	while ([n predecessor]) {
		// [a insertObject: [NSValue valueWithPoint: [n roomAsPoint]] atIndex: 0];
		[a insertObject: n atIndex: 0];
		n = [n predecessor];
	}
	
	return a;
}

- (DMRoom) room
{
	return room;
}

- (NSPoint) roomAsPoint
{
	return NSMakePoint(room.x, room.y);
}

- (DMExit) entrance
{
	return entrance;
}

- (BOOL) didWarpHere
{
	return didWarpHere;
}

- (NSArray *) successors
{
	NSMutableArray *successors = [NSMutableArray arrayWithCapacity: 4];
	DMExit exits = 0;
	
	// Collect entrances
	for (int i = 0; i < 4; ++i) {
		if (entrance & (1 << i))
			exits |= [map connectionsAtX: room.x y: room.y exit: (1 << i)];
	}
	
	// Look for possible exits
	for (int i = 0; i < 4; ++i) {
		DMExit e = 1 << i;
		
		if (exits & e) {
			DMRoom nr = room;
			DMExit ne = DMExitInvalid;
			
			switch (e) {
				case DMExitNorth:
					nr.y += 1;
					ne = DMExitSouth;
					break;
				case DMExitSouth:
					nr.y -= 1;
					ne = DMExitNorth;
					break;
				case DMExitWest:
					nr.x -= 1;
					ne = DMExitEast;
					break;
				case DMExitEast:
					nr.x += 1;
					ne = DMExitWest;
					break;
			}
			
			if (!(nr.x < 0 || nr.x >= [map width] || nr.y < 0 || nr.y >= [map height]))
				[successors addObject: [DMNode nodeWithMap: map room: nr entrance: ne goal: goal goalEntrance: goalEntrance warped: NO predecessor: self]];
		}
	}
	
	// Look for a teleporter
	DMConnections c = [map connectionsAtX: room.x y: room.y];
	DMExit allTeleportEntrances = DMExitInvalid;
	
	// TODO Switch loswerden; brauche alle erreichbaren Eingaenge
	switch (c.teleportEntrance) {
		case DMExitNorth:
			allTeleportEntrances = c.north;
			break;
		case DMExitSouth:
			allTeleportEntrances = c.south;
			break;
		case DMExitWest:
			allTeleportEntrances = c.west;
			break;
		case DMExitEast:
			allTeleportEntrances = c.east;
			break;
	}
	
	if (c.teleportTarget >= 0 && allTeleportEntrances & entrance) {
		DMRoom r = [map roomWithIndex: c.teleportTarget];
		
		[successors addObject: [DMNode nodeWithMap: map room: r entrance: c.teleportExit goal: goal goalEntrance: goalEntrance warped: YES predecessor: self]];
	}
	
	return successors;
}

- (BOOL) isGoalNode
{
	return DMRoomsAreEqual(room, goal) && 
				(entrance == goalEntrance || [map connectionsAtX: room.x y: room.y exit: entrance] & goalEntrance);
}

- (unsigned) depth
{
	return depth;
}

- (unsigned) cost
{
	return cost;
}

- (BOOL) isEqual: (id) n
{
	return DMRoomsAreEqual([self room], [n room]) && entrance == [n entrance];
}

- (NSUInteger) hash
{
	return [[NSNumber numberWithInt: room.x + room.y + entrance] hash];
}

- (NSComparisonResult) compare: (DMNode *) n
{
	if ([self cost] < [n cost])
		return NSOrderedAscending;
	else if ([self cost] > [n cost])
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

@end
