<html><head><title>Splines | The Mirin Template</title></head></html>

[Back to main page](..)
# Splines
Splines are a feature of NotITG, and aren't specific to the Mirin Template.

tl;dr - list of points on the playfield (measured in time away from receptors, in beats)
paired up with a list of mod values for those points.

Arrow properties that can be spline'd:
* X
* Y
* Z
* RotationX
* RotationY
* RotationZ
* Size
* Stealth
* Skew

# How to Apply:
Call it on Playfield.

```lua
P1:SetXSpline(
	which,
	column(-1 for all columns),
	mod percentage,
	offset (distance from recep in beats)
	activation speed (set -1 for instant)
)
```

due to the way this is set up, it's easy to apply large amounts of splines using a for loop.
There is a limit of 40 splines per property per column.

# How to Reset all:

Apply mod "spline"..axis.."reset" or "spline"..col..axis.."reset"
(axes are x,y,z,rotx,roty,rotz,size,stealth,skew)

It activates immediately and instantly kills all splines in that column and axis




# Quirks of splines

Holds suck at splining in default ITG.
I made a version of the hold renderer that plays much nicer with splines.
To use, activate the mod "spiralholds".

If you activate 50% flip and 50% reverse, you can have much more direct control of the motion path
of arrows using splines.

splines have multiple different "join" types.
To change the join type, use "spline"..axis.."type", where axis is one of the aforementioned axes.

* splinetype = 0
  * Default, linear splines. Connected with straight lines.
* splinetype > 0 && splinetype < 100
  * Cosine connected splines.
* splinetype > 100
  * Cubic splines (bezier joining the points. useful for smooth links using few points.)

Certain things will cause splines to truncate (the rest will be ignored after a point)