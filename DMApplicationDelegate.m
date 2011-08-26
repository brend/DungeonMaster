//
//  DMApplicationDelegate.m
//  DungeonMaster
//
//  Created by Philipp Brendel on 15.08.11.
//  Copyright 2011 BrendCorp. All rights reserved.
//

#import "DMApplicationDelegate.h"

// #define LOAD_DEBUG_MAP

@implementation DMApplicationDelegate

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Debugging
#ifdef LOAD_DEBUG_MAP
	NSError *error = nil;
	NSString *mapString = [NSString stringWithContentsOfFile: @"/Users/brph0000/Desktop/DM/Mapfile.txt" encoding: NSUTF8StringEncoding error: &error];
	
	if (error) {
		NSRunAlertPanel(@"An error occurred loading the test file", [error description], @"OK", nil, nil);
		return;
	}

	[[NSFileManager defaultManager] changeCurrentDirectoryPath: @"/Users/brph0000/Desktop/DM"];
	[model replaceDataWithMapString: mapString];
#endif
}

- (IBAction) open: (id) sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes: [NSArray arrayWithObject: @"txt"]];
	if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
		NSString *filename = [[openPanel.URLs objectAtIndex: 0] path];
		NSString *directory = [filename stringByDeletingLastPathComponent];
		NSError *error = nil;
		NSString *text = [NSString stringWithContentsOfFile: filename encoding: NSUTF8StringEncoding error: &error];
		
		if (text) {
			[[NSFileManager defaultManager] changeCurrentDirectoryPath: directory];
			[model replaceDataWithMapString: text];
		} else {
			NSRunAlertPanel(@"An error occurred loading the map configuration file", [NSString stringWithFormat: @"%@", error], @"OK", nil, nil);
			return;
		}
	}
}

@end
