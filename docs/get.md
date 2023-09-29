---
title: Get | The Mirin Template
---
[Back to main page](..)
# Get

Was removed in version 4 of the Mirin Template!!!!!!

```lua
get(modname)
get(modname, pn)
```
Gets the value most recently written to a mod.

Example:
```lua
for i = 1, 10 do
	ease {i, 1, outExpo, 100 - get('invert'), 'invert'}
end
```
