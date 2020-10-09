[Back to main page](..)
# Func
```lua
func {beat, function(b)}
func {beat, len, function(b, poptions)}
func {beat, len, ease_fn, function(p)}
func {beat, len, ease_fn, percent, function(p)}
func {beat, len, ease_fn, begin_percent, end_percent, function(p)}
```
This doc is incomplete because XeroOl is still considering changing this to merge some of these forms in with [`ease`](ease.md).

Form 1, 3, 4, and 5 have persist, but form 2 doesn't.


`poptions` is an undocumented feature that lets you read and write to the current values of of mods. It can be used instead of NotITG's internal `GAMESTATE:ApplyModifiers` function.

For example: `GAMESTATE:ApplyModifiers('*-1 100 invert')` can be replaced with
```lua
for pn = 1, 2 do
	poptions[pn].invert = 100
end
```

the last 3 forms are essentially exschwasion function eases, but with persist, because it should have persist.