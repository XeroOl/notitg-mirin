# Getting Started
This book is an overview for how to use the Mirin Template, a mods template for the game NotITG. The Mirin Template wraps on top of the low level NotITG Mods API to provide a system to smoothly animate game objects in sync with a song. It will cover all of the features of the Mirin Template with examples. This chapter will describe how to use the template to create a new file, and how to add the template to an existing file. Future chapters will cover how to use the template once you have a file prepared.
## Making a New File
Unzip the template and it should work out of the box. Change the contents of the `.sm` to set the metadata of the song, and replace the audio with your own song.
## Add to an Existing Simfile
Unzip the template into your song's directory. Delete `Song.sm` and `Song.ogg`, and instead modify your `.sm` file so that `FGCHANGES` is set to the following value:
```
//The majority of simfile scripts and visual effects are stored here.
#FGCHANGES:0.000=template/main.xml=1.000=0=0=1=====,
;
```
That's it! You're ready to get started!

Other bits and pieces to shuffle around:

# Lua Functions
Lua code allows control over the behavior of mods and actors in a modfile. In the Mirin Template, Lua code can be inserted into the beginning of the file `lua/mods.xml`. This file is meant to be edited by the user, and contain all of the code specific to one song. The Mirin Template provides a Lua API that allows control of mods, but the user is expected to control the actors directly using NotITG's provided functions.
There are two main lua functions provided by the Mirin Template: `ease` and `func`.