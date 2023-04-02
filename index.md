---
title: The Mirin Template
---
# Mirin Template
[NotITG](https://notitg.heysora.net) is a fork of OpenITG that is designed for creating and playing mod files.

[The Mirin Template](https://www.github.com/XeroOl/notitg-mirin) provides tools to allow mod file creators to implement their ideas.

Join the [NotITG Discord](https://uksrt.heysora.net/discord) to learn more about NotITG.

The Mirin Template is designed to make easing as simple as possible, while remaining incredibly powerful.


## Documentation:
[Index](docs/index.md) - in progress
<br>
[Choosing a template](comparison.md)
<br>
[Getting Started](Getting Started.md)
<br>
<div style="display:flex">
<div style="flex:50%" markdown="1">
* [How to set up the template](Getting Started.md)
* [setdefault](docs/setdefault.md)
* [set](docs/set.md)
* [ease](docs/ease.md)
* [add](docs/ease.md#add)
* [for loop](docs/for.md)
* [actors](docs/actors.md)
* [definemod](docs/definemod.md)
* [reset](docs/reset.md)
* [aux](docs/doc-aux.md)
* [node](docs/doc-aux.md#node)
* [alias](docs/alias.md)
</div>
<div style="flex:50%" markdown="1">
* [extra players](docs/players.md)
* mode='end'
* [flip](docs/flip.md)
* [get](docs/get.md)
* [func](docs/func.md)
* [function eases](docs/func.md#func_for_function_eases)
* [poptions](docs/func.md#poptions)
* [aft](docs/aft.md)
* shaders
* [list of mods](docs/mods.md)
* [list of ease functions](docs/eases.md)
</div>
</div>
Bonus:
* [learn Lua](https://www.lua.org/manual/5.1/)
* [gradients](docs/gradients.md)
* [splines](docs/splines.md)

Example code:
```lua
-- turn on invert
ease {0, 1, outExpo, 100, 'invert'}
-- turn off invert
ease {7, 1, outExpo, 0, 'invert'}
```


Documentation by XeroOl, Chegg, Kirby5464, Spax
