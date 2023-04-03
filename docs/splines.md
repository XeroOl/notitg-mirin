---
title: Splines | The Mirin Template
---
[Back to main page](..)
# Splines
Splines are a feature of NotITG, and aren't specific to the Mirin Template.

tl;dr - list of points on the playfield (measured in time away from receptors, in beats)
paired up with a list of mod values for those points.

Arrow properties/axes that can be spline'd:
* X
* Y
* Z
* RotationX
* RotationY
* RotationZ
* Size
* Stealth
* Skew

# How to Apply
Call it on a playfield as follows:

```lua
P1:SetXSpline(
	which,
	column, --(-1 for all columns)
	mod percentage,
	offset, --(distance from receptors in beats)
	activation speed --(set -1 for instant; measured in rates)
)
```
For activation speed, it's measured in rates, which is just 1 divided by the amount of time you want it to take in seconds. So 1 second would be 100, 2 seconds would be 50, and half a second would be 200.

Due to the way this is set up, it's easy to apply large amounts of splines using a `for` loop. 
Note that there is a limit of 40 splines, per property, per column. Setting more will not do anything.

# How to Reset all
Call the method `Reset..axis..Spline(col)` on a playfield, "axis" being one of the aforementioned axes, and "col" being the column number. Put it inside a `func` to control what beat it gets applied on.
Examples:
```lua
--resets X splines on the 'up' column
func{4, function()
	P1:ResetXSplines(2)
	P2:ResetXSplines(2)
end}

--resets X splines on the 'up' column
func{4, function()
	for i = 0, 3, 1 do 
		P1:ResetXSplines(i)
		P2:ResetXSplines(i)
	end
end}
```
(See also: [for loops](for.md) and [funcs](func.md))

It activates immediately and instantly kills all splines in that column and axis.

Alternatively, you can apply the mod `spline..axis..reset` or `spline..col..axis..reset`, but it *may* mess up your splines when playing your file in edit mode, due to persisting. (The axes are `x`, `y`, `z`, `rotx`, `roty`, `rotz`, `size`, `stealth`, and `skew`, case-insensitive).

# Quirks of splines

Holds suck at splining in default ITG. 
XeroOl made a version of the hold renderer that plays much nicer with splines. 
To use, activate the mod `spiralholds` (at 100%).

If you activate 50% `flip` and 50% `reverse`, you can have much more direct control of the motion path of arrows using splines.

Splines have multiple different "join" types. 
To change the join type, use `spline..axis..type`, where `axis` is one of the aforementioned axes. 

* splinetype = 0
  * Default, linear splines. Connected with straight lines.
* splinetype > 0 && splinetype < 100
  * Cosine connected splines.
* splinetype > 100
  * Cubic splines (Bézier joining the points. Useful for smooth links using few points.)

Certain things will cause splines to truncate (the rest will be ignored after a point).