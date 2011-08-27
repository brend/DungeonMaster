//
//  DMMap(Saving).h
//  DungeonMaster
//
//  Created by Philipp Brendel on 27.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DMMap.h"

@interface DMMap (Saving)

- (NSData *) toData;

- (NSString *) lineForRoomAtIndex: (int) roomIndex
							 exit: (NSString *) exitName
				   availableExits: (DMExit) exits;

@end
