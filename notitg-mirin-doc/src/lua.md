# Lua Functions

Lua code allows you to control the behavior of mods and actors in your modfile. In the Mirin Template, you can write your Lua code in the file `lua/mods.xml`. Look for the comment: `-- your lua code here` to find the location for you to write code. There are three lua functions provided by the Mirin Template: `ease`, `ease_relative`, and `func`.

## Eases

In the Mirin Template, mods are controlled through eases, which are transitions that change the value of mods. Unless otherwise specified, mods will keep the value that was prevously assigned to them. Because of this, if you want a mod to be on for a certain range of time, you need to put two ease transitions; one to turn the mod "on" at the beginning, and one to turn the mod "off" at the end.

### Differences from other Templates

If you're coming from other templates, eases work slightly differently here. In other templates, it is common to see ease systems come with sustain times. This template is different because there are **no sustain times**. The Mirin Template automatically holds mods at the specified values until the next ease transition, which means that you don't have to worry about mods reverting to `0%` without you telling them to. This makes the Mirin Template work more like `.crs` files, and less like templates which rely on the `clearall` mod.

In other templates, there's usually another way to more directly affect the values of mods, known as the mods table. This template differs from other templates in that there is **no mods table**. If you want a mod to transition linearly, you can use the `linear` ease, and if you want a mod to transition instantly, you can use the `instant` ease, or set the length of the transition to `0` beats.

### Transitioning a Mod with the `ease` Function

The basic format for an ease entry is `ease {beat, length, func, percent, 'mod'}`.
For example, to ease `rotationz` to `360%` on beat `5`, you would write:

```lua
ease {5, 1, outCirc, 360, 'rotationz'}
```

Let's break that down:
* The first item, `5`, tells the game which beat to start the transition.
* The second item, `1`, tells the game how many beats the transition will take. A bigger number makes the transition take longer, while a smaller number will make the transition faster. If this number is `0` or negative, the transition will be completed instantly.
* The third item, `outCirc`, tells the game which type of transition to use. Note that this item doesn't have `'` marks. The list of functions you can use as eases is in the [Built-in Eases](./eases.md) section.
* The fourth item, `360`, is the percentage that the mod will end up on.
* The fifth item, `'rotationz'`, tells the game which property to transition. If the property you want to ease is a mod, then you *must* use `'` marks.

Ease lets you put multiple entries in once call.
So, if you want the player to rotate back to `0%`, you would write:

```lua
ease
{5, 1, outCirc, 100, 'invert'}
{6, 1, outCirc, 0, 'invert'}
```

Now, the players rotate back to `0%` on beat `6`. In the example above, there are two listed transitions, but you can actually put as many as you want in a row. One important difference between this format and other templates is that there is no comma after each line. This is because `ease` is a function, not a table.

You can also ease multiple mods on the same line. If the mods you're easing all start at the same beat, last the same amount of time, and use the same transition function, they combine together nicely:

```lua
ease {5, 1, outCirc, 360, 'rotationz', -628, 'confusionoffset'}
```

This code will set `rotationz` to `360` **and** set `confusionoffset` to `-628`, where both the transitions share the same properties.

The `ease` function doesn't just let you put two mods in an entry. In fact, you can add as many mods as you want in one entry:
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

As you can see, the above code changes many mods starting on beat `5`.

### Player Specific Eases
If you've been following along yourself, you should have noticed that all of the above examples affect both the players by default. However, sometimes, you want different mods to be applied to different players. In order to do that, you just need to set a variable called `plr`.

For example, if you want Player 1 to get the `drunk` effect on beat 10, you would write something like this:

```lua
ease {10, 2, outQuad, 100, 'drunk', plr = 1}
```

Now, on beat 10, player 1 will become drunk. The important syntax here is the `plr =` at the end. This tells `ease` to only apply it to Player 1. Of course, if you write `plr = 2`, then it will apply to Player 2 instead.

You can add use this to change any ease transition to target a specific player.

### Advanced Player Specific Eases

Internally within NotITG, there are actually eight players, not just two. Because of this, if you're using more than two players in a file, you might encounter a situation where want to apply eases on more than one player at once, but not all the players. In order to do this, you set `plr` to a table of player numbers.

For example, if you wanted to apply the `drunk` effect to all of the odd-numbered players, you could write:

```lua
ease {10, 2, outQuad, 100, 'drunk', plr = {1, 3, 5, 7}}
```

If you're following along with the template, you'll notice that you can only see Player 1 become drunk. In order to see the effect of this example on the other players, you'd first need to enable Players 3, 5, and 7.

If you want to set the `plr` on many ease transitions in a row, it can get inconvenient pretty quickly. Luckily, there's an easy way to affect multiple ease transitions all at once. You can change the global `plr` before you call to `ease`:
```lua
plr = 1
ease
{10, 2, inExpo, 250, 'movex'}
{10, 2, linear, 100, 'drunk'}

plr = 2
ease
{10, 2, outExpo, -250, 'movex'}
{10, 2, linear, -100, 'drunk'}

-- Putting an inline `plr` overrides the global `plr`
{15, 0, instant, 100, 'flip', plr = 1}

-- Set plr back to normal
plr = nil
```
Now, the effects are applied to their respective players.

By default, without the `plr` global set, the template uses the plr `{1, 2}`, which means that ease transitions without a specified `plr` will affect both the players.

This form is convenient for when there is a helper function that you want to call. For example, if you have a function that runs a specific set of eases:
```lua
local function wiggle_around(beat)
	ease
	{beat, 1, pop, 100, 'drunk'}
	{beat, 1, tap, 100, 'tipsy'}
end
```
Then, you can control which players it affects:
```lua
-- control which player is affected:
plr = 1
wiggle_around(10)

plr = 2
wiggle_around(20)

plr = nil
```
As you can see, the `plr` global isn't just shorthand for putting the `plr` in each line; It is also extremely helpful because you can write helper functions that automatically support being applied to a specific player.

Sometimes, instead of calculating the length of a transition, it is more natural to just mark the start and end beats of the transition. Luckily, there's a way to make `ease` accept end beats instead of lengths. If you add in `mode = 'end'` or `m=e` somewhere in the table, the 2nd number will be treated as an end beat instead of a length.
```lua
ease
-- `mode = 'end'` makes this one last 1 beat instead of 21.
{20, 21, mode = 'end', outCirc, 100, 'invert'}

-- `m=e` is just shorthand for `mode = 'end'`.
-- It has the same effect as in the previous example,
-- which means that this effect lasts from beat 21 to 22.
{21, 22, m=e, outCirc, 0, 'invert'}
```
### Setting the speed mod with `ease`
Usually, when you make a modfile, you want to specify the speed mod that the game runs at. With the Mirin Template, there is a special mod that you can use to change the speed mod: `xmod`. Unlike the other mods, when you use `xmod`, you don't put quotes around the name of the mod:
```lua
-- set the speed mod to 3x
ease {0, 0, instant, 3, xmod}
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

One important thing is that you can also read the `poptions` table. Getting the current mod values is extremely helpful because you can use mods to signal the perframe and tell it what to do, instead of just making a formula based on the beat. The `poptions` table lets you see what values of mods the ease engine is about to apply, and tweak them before they are serialized into the game.

### Advanced uses of Perframes.
Here's an example where I also read from `poptions`:
```lua
local sin, cos, pi = math.sin, math.cos, math.pi

-- Make a perframe that lasts for the entire file.
func {0, 9e9, function(beat, poptions)
	
	-- For all the players:
	for pn = 1, max_pn do
		
		-- Read the mod 'blacksphere' from the poptions table.
		local b = poptions[pn][blacksphere].blacksphere / 100
		
		-- Write back nil to the poptions table so that the game
		-- doesn't actually apply 'blackpshere' as a real mod.
		poptions[pn].blacksphere = nil
		
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