# Player Objects
### [P](players.md)
### [P1, P2, P3, P4, P5, P6, P7, P8](players.md)

# Mod Functions
### [add](ease.md#add)
### [alias](alias.md)
### [aux](aux.md)
### [ease](ease.md)
### [func](func.md)
### [node](aux.md#node)
### [set](set.md)

# Proxy Actors
### PC
A table of proxies for the combo object. `PC[1]` holds P1's combo, and `PC[2]` holds P2's combo.
### PJ
A table of proxies for the judgment object. `PJ[1]` holds P1's judgment, and `PJ[2]` holds P2's combo.
### PP
A table of player proxies. `PP[1]` holds a P1 proxy, and `PP2` holds a P2 proxy.
### setupJudgeProxy
This function helps set up the proxies for the judgment and combo.

# Actor Helpers
### aft
Yeah.
### aftsprite
Yeah.
### sprite
Yeah.

# Eases
### bell
### bounce
### tap
### tapElastic
### impulse
### inBack
### inBounce
### inCirc
### inCubic
### inElastic
### inExpo
### inOutBack
### inOutBounce
### inOutCirc
### inOutCubic
### inOutElastic
### inOutExpo
### inOutQuad
### inOutQuart
### inOutQuint
### inOutSine
### inQuad
### inQuart
### inQuint
### inSine
### instant
### inverse
### linear
### outBack
### outBounce
### outCirc
### outCubic
### outElastic
### outExpo
### outQuad
### outQuart
### outQuint
### outSine
### pop
### popElastic
### pulse
### pulseElastic
### spike
### tri

# Constants
### dh
The display height, in actual pixels. This is only useful for AFT stuff, because NotITG uses screen pixels for measurement.
### dw
The display width, in actual pixels.
### e
Shorthand for `'end'`.
### plr
Write to this value to specify the player arguments for `set`, `ease`, and `add`.
Instead of reading from this variable, use the [get_plr](#get_plr) function.
### scx
The X coordinate of the center of the screen measured in screen pixels. In a 4:3 aspect ratio, this will equal 320.
### scy
The Y coordinate of the center of the screen measured in screen pixels. In a 4:3 aspect ratio, this will equal 240.
### sh
The screen height, measured in screen pixels. In a 4:3 aspect ratio, this will equal 480.
### sw
The screen width, measured in screen pixels, In a 4:3 aspect ratio, this will equal 640.

# Provided by Lua
These functions come as part of the Lua programming language. These functions are covered extensively in [the Lua Reference](https://www.lua.org/manual/5.1/manual.html), but a summary is provided here for convenience.

### ipairs
This function can be used in a for loop to iterate over numerical keys:
```lua
for i, v in ipairs(t) do
	-- body
end
```
will iterate over the pairs `(1,t[1])`, `(2,t[2])`, ···, up to the first integer key absent from the table.

### pairs
This function can be used in a for loop to iterate over key, value pairs:
```lua
for k, v in pairs(t) do
	-- body
end
```
will iterate over all key–value pairs of table t.

### math
Read about this in the [Lua Reference](https://www.lua.org/manual/5.1/manual.html#5.6).
### string
Read about this in the [Lua Reference](https://www.lua.org/manual/5.1/manual.html#5.4).
### table
Read about this in the [Lua Reference](https://www.lua.org/manual/5.1/manual.html#5.5).
### tonumber
### tostring
### type
### unpack
### print
Writes into the game's console and logs with a message whenever it is run.
To see the log, set `ShowLogOutput` to `1` in `Data/Stepmania.ini` while the game is closed.
If a message on the screen is required, use `SCREENMAN:SystemMessage()` instead.

# Additional Functions
### xero
Call this at the beginning of every Command for the scope to work.
### stringbuilder
This is kind of cool.
### stable_sort
### copy
### get_plr
Reads the `plr` global's actual value. Use this instead of directly reading the `plr` global.
### max_pn
The maximum player number that the template supports. It's set to `8`.
### mod_buffer
An internal `stringbuilder` to keep track of which mods to apply. Don't use it.
### normalize_mod
A function to follow any aliases.
### screen_error

# Implementation Internals
This section will help navigate the template folder to see how features are implemented.
### on_command
### begin_update_command
### update_command
### compile_nodes
### foreground
### perframe_data_structure
### __PLUGINS
### __call
### __index

# Locals in `template.xml`
This section is a reference for working on the template. It lists the types of all of the tables that are used in the template. This should provide some insight into how the internals work.
### aliases
`{old: string, replacement: string}`
The look up table for aliased mods.
### reverse_aliases
`{name: string, old: {...string}}`
The reverse of the `aliases` table. Shows which mods are aliased to `name`.
### eases
`{beat: number, len: number, eas: function(number): number, percent: number, modname:string, ... , ['plr']:number, ['transient']: boolean, ['relative']: boolean}`
Sorted by `beat`.
### active_eases
same as `eases` table, but only ones that meet `beat <= curbeat < beat+len`
### funcs
`{beat: number, len: number?, func: function(beat, poptions): void, ['mods']: { {[key: string]: number} * max_pn}?, ['priority']: number}`
sorted by priority, but negative priorities are placed after positive ones, so that `defer=true` funcs will be placed last.
### active_funcs
same as `funcs`, but only ones that meet `len and (beat <= curbeat < beat+len)`
### auxes
`{[key: string]: true}`
### mods
`{ {[key: string]: number} * max_pn}`
but only values that are going to be applied this frame
### targets
`{ {[key: string]: number} * max_pn}`
the value that the mod will arive at once all of the currently active eases complete
### poptions
behaves as if it has the type `{ {[key: string]: number} * max_pn}`
### nodes
`{inputs: {...string}, out: {...string}, fn: function(?):?, ['priority']: number}`
sorted by priority, but negative priorities are placed after positive ones, so that `defer=true` nodes will be placed last.
### node_start
A horrible amalgamation of recursive types.
