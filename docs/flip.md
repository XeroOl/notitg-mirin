<head><title>Flip | The Mirin Template</title></head>

[Back to main page](..)
# Flip
```lua
flip(eas)
```
The flip function takes in an ease and returns a flipped version of that ease.

Example usage:
```lua
ease {4, 1, flip(outExpo), -200, 'tiny'}
```
```lua
ease {8, 1, flip(outBounce), -50, 'flip'}
```
