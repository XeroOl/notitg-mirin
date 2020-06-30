## Eases
In the Mirin Template, mods are controlled through eases, which are transitions that change the value of mods. Lua code allows these eases to be created and played back by the game. Multiple eases can be scheduled to happen at the same time, allowing for interesting and complex movements to be created.

### Differences from previous systems
An important concept to note is that eases only control the *transitions*. The Mirin Template automatically holds mods at their previous value until the next ease transition. Eases don't mark the entire time the mods are active, but only when the mods are *changing*. Because of this, if a mod needs to be enabled for a certain range of time, two eases are necessary: one ease to enable the mod, and another to disable it. Nothing needs to be specified to keep the mod enabled between these two eases.

### Transitioning a Mod with the `ease` Function
An ease has 5 required properties that need to be specified. Additionally, there are two named optional arguments that aren't necessary by default.
```lua
ease {start, lenth, ease_fn, percent, modifier, plr = plr, mode = mode}
```
#### Required Properties
The required properties are `start`, `length`, `ease_fn`, `percent`, and `modifier`. They must be specified in this order in each ease.
* `start`: The first property that needs to be specified is the `start` beat. The ease is scheduled to activate at the `start` beat.
* `length`: The second property is the `length`. This value is also measured in beats, but it is relative to the start beat. The `length` specifies how long the ease will take to complete its transition. A larger `length` will create a slower transition that is spread out further over time.
* `ease_fn`: The third property is the ease function, or `ease_fn`. This is the actual transition that is used to change the mod. For example, the `linear` ease function will make the mod slide linearly from its previous value to the target value.
* `percent`: The fourth property is the target `percent`. This is the value that the mod will be at when the transition is over. An ease doesn't store the initial value of a mod, only its target value. The initial value is assumed to be the target `percent` from the previous ease transition, or 0 if the ease is the first in the timeline.
* `modifier`: The fifth property is the `modifier`, or the specific mod that this ease will change. For example, specifying `'drunk'` will mean that the ease will change the `drunk` modifier.
#### Optional Properties
The optional properties are `plr` and `mode`. These are named arguments, so the order they appear in doesn't matter.
* `plr`: The `plr` argument specifies which player the ease affects. For example, `plr = 1` will target player 1, and `plr = {1, 3}` will target players 1 and 3. If left unspecified, it will attempt to read the `plr` variable from the environment, and if that fails, it will default to `{1, 2}`.
* `mode`: Sometimes, it is easier to choose a start and end beat for the transition, instead of describing the ease by start and length. If the `mode` is set to `'end'`, the ease will interpret the second property to mean the end beat of the transition instead of the length of the transition. This argument is never necessary and is only provided for convenience to make some calculations simpler.

```lua
-- an example with only the main properties
-- starting on beat 5, for 1 beat, change the 'rotationz' modifier to 360
ease {5, 1, outCirc, 360, 'rotationz'}

-- an example with all of the extra properties
-- from beats 10 to 11, change the 'bumpy' modifier to 1000%
ease {10, 11, linear, 1000, 'bumpy', mode = 'end', plr = 1}
```
Note that the optional arguments are specified by name.

### Shorthand Syntax Sugar for Eases

Because eases are used so often, there is some shorthand to make writing many eases more simple.

#### Chain Calls
Multiple eases can be specified after writing the word `ease` once. This is called a chain call, because it calls the ease function with each of the eases, and only works if the eases are in a chain, ie. no other code appears in between the eases. 
```lua
ease
{5, 1, outCirc, 360, 'rotationz'}
{6, 1, outCirc, 0, 'rotationz'}
```

#### Multiple Mods
If multiple mods need to be changed at the same time, multiple target/modifier pairs can be specified in an ease. Here is an example that affects many mods with only one ease:
```lua
ease {5, 3, linear,
    30, 'bumpy',
	10, 'dizzy',
	5000, 'beat',
	500, 'digital',
	100, 'tipsy',
	100, 'drunk',
}
```
This form is only useful when multiple mods need to be changed in exactly the same way. Each target/modifier pair is eased separately.

#### Shorthand for `plr`

The `plr` argument to eases acts differently from other arguments because if unspecified, it will check for a `plr` global variable. This is useful if many eases in sequence need to use special player numbers.
Here is an example of some eases that all affect player 1 only:
```lua
plr = 1
ease {0, 1, linear, 100, 'reverse'}
ease {1, 1, linear, 0, 'reverse'}
ease {2, 1, linear, 100, 'reverse'}
ease {3, 1, linear, 0, 'reverse'}
ease {4, 1, linear, 100, 'reverse'}
-- reset the player to normal so later eases won't be affected
plr = nil
```
This only works if the *global* `plr` is set. It is recommended that `pn` is used for local variables that refer to the player number so that the *global* `plr` can remain in scope. The optional argument will take precedence over the global if both are set.

By default, if the `plr` global isn't present, the function acts on `{1, 2}`, which means that ease transitions without a specified `plr` will affect both the players.
This way to pass the `plr` argument is especially convenient for writing and using helper functions.

Here is an example helper function:
```lua
local function wiggle_around(beat)
	ease
	{beat, 1, pop, 100, 'drunk'}
	{beat, 1, tap, 100, 'tipsy'}
end
```
By default, this function affects both players, because the player number isn't specified in either of its eases. However, the caller can specify a player number using the `plr` global trick:
```lua
-- control which player is affected:
plr = 1
wiggle_around(10)

plr = 2
wiggle_around(20)

-- reset so that future eases aren't affected
plr = nil
```
This `plr` shorthand means that helper functions can be applied to specific players without the need for an explicit player argument to be passed around.

#### Shorthand for `mode`
Instead of writing `mode = 'end'`, adding `m=e` does the same thing, but is shorter to type. Unlike `plr`, there is no global variable check for `mode`.

### Special Case for Speed Mod
The speed-mod is a special modifier because there is no natural modifier name to assign to it, but the Mirin Template gets around that by using the name `xmod` to describe the X-Mod, and `cmod` to describe the C-Mod. This gets around the irregular format that NotITG uses to normally represent the X-Mod and C-Mod.
```lua
-- set the speed mod to 3x
ease {0, 0, instant, 3, 'xmod'}
```

