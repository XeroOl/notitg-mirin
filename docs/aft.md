---
title: AFTs | The Mirin Template
---
[Back to main page](..)
# AFT (ActorFrameTexture)

An ActorFrameTexture (AFT) is an Actor which captures the layers beneath it (drawn before it), and puts the result into a texture.

Example of setting up an AFT layer
In your mods.lua:
```lua
	sprite(mysprite) -- set up the sprite
	aft(myaft) -- set up the aft
	mysprite:SetTexture(myaft:GetTexture()) -- set up the texture
```
In your layout.xml:
```xml
<Layer Type = "Sprite" Name = "mysprite" />
<Layer Type = "ActorFrameTexture" Name = "myaft" />
```
From here, try moving / rotating `mysprite`, or place the AFT and Sprite at different positions in the scene.