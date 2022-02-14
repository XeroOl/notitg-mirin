[Back to main page](..)
# Func
```lua
-- Scheduled Function:
func {beat, function(b)}
-- Perframe:
func {beat, len, function(b, poptions)}
-- Function Eases:
func {beat, len, ease_fn, function(p)}
func {beat, len, ease_fn, percent, function(p)}
func {beat, len, ease_fn, begin_percent, end_percent, function(p)}
func {beat, len, ease_fn, percent, 'actor:method'}
func {beat, len, ease_fn, begin_percent, end_percent, 'actor:method'}
```
The `func` function is used to run lua functions at certain beats in the song. `func` can be used to run a function once, or run a function at every frame in a range of beats.

## `func` for Scheduled Functions
Arguments:

| -------------- | ----------                                  |
| `beat: number` | The song beat when the function should run. |
| `fn: function` | The function to run.                        |

The given function will run at the given beat.

Example:

```lua
-- writes 'hello world' to screen on beat 64
func {64, function()
	SCREENMAN:SystemMessage('hello world')
end}

-- hides P1 on beat 32
func {32, function()
	P1:hidden(1)
end}
```

## `perframe` for Per-frames
Arguments:

| -------------- | ----------                                                 |
| `beat: number` | The song beat when the function should begin being called. |
| `len: number`  | The length of beats when the function should be called.    |
| `fn: function` | The function to run every frame in the range.              |

The given function will be called every frame within the range. This is the only variant that supports [poptions](#poptions).

## `func_ease` for Function Eases
Arguments:

| --------------            | ----------                                                   |
| `beat: number`            | The song beat when the function should begin being called.   |
| `len: number`             | The length of beats when the function should be called.      |
| `ease_fn: function`       | The ease to use.                                             |
| `start_percent?: number`  | The starting value to pass to the function, or 0 by default. |
| `target_percent?: number` | The final value to pass to the function, or 1 by default.    |
| `fn: function or string`  | The function to run for every frame of the effect.           |

The given function will get called repeated. The function will recieve a number, `p`, which represents the progress though the effect.
These act a lot like eases, except it runs with

```lua
func_ease {0, 4, outExpo, 360, 0, function(p)
	P1:rotationz(p)
end}
```

### Shorthand
For functions that are just a single method call, like the example shown above, the function definition can be replaced with a string that represents the name of the method. This string has to be: the name of an actor (matches the `Name=` of the actor or the name of the global the actor is in), a `:` character, and then the name of the method. The string will be compiled into a function. This only works for methods that accept a single float parameter.

```lua
-- equivalent to the above example
func_ease {0, 4, outExpo, 360, 0, 'P1:rotationz'}
```

This shorthand only works for actors that are global, and only works if there's only one method to be called. In all other cases, instead of using the shorthand, use the full syntax instead.

## Persist
When previewing mods in the editor, the template has to fast forward to the selected beat. The "persist" is the behavior of a func when being processed during this "fast forward" phase. The persist also applies during large lag spikes, or other times where the template needs to skip over an effect instead of actually playing it. Persist can be set by using the `persist` optional parameter. If `persist` is set to true, then the function will always be called at/after the specified beat. If `persist` is set to `false`, then the func will be called at the specified beat, but skipped if the song is started past the specified beat. If `persist` is a number, then the effect will persist for that number of beats. This means that if the game "ticks" within that many beats of the specified beat, the function will be called on that beat. If not specified, the persist will be true. Persist can be specified for the Scheduled Function and Function Ease variants of `func`, but not for raw perframes.
 
Example:
```lua
-- flashes the screen at beat 10, but doesn't flash the screen if the file is previewed past beat 10.
-- note: this doesn't work on its own. It's implied that there's also a 'screencover' actor.
func {10, function()
	screencover:diffusealpha(1)
	screencover:linear(1)
	screencover:diffusealpha(0)
end, persist = false}
```


## Poptions
`poptions` is an undocumented feature that lets you read and write to the current values of of mods. It can be used instead of NotITG's internal `GAMESTATE:ApplyModifiers` function.

For example: `GAMESTATE:ApplyModifiers('*-1 100 invert')` can be replaced with
```lua
for pn = 1, 2 do
	poptions[pn].invert = 100
end
```
