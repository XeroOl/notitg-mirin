# Appendix
## Appendix A: Functions
```lua

ease {beat, len [, mode = 'end'], fn, percent1, mod1 [, percent2, mod2 ...] [, plr = pn]}

add {beat, len [, mode = 'end'], fn, percent1, mod1 [, percent2, mod2 ...] [, plr = pn]}

func {beat [, len [, mode = 'end']], function(beat, poptions) ... end [, defer = true]}

```
## Appendix B: AFT Setup
```xml
<Layer InitCommand = "%xero.sprite" Name = "aftsprite" />
<Layer InitCommand = "%xero.aft" Name = "aft" />
```
```lua
aftsprite:SetTexture(aft:GetTexture())
```