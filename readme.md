# Mirin Template
[![busted](https://github.com/XeroOl/notitg-mirin/actions/workflows/tests.yml/badge.svg)](https://github.com/XeroOl/notitg-mirin/actions/workflows/tests.yml)
![luacov](https://raw.githubusercontent.com/XeroOl/notitg-mirin/badges/coverage.svg)

[NotITG](https://notitg.heysora.net) is a fork of OpenITG designed to make it easier for mod file creators to implement their ideas. The [Mirin Template](https://www.github.com/XeroOl/notitg-mirin) provides functions that allow creators to use NotITG express their mod ideas and bring them to life in the game.

* **Simple to learn**: Designed with a goal of avoiding unintuitive edge cases in NotITG.
* **Excellent performance**: Optimized code runs quickly compareed to other templates.
* **Theme independent**: Mirin Template creates a separate environment for mod code that is kept separate from themes.
* **Powerful abstractions**: Includes a powerful system that allows users to create custom modifiers.

```lua
-- turn on invert
ease {0, 1, outExpo, 100, 'invert'}
-- turn off invert
ease {7, 1, outExpo, 0, 'invert'}
```
Read the documentation at https://xerool.github.io/notitg-mirin
