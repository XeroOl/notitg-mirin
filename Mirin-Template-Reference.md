If you see anything that is incomplete or could be improved, feel free to click the **Edit button** above and make any changes you'd like.

You are welcome to make changes.

Changes you make here will automatically update the doc website and tooling.
(not implemented yet)

# ease
```
ease {beat, len, ease_fn, [percent, mod]+, ?plr=, ?mode=, ?time=}
```
Eases a mod to a specific value.

The animation lasts `len` beats, and animates using the selected `ease_fn`.

* `beat` -- the song beat when the mod begins to apply
* `len` -- the amount of beats before the ease is complete
* `ease_fn` -- the animation used to approach the target value.
* `percent` -- the target value for the given mod.
* `mod` -- the mod to ease.
* If `time=true` is set, then the first argument will be interpreted in seconds instead of beats.
* If `mode=true` is set, then the second argument will be interpreted as an absolute timestamp instead of a duration.
* If `plr=` is set
  * to a number, the ease will only affect the specified player.
  * to a table of numbers, the ease will only affect the specified players.

# add
```
add {beat, len, ease_fn, [percent, mod]+, ?plr=, ?mode=, ?time=}
```
Changes a mod by the given amount.


# set
Instantly sets a mod to a given value.
# acc
Instantly changes a mod by a given value.
# reset
Sets mods back to their default value.
# func
Runs a function at a given time.
# perframe
Runs a function every frame in a range of time.
# func_ease
Eases a function by calling it repeatedly in a given range of time.
# alias
Aliases one mod to another.
# setdefault
Sets the default percentage of a mod.
# aux
Marks a mod as auxilliary.
# node
Creates a node
# definemod
Defines a new mod.
# get_plr
Gets the `plr` global.
# touch_mod
Re-applies a given mod.
# touch_all_mods
Re-applies all mods.
# sprite
Sets up a sprite for AFT effects.
# aft
Sets up an AFT for AFT effects.
# setupJudgeProxy
Does things.
# backToSongWheel
Does things.
# max_pn
Does things.
# scx
The x coordinate of the center of the screen, measured in game units.

@see SCREEN_CENTER_X
# scy
The y coordinate of the center of the screen, measured in game units.

@see SCREEN_CENTER_Y
# sw
The width of the screen, measured in game units.

@see SCREEN_WIDTH
# sh
The height of the screen, measured in game units.

@see SCREEN_HEIGHT
# dw
The width of the screen, measured in actual display pixels
# dh
The height of the screen, measured in actual display pixels
# e
e="end"

It's obsolete and probably should be removed. (#73)



================== UNDOCUMENTED THINGS =================
# mod_buffer
Does things.
# aftsprite
Does things.
# xero
Does things.
# end