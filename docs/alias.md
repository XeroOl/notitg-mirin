[Back to main page](..)
# Alias
```lua
alias {help I don't remember the args'}
```
The `alias` function tells the game to treat two different mod names as the same mod name. The game will internally use the second provided name. Run the `alias` function before you use the alias.

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