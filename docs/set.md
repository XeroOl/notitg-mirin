[Back to main page](..)
# Set
```lua
set {beat, percent, mod}
```
Use the `set` function to set a mod to a specific value at a specific beat in the song.

Arguments:

| -------------- | ---------- |
| `beat: float` | The song beat when the mod applies. |
| `percent: float` | The target amount to set the mod to. |
| `mod: string` | The mod to apply. |

Examples:
```lua
set {0, 1.5, 'xmod'}
set {10, 100, 'invert'}
```

The `set` function can also take more than one percent/mod at a time.
```lua
set {
	1, -- the song beat
	100, 'invert',
	100, 'drunk',
	100, 'bumpy',
}
```
Set can also be [player specific](players.md).
