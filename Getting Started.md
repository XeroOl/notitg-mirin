[Back](index.md)
# Getting Started
This document will walk you through how to begin modding using the Mirin Template.

Table of Contents
1. [Install NotITG](#install-notitg)
2. [Download the Template](#download-the-template)
3. [Setting up the Song and .sm](#song-setup)
4. [Check your work](#check-your-work)
5. [Default Mods](#default-mods)
6. [Setting Mods](#setting-mods)
7. [Smooth Transitions](smooth-transitions)
8. [Conclusion](#conclusion)

<a name="install-notitg"/>
## Install NotITG
If you already have the game, you can skip this step.
If you don't have NotITG already, you can install NotITG from [notitg.heysora.net](https://notitg.heysora.net).
Download the full setup, unzip it, and then make a shortcut to the `NotITG` executable.
If everything went right, you should be able to start up the game by running the `NotITG.exe` file in the `Program/` folder.

<a name="download-the-template"/>
## Download the Template
To start, you need to find the folder that NotITG is installed in.
Download the [Mirin Template Code from GitHub](https://github.com/XeroOl/notitg-mirin/releases/download/v5.0.0/mirin-template-5.0.0.zip) and unzip it into a song pack in your `Songs` folder.
When you're done, the structure should be something like this (except `My Song Pack` would be filled in with whatever information you want):
```
NotITG
└── Songs
    └── My Song Pack
        └── notitg-mirin-master
            ├── lua
            ├── readme.md
            ├── Song.ogg
            ├── Song.sm
            └── template
```

Now, if everything went right, you can launch the game and find the "Mirin Template" song in the song wheel.

<a name="song-setup"/>
## Setting up the Song and .sm
You probably don't want to make mods for the provided `Song.sm` and `Song.ogg`, so you can use your own.

### Using an existing simfile
If you already have a `.sm` and audio file you want to use, you can delete the provided `Song.sm` and `Song.ogg`, and use your own file.
Inside your `.sm`, you need to set `#FGCHANGES:` to the following:
```
#FGCHANGES:-10.000=template/main.xml=1.000=0=0=1=====,
;
```
Now you're ready to [move on to modding](#Default Mods).

### Adapting the provided Song.sm
First, convert your song into the `ogg` audio format, and replace the `Song.ogg` file with your own.
Next, open `Song.sm` in a text editor. I recommend using the Notepad++ editor, but any text editor works. With Notepad++, you can right click on the file, and choose "Open With Notepad++".
Inside, there are a couple of things to change:
* `#TITLE:` should be changed from "Mirin Template" to the name of your song
* `#ARTIST:` should be changed to the artist
* `#OFFSET:` needs to be set to the offset of your song
* `#BPMS:` needs to be set to `0.000=`, and then the BPM of your song. (The provided Song.ogg is 129.948bpm)
* On line 32 of `Song.sm`, there's a line that just has a `:` symbol. Add your username before this colon
* On line 34 of `Song.sm`, there's a line that has `1:`. Replace that with the difficulty rating of your file.

NOTE: Only edit the `.sm` while the game is closed. To make the game reload changes to the `.sm` file, you need to delete the `Cache` folder before re-opening the game.
After you've put all of the metadata into the `.sm`, you'll need to replace the default provided chart by writing your own chart. I'm not going to cover how to do this here.

<a name="check-your-work"/>
## Check your work
Before you go any further, you'll want to check that things are prepared correctly.
Here's what to do:
1. Open up NotITG, and then find your song in the song wheel.
2. Play the song. If the template is loaded, you should see the theming elements dissappear at the beginning of the song. (If the lifebar and score and stuff is still there, something's wrong)

If that works, you're finally ready to start modding!

<a name="default-mods"/>
## Default Mods
In NotITG:
1. Go to Edit Mode
2. Select Group
3. Select Song
4. Select Steps (usually Expert steps)
5. Choose "Edit Existing"

This is the editor view. Use the arrow keys to scroll through the chart. You can use the space bar to select the bounds on a range, and then use the `p` key to play the song at that range. 
Turn off the measure lines in `Esc>Preferences>Show Measure Lines`.

Open up `lua/mods.lua` in the text editor.
Under the line `-- your code goes here here:`, add this:
```lua
setdefault {2, 'xmod', 100, 'overhead', 100, 'dizzyholds', 100, 'modtimer'}
```
This sets the rate to `2x`, sets the perpective to overhead, and does a couple of other things.
The `setdefault` function takes in pairs of numbers and mods, and sets the mod to that amount.
More information about `setdefault` can be found on [its documentation page](docs/setdefault.md).

<a name="setting-mods"/>
## Setting Mods
Now that you've set some base mods, you can now schedule mods to change at different beats of the song. To do that, you can use the [set function](docs/set.md).
The `set` function works just like `setdefault`, except for an extra beat number at the beginning.
Try choosing a mod from [the list](docs/mods.md), and applying it with set.
Here's an example that turns `invert` on at beat 4, and turns it back off at beat 8.
```lua
-- on beat 4, set 100% invert
set {4, 100, 'invert'}

-- on beat 8, set 0% invert
set {8, 0, 'invert'}
```
This example used invert, but `set` works with any mod. You can try changing out `invert` for another mod from [the list](docs/mods.md), or find more information can be found on [set's documentation page](docs/set.md).

<a name="smooth-transitions"/>
## Smooth Transitions
If you tried the previous example, you'll notice that there's no animations; the mods instantly turn on and off. Sometimes that's okay, but lots of the time, you'll want to choose an animation to use.
That's where the [ease function](docs/ease.md) comes in.
The ease function works like set, except it needs two more arguments: a length, and an ease function.
```lua
-- ease {beat, length, ease, percent, mod}
```
Here's an example that that turns `invert` on at beat 12, and turns it back off at beat 16 smoothly.
```lua
-- on beat 12, for 2 beats, use the `outExpo` animation to set 100% invert
ease {12, 2, outExpo, 100, 'invert'}

-- on beat 16, for 2 beats, use the `outExpo` animation to set 0% invert
ease {16, 2, outExpo, 0, 'invert'}
```
This example used a length of `2`, and the `outExpo` ease, but you can try changing the ease to another one from [the ease list](docs/eases.md), and you can change the length.
You can find more information about `ease` on [its documentation page](docs/ease.md).

<a name="conclusion"/>
## Conclusion
Now you have everything you need to begin modding. The [main page](index.md) has links to other functions you can read about.
