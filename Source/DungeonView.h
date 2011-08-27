/* DungeonView */

#import <Cocoa/Cocoa.h>
#import "DMSearch.h"

@interface DungeonView : NSView
{
	DMRoom start, goal;
	DMMap *map;
	DMNode *thePlan;
	
	NSSize caretSize;
	NSImage *background;
}

- (void) loadMap: (NSString *) mapName;

- (void) performSearch;

- (void) drawCaret: (NSRect) r color: (NSColor *) c;
- (void) setStrokeForPath: (NSBezierPath **) path dotted: (BOOL) d;
- (NSColor *) walkColor;
- (NSColor *) teleportColor;

@end
