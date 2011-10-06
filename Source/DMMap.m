//
//  DMMap.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import "DMMap.h"

@interface DMMap ()
- (NSString *) encodeConnections: (DMExit) connections;
@end

@implementation DMMap

- (id) init
{
	if (self = [super init]) {
		width = height = 1;
		rooms = (DMConnections *) malloc(sizeof(DMConnections));
	}
	
	return self;
}

+ (id) map
{
	return [[[DMMap alloc] init] autorelease];
}

- (id) initWithContentsOfFile: (NSString *) filename
{
	if (self = [super init]) {
		int headerLength = 3;
		
		NSError *error = nil;
		NSString *c = [NSString stringWithContentsOfFile: filename encoding: NSUTF8StringEncoding error: &error];
		
		if (c == nil)
			@throw [NSException exceptionWithName: @"ReadFile" reason: [NSString stringWithFormat: @"Unable to read file \"%@\"; reason: %@", filename, error] userInfo: nil];
		
		NSArray *a = [c componentsSeparatedByString: @"\n"];
		
		if ([a count] < headerLength)
			@throw [NSException exceptionWithName: @"InvalidHeader" reason: @"File to short (less than 2 lines)" userInfo: nil];
		
		image = [[a objectAtIndex: 0] retain];
		
		if (![DMMap parseLine: [a objectAtIndex: 1] forWidth: &width height: &height])
			@throw [NSException exceptionWithName: @"InvalidHeader" reason: [NSString stringWithFormat: @"Invalid size line: \"%@\"", [a objectAtIndex: 1], nil] userInfo: nil];
		
		int startRoomIndex = [[a objectAtIndex: 2] intValue];
		
		preferredStartRoom = [self roomWithIndex: startRoomIndex];
		
		rooms = (DMConnections *) malloc(sizeof(DMConnections) * width * height);
		for (int i = 0; i < width * height; ++i)
			rooms[i] = DMMakeEmptyConnections();
		
		a = [a subarrayWithRange: NSMakeRange(headerLength, [a count] - headerLength)];
		
		NSEnumerator *e = [a objectEnumerator];
		NSString *line;
		
		while (line = [e nextObject]) {
			int roomIndex = -1, teleportTarget = -1;
			DMExit exits = 0, entrance = 0, teleportExit = 0, teleportEntrance = 0;
			
			if ([line = [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0)
				continue;
			
			if (![DMMap parseLine: line
						  forRoom: &roomIndex
						 entrance: &entrance
							exits: &exits
				 teleportEntrance: &teleportEntrance
				   teleportTarget: &teleportTarget
					 teleportExit: &teleportExit]) {
				NSLog(@"invalid line: \"%@\"", line);
				continue;
			}
			
			if (roomIndex < 0 || roomIndex >= width * height) {
				NSLog(@"Line ignored because of invalid room index: \"%@\"", line);
				continue;
			}
			
			DMConnections c = rooms[roomIndex];
			
			if (entrance != DMExitInvalid) {
				for (int j = 0; j < 4; ++j) {
					switch (entrance) {
						case DMExitNorth:
							c.north = exits;
							break;
						case DMExitEast:
							c.east = exits;
							break;
						case DMExitSouth:
							c.south = exits;
							break;
						case DMExitWest:
							c.west = exits;
							break;
						default:
							@throw [NSException exceptionWithName: NSGenericException reason: @"Unexpected value for 'entrance" userInfo: nil];
					}
				}
			} else {
				if (teleportTarget >= 0) {
					c.teleportEntrance = teleportEntrance;
					c.teleportTarget = teleportTarget;
					c.teleportExit = teleportExit;
				} else
					NSLog(@"Neither normal nor teleport line: \"%@\"", line);
			}
			
			rooms[roomIndex] = c;
		}
	}
	
	return self;
}

- (id) initWithDimensions: (NSSize) dimensions
	   preferredStartRoom: (DMRoom) startRoom
					rooms: (DMConnections *) theRooms
					image: (NSString *) imageFilename
{
	if ((self = [super init])) {
		width = (int) dimensions.width;
		height = (int) dimensions.height;
		preferredStartRoom = startRoom;
		rooms = theRooms;
		image = [imageFilename copy];
	}
	
	return self;
}

- (void) dealloc
{
	if (rooms != NULL) {
		free(rooms);
		rooms = NULL;
	}
	[image release];
	image = nil;
	[super dealloc];
}

- (id) mapByChangingDimensions: (NSSize) dimensions
{
	NSAssert(dimensions.width > 0, @"Width must be greater than 0");
	NSAssert(dimensions.height > 0, @"Height must be greater than 0");
	
	int alteredWidth = (int) dimensions.width;
	int alteredHeight = (int) dimensions.height;
	
	// Start room will be kept, if inside dimensions; (0,0) otherwise
	DMRoom startRoom =
		(preferredStartRoom.x >= 0 && preferredStartRoom.x < alteredWidth
		 && preferredStartRoom.y >= 0 && preferredStartRoom.y < alteredHeight)
			? preferredStartRoom
			: DMMakeRoom(0, 0);
	DMConnections *theRooms = (DMConnections *) malloc(alteredWidth * alteredHeight * sizeof(DMConnections));
	
	if (theRooms == NULL)
		@throw [NSException exceptionWithName: @"Malloc failed" reason: @"Could not initialize theRooms" userInfo: [NSDictionary dictionaryWithObject: [NSValue valueWithSize: dimensions] forKey: @"dimensions"]];
	
	for (int i = 0; i < alteredWidth * alteredHeight; ++i)
		theRooms[i] = DMMakeEmptyConnections();
	
	for (int y = 0; y < MIN(height, alteredHeight); ++y) {
		for (int x = 0; x < MIN(width, alteredWidth); ++x) {
			theRooms[y * alteredWidth + x] = rooms[y * width + x];
		}
	}
	
	DMMap *alteredMap = [[DMMap alloc] initWithDimensions: dimensions preferredStartRoom: startRoom rooms: theRooms image: self.image];
	
	return [alteredMap autorelease];
}

- (DMExit) connectionsAtX: (int) x
						y: (int) y
					 exit: (DMExit) e
{
	DMConnections c = [self connectionsAtX: x y: y];
	
	switch (e) {
	case DMExitNorth:
		return c.north;
	case DMExitSouth:
		return c.south;
	case DMExitWest:
		return c.west;
	case DMExitEast:
		return c.east;
	default:
		return DMExitInvalid;
	}
}

- (DMConnections) connectionsAtX: (int) x
							  y: (int) y
{
	if (x < 0 || x >= width || y < 0 || y >= height)
		@throw [NSException exceptionWithName: @"IndexOutOfBounds" reason: [NSString stringWithFormat: @"Invalid index (%d, %d)", x, y, nil] userInfo: nil];
	
	return rooms[y * width + x];
}

- (void) setConnections: (DMConnections) connections
					atX: (int) x
					  y: (int) y
{
	if (x < 0 || x >= width || y < 0 || y >= height)
		@throw [NSException exceptionWithName: @"IndexOutOfBounds" reason: [NSString stringWithFormat: @"Invalid index (%d, %d)", x, y, nil] userInfo: nil];

	rooms[y * width + x] = connections;
}

- (int) width
{
	return width;
}

- (int) height
{
	return height;
}

- (DMRoom) preferredStartRoom
{
	return preferredStartRoom;
}

- (DMRoom) roomWithIndex: (int) i
{
	if (i < 0 || i >= width * height)
		@throw [NSException exceptionWithName: @"IndexOutOfBounds" reason: [NSString stringWithFormat: @"Invalid linear index: %d", i, nil] userInfo: nil];
	
	return DMMakeRoom(i % width, i / width);
}

- (int) indexOfRoom:(DMRoom)room
{
	return room.x + room.y * width;
}

@synthesize image;

+ (void) createBlankMapFile: (NSString *) filename 
					  width: (int) w
					 height: (int) h
					  image: (NSString *) image
{
	NSOutputStream *s = [NSOutputStream outputStreamToFileAtPath: filename append: NO];
	NSString *header = [NSString stringWithFormat: @"%@\n%d %d\n", image, w, h, nil];
	
	[s open];
	[s write: (const UInt8 *) [header UTF8String] maxLength: [header length]];
	
	for (int i = 0; i < w * h; ++i) {
		for (int j = 0; j < 4; ++j) {
			NSString *line = [NSString stringWithFormat: @"%d %@ = \n", i, DMGetExitName(1 << j), nil];
			
			[s write: (const UInt8 *) [line UTF8String] maxLength: [line length]];
		}
	}
	
	[s close];
}

+ (DMExit) parseExitString: (NSString *) s
{
	DMExit e = 0;
	
	for (int i = 0; i < 4; ++i) {
		if ([s rangeOfString: [DMGetExitName(1 << i) substringWithRange: NSMakeRange(0, 1)]].location != NSNotFound)
			e |= 1 << i;
	}
	
	return e;
}

+ (BOOL) parseLine: (NSString *) l
		   forRoom: (int *) i 
		  entrance: (DMExit *) en
			 exits: (DMExit *) ex
  teleportEntrance: (DMExit *) teleportEntrance
	teleportTarget: (int *) teleportTarget
	  teleportExit: (DMExit *) teleportExit
{
	NSArray *equation = [l componentsSeparatedByString: @"="];
	
	if ([equation count] != 2)
		return NO;
	
	NSArray *roomId = [[equation objectAtIndex: 0] componentsSeparatedByString: @" "];
	
	if ([roomId count] < 2)
		return NO;
	
	*i = [[roomId objectAtIndex: 0] intValue];
	*en = DMGetExitByName([roomId objectAtIndex: 1]);
	
	// If the entrance is invalid
	if (*en == DMExitInvalid) {
		if ([[roomId objectAtIndex: 1] isEqualToString: @"teleport"]) {
			NSArray *tinfo = [[equation objectAtIndex: 1] componentsSeparatedByString: @" "];
			
			// TODO Indizes rationalisieren
			*teleportEntrance = DMGetExitByInitial([tinfo objectAtIndex: 1]);
			*teleportTarget = [[tinfo objectAtIndex: 2] intValue];
			*teleportExit = DMGetExitByInitial([tinfo objectAtIndex: 3]);
		} else
			return NO;
	} else {
		*ex = [DMMap parseExitString: [equation objectAtIndex: 1]];
	}
	
	return YES;
}

+ (BOOL) parseLine: (NSString *) l forWidth: (int *) w height: (int *) h
{
	NSArray *size = [l componentsSeparatedByString: @" "];
	
	if ([size count] != 2)
		return NO;
	
	*w = [(NSString *) [size objectAtIndex: 0] intValue];
	*h = [(NSString *) [size objectAtIndex: 1] intValue];
	
	return YES;
}

#pragma mark -
#pragma mark Serializing the Map

- (NSString *) stringRepresentation
{
	NSMutableString *text = [NSMutableString string];
	
	[text appendFormat: @"%@\n", self.image];
	[text appendFormat: @"%d %d\n", self.width, self.height];
	[text appendFormat: @"%d\n", [self indexOfRoom: self.preferredStartRoom]];
	
	for (NSInteger i = 0; i < self.width * self.height; ++i) {
		DMRoom room = [self roomWithIndex: i];
		DMConnections connections = [self connectionsAtX: room.x y: room.y];
		NSString *cs = nil;
		
		cs = [self encodeConnections: connections.north];
		if (cs.length > 0)
			[text appendFormat: @"%d north = %@\n", i, cs];
		
		cs = [self encodeConnections: connections.east];
		if (cs.length > 0)
			[text appendFormat: @"%d east = %@\n", i, cs];
		
		cs = [self encodeConnections: connections.south];
		if (cs.length > 0)
			[text appendFormat: @"%d south = %@\n", i, cs];
		
		cs = [self encodeConnections: connections.west];
		if (cs.length > 0)
			[text appendFormat: @"%d west = %@\n", i, cs];
		
		if (connections.teleportTarget >= 0)
			[text appendFormat: @"%d teleport = %@ %d %@\n", i, connections.teleportEntrance, connections.teleportTarget, connections.teleportExit];
	}
	
	return text;
}

- (NSString *) encodeConnections: (DMExit) connections
{
	NSMutableString *text = [NSMutableString string];
	
	if (connections & DMExitNorth)
		[text appendString: @"n"];
	if (connections & DMExitEast)
		[text appendString: @"e"];
	if (connections & DMExitSouth)
		[text appendString: @"s"];
	if (connections & DMExitWest)
		[text appendString: @"w"];
	
	return text;
}

@end
