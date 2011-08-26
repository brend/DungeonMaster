//
//  DMSearch.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import "DMSearch.h"


@implementation DMSearch

- (id) initWithMap: (DMMap *) m
			  goal: (DMRoom) g
	  goalEntrance: (DMExit) ge
			 start: (DMRoom) s
		  entrance: (DMExit) e
{
	if (self = [super init]) {
		map = [m retain];
		start = [[DMNode alloc] initWithMap: m room: s entrance: e goal: g goalEntrance: ge warped: NO predecessor: nil];
		goal = g;
	}
	
	return self;
}

- (void) dealloc
{
	[map release];
	[super dealloc];
}

- (DMNode *) searchForGoal
{
	DMNode *n = nil;
	NSMutableSet *visited = [[NSMutableSet alloc] init];
	NSMutableArray *open = [[NSMutableArray alloc] init];

	[open addObject: start];
	
	do {
		n = [open objectAtIndex: 0];
		[open removeObjectAtIndex: 0];
		
		if (DMRoomsAreEqual(goal, [n room])) {
			[visited release];
			[open release];
			
			return n;
		}
		
		[visited addObject: n];
		
		NSEnumerator *e = [[n successors] objectEnumerator];
		DMNode *m;
		
		while (m = [e nextObject])
			if (![visited containsObject: m])
				[open addObject: m];
		[open sortUsingSelector: @selector(compare:)];
	} while ([open count] > 0);
	
	[visited release];
	[open release];
	
	return nil;
}

@end
