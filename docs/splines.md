---
title: Splines | The Mirin Template
---
[Back to main page](..)
# Splines
Splines are a list of points on each column of each player (measured in time away from receptors, in beats), that are paired up with a list of mod values for those points. These are a feature of NotITG and aren't specific to the Mirin Template.

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
Call it on a player as follows:

```lua
P1:SetXSpline(
	point #, 
	column, --(-1 for all columns)
	mod percentage, 
	offset, --(distance from receptors in beats)
	activation speed --(set -1 for instant)
)
```
For activation speed, it's just 1 divided by the amount of time you want it to take in seconds. So 1 second would be 100, 2 seconds would be 50, and half a second would be 200.

Due to the way this is set up, it's easy to apply large amounts of splines using a `for` loop. 
Note that there is a limit of 40 splines, per property, per column. Setting more will not do anything.

# How to Reset all
Call the method "Reset"..`axis`.."Spline(`col`)" on a player, "axis" being one of the aforementioned axes, and "col" being the column number. Put it inside a `func` to control what beat it gets applied on.
Examples:
```lua
--resets X splines on the 'up' column
func{4, function()
	P1:ResetXSplines(2)
	P2:ResetXSplines(2)
end}

--resets X splines on the 'up' column
func{4, function()
	for col = 0, 3 do 
		P1:ResetXSplines(col)
		P2:ResetXSplines(col)
	end
end}
```
(See also: [for loops](for.md) and [funcs](func.md))

It activates immediately and instantly resets all splines in that column and axis.

Alternatively, you can apply the mod "spline"..`axis`.."reset" or "spline"..`col`..`axis`.."reset", but it *may* mess up your splines when playing your file in edit mode, due to persisting. (The axes are `x`, `y`, `z`, `rotx`, `roty`, `rotz`, `size`, `stealth`, and `skew`, case-insensitive).

# Quirks of splines

* Holds suck at splining in default ITG. 
Taro made a version of the hold renderer that plays much nicer with splines. 
To use, activate the mod `spiralholds` (at 100%).

* If you activate 50% `flip` and 50% `reverse`, you can have much more direct control of the motion path of arrows using splines, since .

* Splines have multiple different "join" types. 
To change the join type, use `spline..axis..type`, where `axis` is one of the aforementioned axes. 

  * `splinetype` = 0
    * Default, linear splines. Connected with straight lines.
  * `splinetype` > 0 and `splinetype` < 100
    * Cosine connected splines.
  * `splinetype` > 100
    * Cubic splines (Bézier joining the points. Useful for smooth links using few points.)

* Certain things will cause splines to truncate (the rest will be ignored after a point).

* In XYZ mod percentage property, 100% is equal to ARROW_SIZE, which is 64 pixels by default in ITG.
    In RotationX, Y and Z, 628.3% is equal to 360 degrees (2*math.pi*100)
    Size uses the same formulae as Mini and Tiny (200% = 0 zoom)
    Stealth is just stealth
    Trying to get precise values using skew is like trying to count powder.