# sourcebans-extended
This admin mod isn't your typical admin mod where everything is done on an ingame menu; you ***MUST*** edit files. Yes, you do need some lua knowledge, but reading one function should give enough context.

### Files that you need to edit to make this work (ordered by priority):

* sv_sourcebans_database.lua (sourcebans/sv_sourcebans_database.lua)
* SourcebanCFG.lua (sourcebans/autorun/SourcebanCFG.lua)
* sh_sourcebans_shared.lua (sourcebans/sh_sourcebans_shared.lua)
* sv_familyshareblocker.lua (sourcebans/lua/modules/actions/sv_familyshareblocker.lua) Use [this](https://steamcommunity.com/dev/apikey)
* sv_sourceban_gui.lua (sourcebans/lua/modules/commands/sv_sourceban_gui.lua) if you are to change the meta function names

### Information

I won't provide much support for this, sorry.

This module has family share blocker, which blocks the family shared account if the owner of that account is banned

You will need mysqloo, use the link in the shoutout area

You will also need a database to store your bans, duh

As of now, this module is still compatible with SourceBans++ 1.6.3

Use this [link](https://drive.google.com/open?id=1NrgjutfWg1Ov8pvI_FMgfE98lDhN3rIMF7OPEbN5foU) for documentation. This google doc and the official documentation do have similar functions listed, but mine has extra functions which may be useful outside of SourceBans.

TO access the in-game menu, do sm_adminmenu in console. Check sv_sourceban_gui.lua to make sure the meta function "Player:IsModerator()" has all your staff group for them to be able to access the in-game group.

There isn't any adding group function, sorry.

There isn't any noclip command, just use the default noclip key.

In essence, check all files if they are using the correct meta function.

Yo do not need to set permissions permissions on the web panel for groups.

There are chat commands: /bring, /goto, /freeze, /unfreeze, /god, /ungod, /kill, /respawn, /strip. You can use names, steam name, steamid, or steamid64.

You can also use the c menu to ban, kick, freeze, or view ban history!

Screen that shows up when a player is banned is this (kick screen is the same except w/o ban time):

![BanScreen](https://i.imgur.com/mIfKv7T.png)

### Shoutouts

Lexi for allowing SourceBans to be a thing on gmod: https://forum.facepunch.com/gmodaddon/jiep/SourceBans-in-Lua/1/

FredyH for MySQLOO: https://github.com/FredyH/MySQLOO

McSIMP for having family share blocker: https://forum.facepunch.com/gmoddev/mcgm/GMod-What-are-you-working-on-January-2014/11/#postedhai

sbpp for maintaining SourceBans: https://github.com/sbpp/sourcebans-pp
