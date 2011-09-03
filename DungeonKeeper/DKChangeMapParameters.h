//
//  DKChangeMapParameters.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 03.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMMap.h"

@interface DKChangeMapParameters : NSObject
{
	DMMap *map;
	NSSize dimensions;
}

+ (id) paramsWithMap: (DMMap *) map dimensions: (NSSize) dimensions;

@property (retain) DMMap *map;
@property (assign) NSSize dimensions;

@end
