#import <Cocoa/Cocoa.h>

#define min(x, y)	((x) < (y) ? (x) : (y))
#define max(x, y)	((x) < (y) ? (y) : (x))

typedef enum {
	DMExitNone	= 0,
	DMExitNorth = 1 << 0,
	DMExitSouth = 1 << 1,
	DMExitWest	= 1 << 2,
	DMExitEast	= 1 << 3,
	DMExitInvalid = 1 << 4,
	DMExitAll	= 0xF
} DMExit;

typedef struct {
	int x, y;
} DMRoom;

typedef struct {
	DMExit north, south, east, west, teleportEntrance, teleportExit;
	int teleportTarget;
} DMConnections;

NSString *DMGetExitName(DMExit e);
DMExit DMGetOppositeExit(DMExit e);
DMRoom DMMakeRoom(int x, int y);
BOOL DMRoomsAreEqual(DMRoom a, DMRoom b);
DMExit DMGetExitByName(NSString *name);
DMExit DMGetExitByInitial(NSString *initial);
DMConnections DMMakeEmptyConnections();
