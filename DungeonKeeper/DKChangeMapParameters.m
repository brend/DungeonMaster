//
//  DKChangeMapParameters.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 03.09.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DKChangeMapParameters.h"

@implementation DKChangeMapParameters

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

+ (id) paramsWithMap: (DMMap *) map dimensions: (NSSize) dimensions
{
	DKChangeMapParameters *params = [[DKChangeMapParameters alloc] init];
	
	params.map = map;
	params.dimensions = dimensions;
	
	return [params autorelease];
}

@synthesize map, dimensions;


@end
