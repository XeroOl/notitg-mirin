<head><title>Reset | The Mirin Template</title></head>

[Back to main page](..)
# Reset
```lua
reset {beat}
reset {beat, len, eas}
reset {beat, exclude = {mod1, mod2, mod3, ...}}
```
It resets all mods to their default value at the specified beat. If `exclude` is provided, it will not reset any of the mods in the list.

See the [setdefault](setdefault.md) page for more information on how to change the default value of a mod.

Examples:
```lua
-- reset the mods at beat 128
reset {128}

-- reset the mods at beat 192, but keep 'reverse' and 'alternate' on
reset {128, exclude = {'reverse', 'alternate'}}

-- reset the mods at beat 256 with an ease, but keep 'spiralx' on
reset {256, 1, outExpo, exclude = 'spiralx'}
```