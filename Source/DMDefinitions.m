#include "DMDefinitions.h"

inline NSString *DMGetExitName(DMExit e)
{
	switch (e) {
		case DMExitNorth:
			return @"north";
		case DMExitSouth:
			return @"south";
		case DMExitWest:
			return @"west";
		case DMExitEast:
			return @"east";
		default:
			return [NSString stringWithFormat: @"undefined: %d", e, nil];
	}
}

inline DMExit DMGetOppositeExit(DMExit e)
{
	switch (e) {
		case DMExitNorth:
			return DMExitSouth;
		case DMExitSouth:
			return DMExitNorth;
		case DMExitWest:
			return DMExitEast;
		case DMExitEast:
			return DMExitWest;
		default:
			return DMExitInvalid;
	}
}

inline DMRoom DMMakeRoom(int x, int y)
{
	DMRoom r;
	
	r.x = x;
	r.y = y;
	
	return r;
}

inline BOOL DMRoomsAreEqual(DMRoom a, DMRoom b)
{
	return a.x == b.x && a.y == b.y;
}

inline DMExit DMGetExitByName(NSString *name)
{
	if ([name isEqualToString: @"north"])
		return DMExitNorth;
	else if ([name isEqualToString: @"south"])
		return DMExitSouth;
	else if ([name isEqualToString: @"west"])
		return DMExitWest;
	else if ([name isEqualToString: @"east"])
		return DMExitEast;
	else
		return DMExitInvalid;
}

inline DMExit DMGetExitByInitial(NSString *name)
{
	if ([name isEqualToString: @"n"])
		return DMExitNorth;
	else if ([name isEqualToString: @"s"])
		return DMExitSouth;
	else if ([name isEqualToString: @"w"])
		return DMExitWest;
	else if ([name isEqualToString: @"e"])
		return DMExitEast;
	else
		return DMExitInvalid;
}

inline DMConnections DMMakeEmptyConnections()
{
	DMConnections c;
	
	c.north = c.south = c.west = c.east = c.teleportEntrance = c.teleportExit = DMExitNone;
	c.teleportTarget = -1;
	
	return c;
}

inline CGFloat DMPointDistance(NSPoint p, NSPoint q)
{
	CGFloat dx = q.x - p.x, dy = q.y - p.y;
	
	return sqrtf(dx * dx + dy * dy);
}

inline DMExit DMEntrancesForExit(DMConnections c, DMExit exit)
{
	switch (exit) {
		case DMExitNorth:
			return c.north;
		case DMExitEast:
			return c.east;
		case DMExitSouth:
			return c.south;
		case DMExitWest:
			return c.west;
		default:
			@throw [NSException exceptionWithName: @"Invalid exit" reason: [NSString stringWithFormat: @"Not a valid singular exit: %d", exit] userInfo: nil];
	}
}
