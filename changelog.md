# Releases
https://github.com/XeroOl/notitg-mirin/releases


# Mirin Template v5.0.1 Hotfix
Secret update 5.0.1

## New Features ##
* Mod name validation no longer applies to `aux`ed mods ([#69](https://github.com/XeroOl/notitg-mirin/issues/69))

## Bug Fixes ##
* `Esc` → `Play From Current Beat` now doesn't do the funny thing.
* `require` now actually finds lua files in the `plugins` folder.
* `set {0, 100, 'invert', 100, 'invert'}` now doesn't confuse the engine.


# Mirin Template v5.0.0
Version 5 is here!

## New Features ##
* Everything is in real **Lua** files now.
  * No need to download specialized plugins to get syntax highlighting, formatting, and linting.
Use `require` to load more `.lua` files.

* There are `outIn` eases now, for those who want a complete ease collection.

* Clearer function names:
  * `func` is now three functions: `func`, `perframe`, and `func_ease`
* New `blendease` function!
  * It's kind of like `flip`, but takes two eases and combines them smoothly!  
  (the precise definition is `blendease(a, b)(t) = mix(a(t), b(t), smoothstep(t))`)

* Ease params are coded better internally, but it means you have to call them with a `:` now.  
`(outBack:param(1.1)` instead of `outBack.param(1.1))`

* Testing code!
  * Versions in the future should be much less likely to break stuff because I'm using the wonderful [busted](http://olivinelabs.com/busted/) framework for testing things.

## Bug Fixes ##
* No more `ScreenReadyCommand`
  * Files will work in Marathon Mode, and with `Ctrl`+`R`
* Probably more. I wasn't keeping track.

## Things Not Added™ ##
I don't trust the implementation of `delay=` enough for it to make it into this release, so it's not included yet. DM me (`XeroOl#5452`) on Discord if you want a build with `delay=`, because I don't want to support it "officially".

Have fun, and happy modding!


# Mirin Template v4.0.3 Hotfix
Important Bug fix

## Bug Fixes ##
* Fixes random crashes, flickering, and broken mod movement under certain conditions.

## Notes ##
* Files made in `v4.0.0` to `v4.0.2` should be retroactively updated to `v4.0.3`, because it fixes potential crashes and no other behavior is changed.
* If you're updating a pre-existing file, you just need to replace the `template/` folder.


# Mirin Template v4.0.2 Hotfix
I am once again asking for your downloading support

## Bug Fixes ##
* More bug fixes!!
* `func` now works again


# Mirin Template v4.0.1 Hotfix
Apologies if you downloaded `v4.0.0`, You'll want to use `v4.0.1` instead. There's a major issue with player specific mods in `v4.0.0`.

## Bug Fixes ##
* Fixes a major bug that prevents anything player-specific from working.


# Mirin Template v4.0.0
Here we go! A bunch of bug fixes and cool features in this version.

## New Features ##
* Time based mods !!!!!!!
  * You can now add a `time=true` to any `ease`/`set`/`add`/`func`/`reset`/`acc` to switch the units to **seconds** instead of **beats**
  * Time-based and beat-based mods can overlap with no issues
  * Time-based mods behave consistently, regardless of globaloffset
* New shorthand forms for things!!!
  * Ever written a `func` that does just one thing? Now you can write it with the "everything eater" shorthand that works with any actor method:
  ```lua
  func {0, 'myactor:diffuse', 0.0, 0.1, 0.5, 1.0}
  ```
  * Want to write a simple `definemod` or `node`? Now you can write simple `definemod`s with this super convenient shorthand:
  ```lua
    definemod {'videogames', 25, 'flip', -75, 'invert'}
  ```
* New Additions!!!
  * You can now `reset` with only a small list of mods using `only=` with `reset`. It's like the opposite of the `exclude=` feature!
  * New `acc` function, which is like `set`, but relative!
  * New `backToSongWheel` function to convey an error to the user without creating an error box.

## Bug Fixes ##
* Eases with parameters now work correctly with `func`
* Fixed instability when using "Play Current Beat to End" in the editor
* `setdefault` is now case-insensitive
* `reset`'s `exclude=` now deals with `alias`ed mod names properly
* overwriting template provided functions, like running `ease = nil` no longer breaks things
* Stronger detection against mod names with typos
* Better error messages when the user calls template functions after the update loop is running
* and more!

## Changes ##
* Huge code refactor!
  * Everything is now more organized
  * Error checking is done in its own section and doesn't get in the way of the logic as much
  * It should be a bit easier to tell what's going on in `template.xml`! Dive in and tell me what you think!
* The error system is switching back from `SystemMessage` to actual error boxes again
  * Error boxes should only pop up once, not every frame
  * After an error box, the template stops running the update loop
* The `get` function is gone now 🦀🦀. We'll miss you!


# Mirin Template v3.0.1 Hotfix
—please remember to download the newest hotfix version `3.0.1` of the Mirin Template—  
It fixed a bug which would cause the game to error when using `func` in the format:
```lua
func {start, len, function}
```

## New Features ##
* you can now use `.param` or `.params` for eases.

## Bug Fixes ##
* `func`'s plain perframe form works again


# Mirin Template v3.0.0
Oops I accidentally an update!

## New features ##
* New `func` variation for function eases for when you have a small function
```lua
func {0, 1, inOutExpo, 0, scx, 'P1:x'}
```
* `alias`es are more precise, so you can do complicated things with `alias`:
```lua
alias
{'movex1', 'movex0'}
{'movex2', 'movex1'}
{'movex3', 'movex2'}
{'movex4', 'movex3'}
```
* New parameters for eases:
```lua
ease {0, 1, outElastic.params(1.5, 0.1), 100, 'invert'}
```
* New helper functions `touch_mod(mod, pn)` and `touch_all_mods(pn)`<br>
```lua
func {5, function()
  touch_all_mods()
end}
```
* Now you can run `touch_all_mods(pn)` after setting a noteskin with `LaunchAttack` to keep the mods on.
* `func` has another shorthand for when you're function-easing a method:
```lua
func {0, 1, inOutExpo, 0, scx, 'P1:x'}
```

## Bug Fixes ##
* if you ease a player that's asleep, it will have the correct mods when it is set to be awake
* `reset` and `setdefault` can now be chained (like, more than one `{}`)
* `zoomz` now correctly defaults to `100`
* `grain` now defaults to `400`
* `outExpo` now is actually smooth, and doesn't end at `0.998` and then jump to `1.0`
* slightly better error message for when `definemod` or `node` have wrong argument order (still bad)

## Notes ##
* Docs are still outdated, and still need `touch_mod`, `touch_all_mods`. The `func` string syntax still isn't documented either. I'd like to also have the docs cover the new `.params`.


# Mirin Template v2
It's time! Here's the new version of the template! It adds some new functions.

## New features ##
* `definemod` now is an easy way to use `aux` and `node`
* `flip` function to flip your eases
* `get` function, to read mod percentages
* `setdefault` function, sets the default value of a mod
* `reset` function, resets mods to their default at a given beat

## Bug Fixes ##
* `zoom` on extra players being jank
* fixed: strange behavior with one of the debug variables


# Mirin Template v1

## New features ##
* case-insensitivity for mods
* `alias` has been split into `aux` and `alias`
* `func` has a `func-ease` mode thing
* `node` thing that apparently only xero cares about
* you can mix `xmod` and `cmod` sort of, please don't stretch this too far (thanks brothermojo)
* you can use `movex` 😩
* you can use `zoom` now
* only loads `.xml` files from plugins folder (so that you can keep the docs from [notitg-mirin-plugins](https://github.com/xerool/notitg-mirin-plugins)) 

## Notes ##
* everything is untested now, consider it an alpha I guess
* you have to declare your `alias`es before you use them now (`aux`es are still free to put wherever)
* a little bit of technical debt because I need to figure out how to do `xmod`+`cmod` the "correct" way