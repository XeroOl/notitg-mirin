# Plugins
## Installing a Plugin
If there isn't already a `plugins/` folder, add one. It should be in the same directory as the `.sm` file.
Just take the plugin's `.xml` file and put it in the `plugins/` folder. Congrats! You're Done!
## Making a Plugin
Make an xml with a `LoadCommand`, just like `mods.xml` is done. Plugin `LoadCommand`s will be called in alphabetical order by plugin name before the `lua/mods.xml` one is called. You can do the exact same things in a plugin that you can in `mods.xml`.


## FAQ
No, you can't get any plugin code to run after the user's `mods.xml` yet. No you can't change the order that plugins are loaded.
Support for this sort of thing will be coming in the future. If you have any suggestions on the best way to do this, I'm open to ideas. So far, these are my ideas, and none of them are too great:
* Different stages of loading. (think Load1Command, Load2Command, Load3Command)
* Better suppport for scheduled functions. Basically, allow `ease`, `func`, etc during functions scheduled for beat 0. Maybe have it specifically exposed to 
