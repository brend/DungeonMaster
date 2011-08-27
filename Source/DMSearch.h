//
//  DMSearch.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 24.02.07.
//  Copyright 2007 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMNode.h"

@interface DMSearch : NSObject {
	DMMap *map;
	DMNode *start;
	DMRoom goal;
}

- (id) initWithMap: (DMMap *) m
			  goal: (DMRoom) g
	  goalEntrance: (DMExit) ge
			 start: (DMRoom) s
		  entrance: (DMExit) e;

- (DMNode *) searchForGoal;

@end
