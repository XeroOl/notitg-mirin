# Appendix
## Appendix A: Functions
```lua
ease {beat, len [, mode = 'end'], fn, percent1, mod1 [, percent2, mod2 ...] [, plr = pn]}

add {beat, len [, mode = 'end'], fn, percent1, mod1 [, percent2, mod2 ...] [, plr = pn]}

set {beat, percent1, mod1 [, percent2, mod2 ...] [, plr = pn]}

func {beat [, len [, mode = 'end']], function(beat, poptions) ... end [, defer = true]}

alias {name [, value]}
alias (name [, value])
```
## Appendix B: AFT Setup
```xml
<Layer InitCommand = "%xero.sprite" Name = "aftsprite" Type="Sprite" />
<Layer InitCommand = "%xero.aft" Name = "aft" Type="ActorFrameTexture" />
```
```lua
aftsprite:SetTexture(aft:GetTexture())
```
