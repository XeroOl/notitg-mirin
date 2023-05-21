---
title: Reference | The Mirin Template
---
[Back to main page](..)
# Reference
Here's all the functions provided by mirin template:
## Mods
```lua
-- mods related
ease {beat, len, ease_fn, percent, mod}
add {beat, len, ease_fn, relative_percent, mod}
set {beat, percent, mod}
acc {beat, percent, mod}
reset {beat [len, ease]}
reset {beat, exclude = {mod1, mod2, mod3, ...}} -- skip some values
reset {beat, only = {mod1, mod2, mod3, ...}} -- only some values
alias {'oldmodname', 'newmodname'}
setdefault {percent, mod}
aux {mod}
definemod {mod, ..., function(percent, ...[, pn])
    -- your code here
    [return outpercent, ...]
end[, outmod, ...]}
node {mod, ..., function(percent, ...[, pn])
    -- your code here
    [return outpercent, ...]
end[, outmod, ...]}
get_plr() -- reads xero.plr, or {1, 2} if xero.plr is not set
touch_mod(mod[, pn])
touch_all_mods([pn])
```
## Functions
```lua
func {beat, function(b)}
perframe {beat, len, function(b, poptions)}
func_ease {beat, len, ease_fn, [begin_percent defaults to 0], [end_percent defaults to 1], function(p) or 'actor:method']}
```
## Actor Setup
Check a NotITG reference for more details about actor methods.
```lua
sprite(actor)
aft(actor)
```

## Manipulating eases
```lua
flip(eas) -- Flips an ease
blendease(eas1, eas2) -- blends two eases
```
## Miscellaneous
```lua
stable_sort(tbl[, comparator]) -- is a stable sort implementation in lua
unstable_sort(tbl) -- table.sort
copy(tbl[, comparator]): table -- shallow copy a kv table
deepcopy(tbl) -- TODO delete this from the template
clear(tbl) -- set every key in a table to nil
iclear(tbl) -- set every key from 1 to #t in a table to nil
perframe_data_structure() -- Do not use
stringbuilder() -- Do not use
```
## Other Variables
```lua
xero
foreground: ActorFrame -- the root foreground actorframe
dir: string = GAMESTATE:GetCurrentSong():GetSongDir()
strict: table -- Do not use
scx scy sw sh
dw dh
e
```
### Eases:
The [Full ease list](eases.md) has all the eases.

