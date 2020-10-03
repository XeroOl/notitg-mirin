[Back to main page](..)
# Set
```lua
set {beat, percent, mod}
```
Use the`set`function to set a mod to a specific value at a specific beat in the song.

Arguments:
* `beat: float`: The song beat to apply the
* `percent: float`: The amount of 
* `mod: string`: The mod to apply.
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
