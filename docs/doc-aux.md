[Back to main page](..)
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

`node` creates a function that transforms the values of mods before they are applied every frame.
node creates a function that takes in mod values and outputs mod values.

| -------------- | ---------- |
| `modname: 1 or more strings` | The mods to take as input to the function |
| `function: modnames => void or modname_out` | The function to run. |
| `modname_out (optional): 0 or more strings` | The name of the mods to write back to. |

<br>
## Examples
Node is a very general function that can be used in different ways. These examples explore some of the ways in which node can be used.
<br><br>
### Blacksphere
This example shows how to create a `'blacksphere'` mod with `node`.

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
Firstly, the `aux` function marks the mod `'blacksphere'` as an auxiliary mod. Then, the `node` function reads the value stored in `'blacksphere'`, and calculates and returns the amount of `'invert'`, `'alternate'`, and `'reverse'` to apply.

Then, the `'blacksphere'` auxiliary mod can be used:
```lua
ease {0, 1, outExpo, 180, 'blacksphere'}
ease {4, 1, outExpo, 0, 'blacksphere'}
```
Although `'blacksphere'` uses `'invert'`, `'alternate'`, and `'reverse'`, those mods can still be used.
```lua
ease {0, 10, linear, 360, 'blacksphere', 100, 'reverse'}
```
<br><br>
### Rotate BG
`node` can be used to bind properties of actors to auxiliary mods. In this example, the mod `'rotatebg'` is is set up to control the angle of an actor.
```lua
-- In the Lua
aux {'rotatebg'}
node {'rotatebg', function(p)
    my_bg_actor:rotationz(p)
end}

-- In the XML
<Layer Name = "my_bg_actor" File = "my_background_file.png">
```
Then, the `'rotatebg'` mod controls the rotation of the actor.
<br><br>
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
<br><br>
### Superpowered Counter Rotation
Here's an example of how powerful `node` can be:
This node makes the confusionoffset mods be independent of the rotation mods.
```lua
alias {'confusionzoffset', 'confusionoffset'}
local sin, cos = math.sin, math.cos
local asin, atan2 = math.asin, math.atan2
local pi = math.pi
node {
    'rotationx', 'rotationy', 'rotationz',
    'confusionxoffset', 'confusionyoffset', 'confusionoffset',
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
    'confusionxoffset', 'confusionyoffset', 'confusionoffset',
}
```
<br><br>
