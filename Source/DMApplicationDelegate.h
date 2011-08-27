//
//  MyClass.h
//  DungeonMaster
//
//  Created by Philipp Brendel on 15.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMModel.h"

@interface DMApplicationDelegate : NSObject
{
	IBOutlet DMModel *model;
}

- (IBAction) open: (id) sender;

@end
