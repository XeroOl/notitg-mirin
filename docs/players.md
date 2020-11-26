[Back to main page](..)
# Player Specific Mods
* This section is not done. Ask for @XeroOl in the (NotITG Discord)[https://uksrt.heysora.net/discord].
`set`, `ease`, and `add` all can take in an optional argument called `plr`.
It can be passed in by setting a global, or by adding a key to the table. If `plr` is a number, then the mods will only apply to the specified player. If `plr` is a table, then the mods will only apply to the specified players. If not provided, `plr` will default to `{1, 2}`, which means that mods affect both players by default.

Examples:
```lua
-- ease only player 1 to 100% invert
ease {0, 1, outExpo, 100, 'invert', plr = 1}

-- ease only player 2 to -100% invert
ease {0, 1, outExpo, -100, 'invert', plr = 2}

-- run a batch of eases using plr as a global, and reset plr when done.
plr = 1
ease {1, 2, outExpo, 100, 'reverse0'}
ease {2, 2, outExpo, 100, 'reverse1'}
ease {3, 2, outExpo, 100, 'reverse2'}
ease {4, 2, outExpo, 100, 'reverse3'}
plr = nil


-- use a table plr to specify multiple players at once
ease {10, 2, outExpo, 100, 'drunk', plr = {1, 3, 5}}
```

# Extra Players
## How to enable extra players
Although the game only goes up to 2 players, NotITG internally has 8 players. By default, these players are hidden, and in a special sleeping mode. To turn them on, run the `SetAwake` method, and pass in `true`. They can be disabled again with `SetAwake(false)`.

Example:
```lua
-- awaken P3
P3:SetAwake(true)
-- show P3
P3:hidden(0)
```

## How to set up extra player proxies
I'm too lazy to actually look at mods.xml and figure out how it works, so do it yourself, thanks in advance.
