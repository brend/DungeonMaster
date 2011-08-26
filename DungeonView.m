#import "DungeonView.h"

@implementation DungeonView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		srand(time(NULL));
		
		// [self loadMap: @"zelda_castle_9"];
		
		// [DMMap createBlankMapFile: @"/Users/brph0000/Desktop/template.txt" width: 8 height: 8 image: @"zelda_castle_1.gif"];
	}
	
	return self;
}

- (void) loadMap: (NSString *) mapName
{
	// Search
	[map release];
	
	// NSString *mapFile = [[NSBundle mainBundle] pathForResource: mapName ofType: @"txt"];
	NSString *mapFile = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent: mapName];
	
	if (mapFile == nil) {
		NSLog(@"Couldn't load map file");
		map = [[DMMap alloc] init];
	} else {
		map = [[DMMap alloc] initWithContentsOfFile: mapFile];
		start = goal = [map preferredStartRoom];
	}
	
	[self performSearch];
	
	// Image
	[background release];
	background = [[NSImage alloc] initWithContentsOfFile: [map image]];
	caretSize = NSMakeSize([background size].width / [map width], [background size].height / [map height]);
	
	// Redraw
	[self setNeedsDisplay: YES];
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (void) mouseDown: (NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
	int x = floor(p.x / caretSize.width), y = floor(p.y / caretSize.height);
	
	if (x < 0 || x >= [map width] || y < 0 || y >= [map height]) {
		NSLog(@"Invalid coordinates: %d, %d", x, y);
		return;
	}
	
	if ([e type] == NSRightMouseDown)
		start = DMMakeRoom(x, y);
	else
		goal = DMMakeRoom(x, y);

	[self performSearch];
	[self setNeedsDisplay: YES];
}

- (void) rightMouseDown: (NSEvent *) e
{
	NSPoint p = [self convertPoint: [e locationInWindow] fromView: nil];
	int x = floor(p.x / caretSize.width), y = floor(p.y / caretSize.height);
	
	if (x < 0 || x >= [map width] || y < 0 || y >= [map height]) {
		NSLog(@"Invalid coordinates: %d, %d", x, y);
		return;
	}
	
	if ([e type] == NSRightMouseDown)
		start = DMMakeRoom(x, y);
	else
		goal = DMMakeRoom(x, y);
	
	[self performSearch];
	[self setNeedsDisplay: YES];
}

- (void) performSearch
{
	DMSearch *s = [[DMSearch alloc] initWithMap: map
										   goal: goal
								   goalEntrance: DMExitAll // NOTE Jeder Eingang ist z.Zt. recht
										  start: start
									   // entrance: DMExitWest];
									   entrance: DMExitAll]; // NOTE Jeder...
	
	[thePlan release];
	thePlan = [[s searchForGoal] retain];
	
	[s release];
}

- (void) tick: (id) userInfo
{
	goal = DMMakeRoom(rand() % 8, rand() % 8);
	[self performSearch];
	[self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)rect
{	
	// NSImage *buffer = [[NSImage alloc] initWithSize: rect.size];
	
	// [buffer lockFocus];
	
	[background compositeToPoint: NSMakePoint(0, 0) operation: NSCompositeSourceOver];
	
	NSSize s = caretSize;
	
	// Draw goal and start
	[self drawCaret: NSMakeRect(start.x * s.width, start.y * s.height, s.width, s.height) color: [NSColor colorWithDeviceRed: 0 green: 1 blue: 0 alpha: 0.3]];
	[self drawCaret: NSMakeRect(goal.x * s.width, goal.y * s.height, s.width, s.height) color: [NSColor colorWithDeviceRed: 1 green: 0 blue: 1 alpha: 0.3]];
	
	// Draw path from start to goal, if any
	if (thePlan != nil) {
		NSEnumerator *e = [[thePlan path] objectEnumerator];
		DMNode *n;
		BOOL previousWasWarp = NO;
		NSBezierPath *path = [NSBezierPath bezierPath];
		
		[path moveToPoint: NSMakePoint(s.width * (start.x + 0.5), s.height * (start.y + 0.5))];
		[path setLineWidth: 5.0];
		[path setLineCapStyle: NSRoundLineCapStyle];
		[path setLineJoinStyle: NSRoundLineJoinStyle];

		[[self walkColor] setStroke];
				
		while (n = [e nextObject]) {
			DMRoom p = [n room];
			NSPoint q = NSMakePoint(s.width * (p.x + 0.5), s.height * (p.y + 0.5));
			
			if ([n didWarpHere] != previousWasWarp)
				[self setStrokeForPath: &path dotted: previousWasWarp = !previousWasWarp]; // NOTE Also changes color
			
			[path lineToPoint: q];
		}
		
		[path stroke];
	}
	
	// [buffer unlockFocus];
	// [buffer compositeToPoint: NSMakePoint(0, 0) operation: NSCompositeSourceOver];
	// [buffer release];
}

- (void) drawCaret: (NSRect) r color: (NSColor *) c
{
	NSBezierPath *p = [NSBezierPath bezierPathWithRect: r];
	
	[c setFill];
	[p fill];
}

- (void) setStrokeForPath: (NSBezierPath **) path dotted: (BOOL) dotted
{
	NSPoint currentPoint = [*path currentPoint];
	float lineWidth = [*path lineWidth];
	NSLineCapStyle capStyle = [*path lineCapStyle];
	NSLineJoinStyle joinStyle = [*path lineJoinStyle];
	
	[*path stroke];
	*path = [NSBezierPath bezierPath];
	[*path setLineWidth: lineWidth];
	[*path setLineCapStyle: capStyle];
	[*path setLineJoinStyle: joinStyle];
	[*path moveToPoint: currentPoint];
	
	if (dotted) {
		float dash[] = { 4, 10 };
		
		[*path setLineDash: dash count: 2 phase: 0];
		
		[[self teleportColor] setStroke];
	} else
		[[self walkColor] setStroke];
}

- (NSColor *) walkColor
{
	return [NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: 1];
}

- (NSColor *) teleportColor
{
	return [NSColor colorWithDeviceRed: 0 green: 1 blue: 0 alpha: 1];
}

@end
