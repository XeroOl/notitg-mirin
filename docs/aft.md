---
title: AFTs | The Mirin Template
---
[Back to main page](..)
# AFT (ActorFrameTexture)

ActorFrameTexture (AFT) is an Actor which captures the layers beneath it (drawn before it), and puts the result into a texture.

Example of setting up an AFT layer:
```xml
<Mods LoadCommand = "%xero(function(self)
	-- judgment / combo proxies
	for pn = 1, 2 do
		setupJudgeProxy(PJ[pn], P[pn]:GetChild('Judgment'), pn)
		setupJudgeProxy(PC[pn], P[pn]:GetChild('Combo'), pn)
	end
	-- player proxies
	for pn = 1, #PP do
		PP[pn]:SetTarget(P[pn])
		P[pn]:hidden(1)
	end
	-- your code goes here here:
	sprite(mysprite) -- set up the sprite
	aft(myaft) -- set up the aft
	mysprite:SetTexture(myaft:GetTexture()) -- set up the texture
	
end)"
Type = "ActorFrame"
><children>
	<Layer Type = "Sprite" Name = "mysprite" />
	<Layer Type = "ActorProxy" Name = "PC[1]" />
	<Layer Type = "ActorProxy" Name = "PC[2]" />
	<Layer Type = "ActorProxy" Name = "PJ[1]" />
	<Layer Type = "ActorProxy" Name = "PJ[2]" />
	<Layer Type = "ActorProxy" Name = "PP[1]" />
	<Layer Type = "ActorProxy" Name = "PP[2]" />
	<Layer Type = "ActorFrameTexture" Name = "myaft" />
</children></Mods>
```
From here, try moving / rotating `mysprite`, or place the AFT and Sprite at different positions in the scene.