<html><head><title>Alias | The Mirin Template</title></head></html>

[Back to main page](..)
# Alias
```lua
alias {'oldmodname', 'newmodname'}
```
The `alias` function tells the game to treat two different mod names as the same mod name. The game will internally use the second provided name.

Arguments:

| -------------- | ---------- |
| `oldmodname: string` | The name of the mod to rename. |
| `newmodname: string` | The new name of the mod. |

Example:
```lua
alias {'confusionzoffset', 'confusionoffset'}
```
