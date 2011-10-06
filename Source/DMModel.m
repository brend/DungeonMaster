#import "DMModel.h"

@implementation DMModel

@synthesize maps;

- (id) init
{
	if (self = [super init]) {
	}
	
	return self;
}

- (void) replaceDataWithMapString: (NSString *) mapText
{
	NSMutableArray *lines = [NSMutableArray arrayWithArray: [mapText componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
	
	// Remove trailing empty lines
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
	
	while (lines.count > 0 
		   && [[[lines objectAtIndex: lines.count - 1] stringByTrimmingCharactersInSet: whitespace] isEqualToString: @""]) {
		[lines removeObjectAtIndex: lines.count - 1];
	}
	
	// Check for even number of lines
	if (lines.count % 2 != 0)
		@throw [NSException exceptionWithName: NSGenericException reason: @"Map string must contain an even number of lines" userInfo: nil];
	
	// Split text into names and files
	NSMutableArray 
		*nameLines = [NSMutableArray arrayWithCapacity: lines.count / 2],
		*fileLines = [NSMutableArray arrayWithCapacity: lines.count / 2];
	
	for (int i = 0; i < lines.count; ++i) {
		if (i % 2 == 0)
			[nameLines addObject: [lines objectAtIndex: i]];
		else
			[fileLines addObject: [lines objectAtIndex: i]];
	}
	
	[names release];
	names = [[NSArray alloc] initWithArray: nameLines];
	[files release];
	files = [[NSArray alloc] initWithArray: fileLines];
	
	// Create map objects
	NSMutableArray *mapCollection = [NSMutableArray array];
		
	for (int i = 0; i < [names count]; ++i) {
		[mapCollection addObject: [NSDictionary dictionaryWithObjectsAndKeys: [names objectAtIndex: i], @"name", [files objectAtIndex: i], @"file", nil]];
	}
	
	self.maps = mapCollection;
}

- (void) dealloc
{
	[names release];
	names = nil;
	[files release];
	files = nil;
	[maps release];
	maps = nil;
	
	[super dealloc];
}

- (int) numberOfItemsInComboBox: (NSComboBox *) b
{
	return [names count];
}

- (id) comboBox: (NSComboBox *) b objectValueForItemAtIndex: (int) i
{
	return [names objectAtIndex: i];
}

- (IBAction) selectMap: (id) sender
{
	int i = [sender indexOfSelectedItem];
	
	[dungeonView loadMap: [files objectAtIndex: i]];
}

- (id) selectedMap
{
	return selectedMap;
}

- (void) setSelectedMap: (id) map
{
	[self willChangeValueForKey: @"selectedMap"];
	[selectedMap autorelease];
	selectedMap = [map retain];
	[self didChangeValueForKey: @"selectedMap"];
	// TODO Dies eleganter lšsen:
	[dungeonView loadMap: selectedMap];
}

- (BOOL) showRoomIndices
{
	return showRoomIndices;
}

- (void) setShowRoomIndices:(BOOL)flag
{
	[self willChangeValueForKey: @"showRoomIndices"];
	showRoomIndices = flag;
	[self didChangeValueForKey: @"showRoomIndices"];
	dungeonView.showRoomIndices = showRoomIndices;
}

@end
