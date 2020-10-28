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
### PJ
### PP
### setupJudgeProxy

# Actor Helpers
### aft
### aftsprite
### sprite

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
### dw
### e
### plr
### scx
### scy
### sh
### sw

# Provided by Lua
### ipairs
### math
### pairs
### string
### table
### tonumber
### tostring
### type
### unpack
### print

# Additional Functions
### xero
### stringbuilder
### stable_sort
### copy
### get_plr
### max_pn
### mod_buffer
### normalize_mod
### screen_error

# Implementation Internals
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
This section is more of a reference for working on the template. It lists the types of all of the tables that are used in the template. This should provide some insight into how the internals work.
### aliases
`{old: string, replacement: string}`
### reverse_aliases
`{name: string, old: {...string}}`
### eases
`{beat: number, len: number, eas: function(number): number, percent: number, modname:string, ... , ['plr']:number, ['transient']: boolean, ['relative']: boolean}`
Sorted by `beat`
### active_eases
same as `eases` table, but only ones that meet `beat <= curbeat < beat+len`
### funcs
`{beat: number, len: number?, func: function(beat, poptions): void, ['mods']: {\{[key: string]: number} * max_pn}?, ['priority']: number}`
sorted by priority, but negative priorities are placed after positive ones, so that `defer=true` funcs will be placed last.
### active_funcs
same as `funcs`, but only ones that meet `len and (beat <= curbeat < beat+len)`
### auxes
`{[key: string]: true}`
### mods
`{\{[key: string]: number} * max_pn}`
but only values that are going to be applied this frame
### targets
`{\{[key: string]: number} * max_pn}`
the value that the mod will arive at once all of the currently active eases complete
### poptions
behaves as if it has the type `{\{[key: string]: number} * max_pn}`
### nodes
`{inputs: {...string}, out: {...string}, fn: function(?):?, ['priority']: number}`
sorted by priority, but negative priorities are placed after positive ones, so that `defer=true` nodes will be placed last.
### node_start
A horrible amalgamation of recursive types
