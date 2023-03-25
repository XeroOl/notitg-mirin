<head><title>Eases | The Mirin Template</title></head>

[Back to main page](..)
# Ease
```lua
ease {beat, len, ease_fn, percent, mod}
```
Use the `ease` function to animate a mod to a specific value at a specific beat in the song.
The animation lasts `len` beats, and animates using the selected `ease_fn`.

Arguments:

| -------------- | ---------- |
| `beat: number` | The song beat when the mod begins to apply. |
| `len: number` | The amount of beats before the ease is complete. |
| [`ease_fn: function`](eases.md) | The way to approach the target value. |
| `percent: number` | The target amount to set the mod to. |
| `mod: string` | The mod to apply. |

Examples:
```lua
ease {0, 1, outExpo, 100, 'invert'}
ease {0, 2, outBack, 100, 'movex'}
```

The `ease` function can also take more than one percent/mod at a time.
```lua
ease {
	0, 2, inCubic,
	100, 'invert',
	100, 'drunk',
	100, 'bumpy',
}
```
`ease` can also be [player specific](players.md).

# Add
```lua
add {beat, len, ease_fn, relative_percent, mod}
```
The `add` function works like `ease`, except it is relative. The `add` function will add to the old value of the mod instead of overriding the old value of the mod with a new value. So, for example, if a mod is currently at `200`, and an `add` runs with the value of `100`, the result would be `300`.

Arguments:

| -------------- | ---------- |
| `beat: number` | The song beat when the mod begins to apply. |
| `len: number` | The amount of beats before the ease is complete. |
| [`ease_fn: function`](eases.md) | The way to approach the target value. |
| `percent: number` | The amount to add to the mod. |
| `mod: string` | The mod to apply. |

Example:
```lua
add {1, 2, inExpo, 360, 'rotationz'}
```

`add` can also be [player specific](players.md).
