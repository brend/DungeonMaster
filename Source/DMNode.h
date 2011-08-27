//
//  DMNode.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMDefinitions.h"
#import "DMMap.h"

@interface DMNode : NSObject {
	DMMap *map;
	DMNode *predecessor;
	DMExit entrance, goalEntrance;
	DMRoom room, goal;
	BOOL didWarpHere;
	
	unsigned depth, cost;
}

- (id) initWithMap: (DMMap *) m room: (DMRoom) r entrance: (DMExit) e goal: (DMRoom) g goalEntrance: (DMExit) ge warped: (BOOL) w predecessor: (DMNode *) n;
+ (id) nodeWithMap: (DMMap *) m room: (DMRoom) r entrance: (DMExit) e goal: (DMRoom) g goalEntrance: (DMExit) ge warped: (BOOL) w predecessor: (DMNode *) n;

- (DMNode *) predecessor;

- (NSString *) description;
- (NSString *) pathDescription;
- (NSArray *) path;

- (DMRoom) room;
- (NSPoint) roomAsPoint;
- (DMExit) entrance;
- (BOOL) didWarpHere;

- (BOOL) isGoalNode;
- (unsigned) depth;
- (unsigned) cost;
- (NSArray *) successors;

- (BOOL) isEqual: (id) n;
- (unsigned) hash;

- (NSComparisonResult) compare: (DMNode *) n;

@end
