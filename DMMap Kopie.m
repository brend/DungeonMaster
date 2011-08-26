//
//  DMMap.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import "DMMap.h"


@implementation DMMap

- (id) init
{
	if (self = [super init]) {
	}
	
	return self;
}

- (id) initWithContentsOfFile: (NSString *) filename
{
	if (self = [super init]) {
		int headerLength = 2;
		NSString *c = [NSString stringWithContentsOfFile: filename];
		
		if (c == nil)
			@throw [NSException exceptionWithName: @"ReadFile" reason: [NSString stringWithFormat: @"File couldn't be read: %@", filename, nil] userInfo: nil];
		
		NSArray *a = [c componentsSeparatedByString: @"\n"];
		
		if ([a count] < headerLength)
			@throw [NSException exceptionWithName: @"InvalidHeader" reason: @"File to short (less than 2 lines)" userInfo: nil];
		
		image = [[a objectAtIndex: 0] retain];
		
		NSArray *size = [[a objectAtIndex: 1] componentsSeparatedByString: @" "];
		
		width = [(NSString *) [size objectAtIndex: 0] intValue];
		height = [(NSString *) [size objectAtIndex: 1] intValue];
		
		if ([a count] < headerLength + width * height)
			@throw [NSException exceptionWithName: @"InvalidBody" reason: [NSString stringWithFormat: @"Lines expected: %d, found: %d", headerLength + width * height, [a count], nil] userInfo: nil];
		
		rooms = (DMConnections *) malloc(sizeof(DMConnections) * width * height);
		a = [a subarrayWithRange: NSMakeRange(headerLength, [a count] - headerLength)];
		
		for (int i = 0; i < width * height; ++i) {
			DMConnections c;
			
			for (int j = 0; j < 4; ++j) {
				NSString *exitString = [[[a objectAtIndex: i * 4 + j] componentsSeparatedByString: @"="] objectAtIndex: 1];
				DMExit exits = [DMMap parseExitString: exitString];
				
				switch (1 << j) {
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
				}
			}
			
			rooms[i] = c;
		}
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
	[super dealloc];
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

- (int) width
{
	return width;
}

- (int) height
{
	return height;
}

- (NSString *) image
{
	return image;
}

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

@end
