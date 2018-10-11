# sourcebans-extended
This admin mod isn't your typical admin mod where everything is done on an ingame menu; you ***MUST*** edit files. Yes, you do need some lua knowledge, but reading one function should give enough context.

### Files that need editing to make this work (ordered by priority):

* sv_sourcebans_database.lua (sourcebans/sv_sourcebans_database.lua)
* SourcebanCFG.lua (sourcebans/autorun/SourcebanCFG.lua)
* sh_sourcebans_shared.lua (sourcebans/sh_sourcebans_shared.lua)
* sv_sourceban_gui.lua (sourcebans/lua/modules/commands/sv_sourceban_gui.lua) if you are to change the meta function names

### Information

This module has family share blocker, which blocks the family shared account if the owner of that account is banned

You will need mysqloo, use the link in the shoutout area

You will also need a database to store your bans, duh

As of now, this module is still compatible with SourceBans++ 1.6.3

### Shoutouts

Lexi for allowing SourceBans to be a thing on gmod: https://forum.facepunch.com/gmodaddon/jiep/SourceBans-in-Lua/1/

FredyH for MySQLOO: https://github.com/FredyH/MySQLOO

McSIMP for having family share blocker: https://forum.facepunch.com/gmoddev/mcgm/GMod-What-are-you-working-on-January-2014/11/#postedhai

sbpp for maintaining SourceBans: https://github.com/sbpp/sourcebans-pp
