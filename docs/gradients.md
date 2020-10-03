[Back to main page](..)
# Gradients
Gradients are a feature of NotITG, and aren't specific to the Mirin Template.

## Set Num Points
```lua
Player:SetNumPathGradientPoints(column,amount)
Player:SetNumArrowGradientPoints(column,amount)
Player:SetNumStealthGradientPoints(column,amount)
```
These tell the game how many points/stops there are in the gradient. (Much like Photoshop gradients where you can set a color at each point)

## Set Gradient Points
```lua
Player:SetPathGradientPoint(point,column,where)
Player:SetArrowGradientPoint(point,column,where)
Player:SetStealthGradientPoint(point,column,where)
```
These position those points on the column provided. (1 = 1 arrow -or- 64 pixels)

### Example:
```lua
P1:SetArrowGradientPoint(0,0,1)
-- This would set the first point in the gradient 1 arrow (64 pixels) down from the receptors on column 0, which is the left column, on Player 1
-- Keep in mind that column and point numbers start at 0 and not 1. (I'm looking at you, Lua.)
```

## Set Gradient Color
```lua
Player:SetPathGradientColor(point,column,r,g,b,a)
Player:SetArrowGradientColor(point,column,r,g,b,a)
Player:SetStealthGradientColor(point,column,r,g,b,a)
```
These will set the color of the point provided.
### Example:
```lua
P1:SetArrowGradientColor(0,2,1,0,0,1)
P1:SetArrowGradientColor(1,2,0,1,0,1)
P1:SetArrowGradientColor(2,2,0,0,1,1)
P1:SetArrowGradientColor(3,2,1,1,1,0)
-- This arrow gradient has 4 points in it starting from 0. Point 0 will be colored Red,
-- then point 1 will be colored Green, then point 2 will 
-- be colored Blue, and the final point will be a fade on the alpha channel
```

## Example
To put it all together, here is some example code...
```lua
for pn = 1,2 do -- first, we run a loop so we can grab players 1 and 2
	local a = Plr(pn) -- grab the players here with this function (a means both players in this context)
	if a then -- if they exist do a thing
		for col = 0,3 do -- iterate through all the columns
			a:SetNumArrowGradientPoints(col,4)	-- for each column, set the number of points to 4

			a:SetArrowGradientPoint(0,col,1) -- set their points
			a:SetArrowGradientPoint(1,col,2)
			a:SetArrowGradientPoint(2,col,3)
			a:SetArrowGradientPoint(3,col,4)

			a:SetArrowGradientColor(0,col,1,0,0,1)	-- set their colors and shiet
			a:SetArrowGradientColor(1,col,0,1,0,1)
			a:SetArrowGradientColor(2,col,0,0,1,1)
		end
	end
end
```
You can swap out "Arrow" with "Path" so it affects the arrowpaths or "Stealth" so it only affects the notes when
stealth is applied
And there you go! You can now gradient!
