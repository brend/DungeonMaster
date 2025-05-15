# Dungeon Master

(not the game, the mapping tool!)

Dungeon Master is a simple application that does one thing:
It helps you find your path through those pesky dungeons
in which you never can remember the way to the boss.
I'm looking straight atcha, Level-9!

## Project details

Application "DungeonMaster": Displays dungeon map files
and can find paths from one room to another.

## Map file format

See the file "Map file format.txt" for the details of the format
for a single map file (dungeon map).

## Configuration file

A configuration file brings many maps together to
a set. Every odd line contains the (arbitrary) title of a map,
the following even line is the path to the map file itself
(either absolute or relative to the path of the configuration file).
E.g.:
The Fire Dungeon
fire_dungeon.txt
The Ice Dungeon
dungeon_a_la_glace.txt
etc.
