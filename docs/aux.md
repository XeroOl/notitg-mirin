# Aux
```lua
aux {modname}
```
The `aux` function creates an auxiliary mod. The template will keep track of the value of the mod, but will not apply it to the players.

Arguments:

| -------------- | ---------- |
| `modname: string` | The name of the mod to create. |

Examples:
```lua
aux {'blacksphere'}
aux {'my_mod_1'}
```

The `aux` function can also take more than one modname.

```lua
aux {'mod1', 'mod2', 'mod3'}
```

# Node
```lua
node {modname, function(p)
	-- code
end}

-- alternatively
node {
	modname,
	function(p)
		-- code
		return k
	end,
	modname_out
}
```
Oh boy, welcome to node. This is probably the most complicated function in the Mirin Template, but it is also the most powerful.


| -------------- | ---------- |
| `modname: 1 or more strings` | The mods to take as input to the function |
| `function: modnames => void or modname_out` | The function to run. |
| `modname_out (optional): 0 or more strings` | The name of the mods to write back to. |


### Blacksphere
This example shows how to encode the "blacksphere" effect into a node.
```lua
aux {'blacksphere'}
node {
	'blacksphere',
	function(blacksphere)
		local invert = 50 - 50 * math.cos(blacksphere * math.pi / 180)
		local alternate = 25 * math.sin(blacksphere * math.pi / 180)
		local reverse = -12.5 * math.sin(blacksphere * math.pi / 180)
		return invert, alternate, reverse
	end,
	'invert', 'alternate', 'reverse',
}
```
Firstly, the `aux` function marks the mod `blacksphere` as an auxiliary mod. Then, the `node` function reads that mod, calculates the amount of `invert`, `alternate`, and `reverse` to apply, and applies them by returning them from the node.

Then, the `blacksphere` auxiliary mod can be used:
```lua
ease {0, 1, outExpo, 180, 'blacksphere'}
ease {4, 1, outExpo, 0, 'blacksphere'}
```


### Tornado scaled by Flip
If a node reads and writes to the same mod, then that mod is overwritten instead of added.
```lua
node {
	'flip', 'tornado',
	function(flip, tornado)
		return (1 - flip * 0.02) * tornado
	end,
	'tornado',
}
```


### Superpowered Counter Rotation
Here's an example of how powerful `node` can be:
This node makes the confusionoffset mods be independent of the rotation mods.
```lua
local sin, cos, atan2, asin, pi = math.sin, math.cos, math.atan2, math.asin, math.pi
node {
	'rotationx', 'rotationy', 'rotationz', 'confusionxoffset', 'confusionyoffset', 'confusionzoffset',
	function(rx, ry, rz, cx, cy, cz)
		-- transform axes
		rx, rz = rz, rx
		cx, cz = cz, cx
		
		-- helpers for r
		local rcosx, rcosy, rcosz, rsinx, rsiny, rsinz =
			cos(rx / 360 * pi), cos(ry / 360 * pi), cos(rz / 360 * pi),
			sin(rx / 360 * pi), sin(ry / 360 * pi), sin(rz / 360 * pi)
		
		-- r to quaternion
		local ra, rb, rc, rd =
			rcosx*rcosy*rcosz-rsinx*rsiny*rsinz,
			rsinx*rsiny*rcosz+rcosx*rcosy*rsinz,
			rsinx*rcosy*rcosz+rcosx*rsiny*rsinz,
			rcosx*rsiny*rcosz-rsinx*rcosy*rsinz
		
		-- helpers for c
		local ccosx, ccosy, ccosz, csinx, csiny, csinz =
			cos(cx/200), cos(cy/200), cos(cz/200),
			sin(cx/200), sin(cy/200), sin(cz/200)
		
		-- c to quaternion
		local ca, cb, cc, cd =
			ccosx*ccosy*ccosz-csinx*csiny*csinz,
			csinx*csiny*ccosz+ccosx*ccosy*csinz,
			csinx*ccosy*ccosz+ccosx*csiny*csinz,
			ccosx*csiny*ccosz-csinx*ccosy*csinz
		
		-- o = c * inverse(r)
		local oa, ob, oc, od =
			ca*ra+cb*rb+cc*rc+cd*rd,
			-ca*rb+cb*ra-cc*rd+cd*rc,
			-ca*rc+cb*rd+cc*ra-cd*rb,
			-ca*rd-cb*rc+cc*rb+cd*ra
		
		-- o to euler angles
		local ox, oy, oz =
			100 * atan2(2*oc*oa-2*ob*od, 1-2*oc*oc-2*od*od),
			100 * asin(2*ob*oc+2*od*oa),
			100 * atan2(2*ob*oa-2*oc*od, 1-2*ob*ob-2*od*od)
		
		-- transform axes
		ox, oz = oz, ox
		return ox, oy, oz
	end,
	'confusionxoffset', 'confusionyoffset', 'confusionzoffset',
}
```
