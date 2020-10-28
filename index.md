# Mirin Template
[NotITG](https://notitg.heysora.net) is a fork of OpenITG that is designed for creating and playing mod files.

[The Mirin Template](https://www.github.com/XeroOl/notitg-mirin) provides tools to allow mod file creators to implement their ideas.

Join the [NotITG Discord](https://uksrt.heysora.net/discord) to learn more about NotITG.

The Mirin Template is designed to make easing as simple as possible, while remaining incredibly powerful.


## Documentation:
<div style="display:flex">
<div style="flex:50%" markdown="1">
* How to set up the template
* [set](docs/set.md)
* [ease](docs/ease.md)
* [add](docs/ease.md#add)
* for loop
* actors
* [aux](docs/aux.md)
* [node](docs/aux.md#node)
* [alias](docs/alias.md)
</div>
<div style="flex:50%" markdown="1">
* [extra players](docs/players.md)
* mode='end'
* [func](docs/func.md)
* function eases
* poptions
* [aft](docs/aft.md)
* shader
* [list of mods](docs/mods.md)
* [list of ease functions](docs/eases.md)
* [list of all variables](docs/index.md)
</div>
</div>

```lua
-- turn on invert
ease {0, 1, outExpo, 100, 'invert'}
-- turn off invert
ease {7, 1, outExpo, 0, 'invert'}
```
Bonus: [gradients](docs/gradients.md) [splines](docs/splines.md)

Documentation by XeroOl, Chegg, Kirby5464
