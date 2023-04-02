---
title: Set Default | The Mirin Template
---
[Back to main page](..)
# SetDefault
```lua
setdefault {percent, mod}
```
Sets the default value of the mod, which affects the initial value, and what value [`reset`](reset.md) will set the mod to.
Unlike [`set`](ease.md#set), this function cannot take a player number, and must apply to all players.

`setdefault` should be used to set the value of mods that are expected to stay on the
entire file, even through `reset`s.

Examples:
```lua
-- sets 5x for this modfile
setdefault {5, 'xmod'}

-- sets a default value for a bunch of mods
setdefault {2, 'xmod', 100, 'dizzyholds', 100, 'stealthtype', 100, 'stealthpastreceptors', 100, 'reversetype', 100, 'modtimer'}
```

`setdefault` can also be used for user-created mods:
```lua
-- create a mod that adjusts the zoom of the background
definemod {'backgroundzoom', function(z)
	backgroundsprite:zoom(z / 100)
end}
-- by default, the background should have a default zoom of 100%
setdefault {100, 'backgroundzoom'}
```
