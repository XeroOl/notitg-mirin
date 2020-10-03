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
-- TODO add node for reverse rotation
```
