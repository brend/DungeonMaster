/* DMModel */

#import <Cocoa/Cocoa.h>
#import "DungeonView.h"

@interface DMModel : NSObject
{
	NSArray *names, *files, *maps;
	id selectedMap;
	
	IBOutlet DungeonView *dungeonView;
}

- (void) replaceDataWithMapString: (NSString *) mapText;

- (IBAction) selectMap: (id) sender;

- (int) numberOfItemsInComboBox: (NSComboBox *) b;
- (id) comboBox: (NSComboBox *) b objectValueForItemAtIndex: (int) i;

@property (retain) NSArray *maps;

- (id) selectedMap;
- (void) setSelectedMap: (id) map;

@end
