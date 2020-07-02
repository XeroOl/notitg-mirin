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
### Function Eases
Function eases are for when you want something to ease that isn't a mod. To use function eases, you provide a function instead of the name of a mod. Your function's signature has to be one of these:
* `(float percent, int pn) => (nil)`
* `(float percent, int pn) => (string)`
```xml
<Layer
	Type = "Quad"
	OnCommand = "zoomto,50,50;xy,SCREEN_CENTER_X,SCREEN_CENTER_Y"
	Name = "my_quad"
/>
```
```lua
-- create a function to change the x position of the quad
local function quad_x(percent, pn)
	if pn == 1 then
		my_quad:x(percent)
	end
end

-- make the quad start at the center
ease {0, 0, instant, scx, quad_x}

-- On beat 10, change to scx / 2.
{10, 5, outExpo, scx / 2, quad_x}
```

### Aliases and the `alias` function

Sometimes, it is easier to give a string name to your functions, so that you can ease them just like other mods. In order to do that, this template has a function called `alias`. This function lets you assign a name to a mod. So, if you have a function ease, you can assign it a name:

```lua
local function my_function_ease(percent, pn)
	--[[ ... ]]
end

alias('custom_name', my_function_ease)
```

You can use either curly braces `{}`, or parentheses `()` for `alias`. If you use curly braces `{}`, then you can chain calls to alias like you can with the other functions.

Then, whenever you want to ease the function, you can use its name instead:
```lua
ease {0, 0, instant, 100, 'custom_name'}
```
The alias also lets you use the new name to index into `poptions` in a perframe. We'll cover perframes later in this document.

Aliases aren't only for function eases: Sometimes, there's two names for the same mod, and you want to use both names interchangeably to refer to the same mod.
```lua
alias('longboy', 'longholds')
```

There's one more use for `alias`. Sometimes, when working with perframes, it's nice to have a value to ease that is only meant to be read from perframes. If you've done modding before, you might have heard of "aux vars". The idea is that you want a value that you can apply eases to that you can read back from later. If you don't provide a second argument to `alias`, then you get a dummy value that you can read from perframes later. Check the documentation of perframes for an example use of this.
```lua
alias('my_mod_name')
alias('custom_mod')
alias('my_aux_var')
```

### Instant Eases and the `set` Function

The `set` function is just like `ease`, except the duration is 0, and the ease is `instant`.

### Relative Eases and the `add` Function
The function `ease` has a sister function, called `add`. This other function works exactly the same as `ease`, except for one important difference: Any percentages used with `add` are interpreted as offsets to the current percent. This is important because it is different behavior than `ease`, where percentages are interpreted as target percentages. Here's an example of some code that uses `add`:

```lua
add
-- turn on invert
{20, 1, outExpo, 100, 'invert'}
-- with `add`, you have to subtract 100 to bring invert back down to 0.
{22, 1, outExpo, -100, 'invert'}


-- add is useful for rotations, where you want to add an amount over and over.
-- spin once
{24, 1, outExpo, 360, 'rotationz'}
-- spin again
{25, 1, outExpo, 360, 'rotationz'}
-- spin for a third time
{26, 1, outExpo, 360, 'rotationz'}
-- After beat 27, rotationz is at 360 * 3, aka 1080.
```
As you can see, the syntax is very similar to `ease`. Note that we used `-100` to turn off `invert`, instead of using `0`.
### Example with a Transient Ease
Transient Eases are a type of ease function that doesn't actually permenantly change the percentage of a mod; it only makes the change temporarily. An example of such an ease function is the `pop` ease. You can see the full list of which ease functions are marked as `transient` on the [List of Built in Eases](easing.md).
```lua
ease
{30, 1, pop, -500, 'tiny'}
```
If you're not sure what I'm trying to show here, try testing this in your game. You should notice that unlike all the previous examples, even though the transition specifies `-1000`, the game doesn't leave the `tiny` mod on.

### Example with Overlapped Eases
```lua
add
{0, 3, outExpo, 100, 'invert'}
{2, 3, outExpo, -100, 'invert'}
```
These two ease lines might seem like a mistake at first, but they actually demonstrate one of the most advanced features of this template. The reason they appear to be a mistake is that the ranges of beats overlap: The first line ends on beat 3, but the second line starts on beat 2. Which one will actually get to set the `invert` mod? It's a trick question: Both the lines share the invert mod at the same time! The two transitions blend together into one clean motion that incorporates everything. The template doesn't just work with two lines: no matter how many eases are happening at the same time, the template will be able to play them all at the same time. Play around with overlapping effects and see what you can do. This feature makes it easy to have good looking eases where the transitions blend into eachother, making one smooth motion. This feature works with both `ease` and `add`, or any combination of the two, so try it out!
### Making Your Own Ease Function
Although the Mirin Template has a decent collection of [Built in Eases](easing.md), you can also make your own ease transitions. Eases are just lua functions take in a number from 0 to 1, and output a number from 0 to 1. For example, `inQuad` is defined as:
```lua
function inQuad(t) return t * t end
```
So, instead of writing `inQuad` in an ease, you could write an ease with a function instead:
```lua
ease {0, 1, function(t) return t * t end, 100, 'bumpy'}
```
The template will determine if the ease is transient by checking `fn(1) <= 0.5`.
### Scheduled Functions (aka. Mod Actions)
Sometimes, you want code to run at a certain beat during a file. To do this, you need to schedule a function. The basic format for a scheduled function is `func {beat, fn}`. For example, if you want to have a system message play at beat 50, you could write this code:
```lua
func {50, function(beat)
	SCREENMAN:SystemMessage 'Hello World!'
end}
```
If you start the file in the editor some time past the given beat, the template will play the scheduled function in an attempt to catch up the game. If you don't want this to happen, you can check the `beat` that's passed in to see if its near the expected value before you run the code in the scheduled function.

### Perframes and Applying Mods from Perframes
Perframes are functions that get called every frame. The basic form for a perframe is `func {beat, len, fn}`.
For example, if you want to use a perframe to make a blacksphere effect.
```lua
func {32, 64, function(beat, poptions)

	-- I want to know how long this perframe has been going,
	-- so I subtract 32 from the current beat
	local time_since_start = beat - 32
	
	-- I want my invert effect to apply on both the players
	for pn = 1, 2 do
		
		-- set the amount of invert for the player
		poptions[pn].drunk = 50 - 50 * math.cos(time_since_start * math.pi)
		
	end
	
end}
```
Poptions acts like a temporary table that is rebuilt every frame. Each frame, the template follows 4 steps:
1. Run the eases to figure out what values every mod has.
2. Run any scheduled functions for the beat.
3. Run all the perframes that are currently active.
4. Find which mods changed, serialize them, and apply to the game. Function eases are also evaluated during this step.

The poptions table's values are set in step 1, then modified in step 3, and then written to the game in step 4.

One important thing is that you can also read the `poptions` table. Getting the current mod values is extremely helpful because you can use mods to signal the perframe and tell it what to do, instead of just making a formula based on the beat. The `poptions` table lets you see what values of mods the template is about to apply, and tweak them before they are serialized into the game.

### Advanced uses of Perframes.
Here's an example that also reads from `poptions`:
```lua
local sin, cos, pi = math.sin, math.cos, math.pi

-- tell the template that the mod 'blacksphere' isn't real
alias {'blacksphere'}

-- Make a perframe that lasts for the entire file.
func {0, 9e9, function(beat, poptions)
	
	-- For all the players:
	for pn = 1, max_pn do
		
		-- Read the mod 'blacksphere' from the poptions table.
		local b = poptions[pn][blacksphere].blacksphere / 100
		
		-- Calculate the cosine and sine of the percentage that
		-- was applied. Fast calcuation path if set to 0%
		local c = b == 0 and 1 or cos(b * pi)
		local s = b == 0 and 0 or sin(b * pi)
		
		-- Apply mods to the players every frame through poptions
		poptions[pn].invert = poptions[pn].invert + 50 - 50 * c
		poptions[pn].reverse = poptions[pn].reverse + 12.5 * s
		poptions[pn].alternate = poptions[pn].alternate + 25 * s
		
	end
	
	-- defer = true makes this perframe run after others, so other
	-- perframes can act as if there is a mod named 'blacksphere'
end, defer = true}
```
You can also use `mode = 'end'` for `func`.
