<html><head><title>Table of Contents | The Mirin Template</title></head></html>

# Mirin Template Documentation

## Table of Contents

| table of contents |
|-------------------|
| <code class="language-lua">[ease](#ease) {beat, len, ease_fn, [percent, mod]+, ?plr=, ?mode=, ?time=}</code> <br> Eases a mod to a specific value. |
| <code class="language-lua">[add](#add) {beat, len, ease_fn, [percent, mod]+, ?plr=, ?mode=, ?time=}</code> <br> Changes a mod by the given amount. |
| <code class="language-lua">[set](#set)</code> <br> Instantly sets a mod to a given value. |
| <code class="language-lua">[acc](#acc)</code> <br> Instantly changes a mod by a given value. |
| <code class="language-lua">[reset](#reset)</code> <br> Sets mods back to their default value. |
| <code class="language-lua">[func](#func)</code> <br> Runs a function at a given time. |
| <code class="language-lua">[perframe](#perframe)</code> <br> Runs a function every frame in a range of time. |
| <code class="language-lua">[func_ease](#func_ease)</code> <br> Eases a function by calling it repeatedly in a given range of time. |
| <code class="language-lua">[alias](#alias)</code> <br> Aliases one mod to another. |
| <code class="language-lua">[setdefault](#setdefault)</code> <br> Sets the default percentage of a mod. |
| <code class="language-lua">[aux](#aux)</code> <br> Marks a mod as auxilliary. |
| <code class="language-lua">[node](#node)</code> <br> Creates a node |
| <code class="language-lua">[definemod](#definemod)</code> <br> Defines a new mod. |
| <code class="language-lua">[get_plr](#get_plr)</code> <br> Gets the `plr` global. |
| <code class="language-lua">[touch_mod](#touch_mod)</code> <br> Re-applies a given mod. |
| <code class="language-lua">[touch_all_mods](#touch_all_mods)</code> <br> Re-applies all mods. |
| <code class="language-lua">[sprite](#sprite)</code> <br> Sets up a sprite for AFT effects. |
| <code class="language-lua">[aft](#aft)</code> <br> Sets up an AFT for AFT effects. |
| <code class="language-lua">[setupJudgeProxy](#setupJudgeProxy)</code> <br> Does things. |
| <code class="language-lua">[backToSongWheel](#backToSongWheel)</code> <br> Does things. |
| <code class="language-lua">[max_pn](#max_pn)</code> <br> Does things. |
| <code class="language-lua">[scx](#scx)</code> <br> The x coordinate of the center of the screen, measured in game units. |
| <code class="language-lua">[scy](#scy)</code> <br> The y coordinate of the center of the screen, measured in game units. |
| <code class="language-lua">[sw](#sw)</code> <br> The width of the screen, measured in game units. |
| <code class="language-lua">[sh](#sh)</code> <br> The height of the screen, measured in game units. |
| <code class="language-lua">[dw](#dw)</code> <br> The width of the screen, measured in actual display pixels |
| <code class="language-lua">[dh](#dh)</code> <br> The height of the screen, measured in actual display pixels |
| <code class="language-lua">[e](#e)</code> <br> e="end" |
| <code class="language-lua">[mod_buffer](#mod_buffer)</code> <br> Does things. |
| <code class="language-lua">[aftsprite](#aftsprite)</code> <br> Does things. |
| <code class="language-lua">[xero](#xero)</code> <br> Does things. |

## Contents
### ease
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

### add
```
add {beat, len, ease_fn, [percent, mod]+, ?plr=, ?mode=, ?time=}
```
Changes a mod by the given amount.

### set
```

```
Instantly sets a mod to a given value.

### acc
```

```
Instantly changes a mod by a given value.

### reset
```

```
Sets mods back to their default value.

### func
```

```
Runs a function at a given time.

### perframe
```

```
Runs a function every frame in a range of time.

### func_ease
```

```
Eases a function by calling it repeatedly in a given range of time.

### alias
```

```
Aliases one mod to another.

### setdefault
```

```
Sets the default percentage of a mod.

### aux
```

```
Marks a mod as auxilliary.

### node
```

```
Creates a node

### definemod
```

```
Defines a new mod.

### get_plr
```

```
Gets the `plr` global.

### touch_mod
```

```
Re-applies a given mod.

### touch_all_mods
```

```
Re-applies all mods.

### sprite
```

```
Sets up a sprite for AFT effects.

### aft
```

```
Sets up an AFT for AFT effects.

### setupJudgeProxy
```

```
Does things.

### backToSongWheel
```

```
Does things.

### max_pn
```

```
Does things.

### scx
```

```
The x coordinate of the center of the screen, measured in game units.

@see SCREEN_CENTER_X

### scy
```

```
The y coordinate of the center of the screen, measured in game units.

@see SCREEN_CENTER_Y

### sw
```

```
The width of the screen, measured in game units.

@see SCREEN_WIDTH

### sh
```

```
The height of the screen, measured in game units.

@see SCREEN_HEIGHT

### dw
```

```
The width of the screen, measured in actual display pixels

### dh
```

```
The height of the screen, measured in actual display pixels

### e
```

```
e="end"

It's obsolete and probably should be removed. (#73)



================== UNDOCUMENTED THINGS =================

### mod_buffer
```

```
Does things.

### aftsprite
```

```
Does things.

### xero
```

```
Does things.

