[Back to main page](..)
# AFT (ActorFrameTexture)

ActorFrameTexture (AFT) is an Actor which captures the layers beneath it (drawn before it), and puts the result into a texture.

Example of setting up an AFT layer:
```xml
<Layer Type = "ActorFrameTexture" Name = "my_aft" />
```

Example of setting up an AFT sprite:
```xml
<Layer Type = "Sprite" Name = "my_sprite" />
```

Example of setting the texture for the AFT layer (This part goes into the lua part of the template):
```lua
aft(my_aft) -- set up the aft
sprite(my_sprite) -- set up the sprite
my_sprite:SetTexture(my_aft:GetTexture()) -- set up the texture
```

Side note, depending on the sequence on setting the AFTs, it will give different results.

Example of setting up an aft sprite behind the aft layer:
```xml
<Layer Type = "Sprite" Name = "my_sprite" />
<Layer Type = "ActorFrameTexture" Name = "my_aft" />
```

TODO: add a screenshot for this. ^

Example of setting up an aft sprite in front the aft layer:
```xml
<Layer Type = "ActorFrameTexture" Name = "my_aft" />
<Layer Type = "Sprite" Name = "my_sprite" />
```

TODO: add a screenshot for this. ^