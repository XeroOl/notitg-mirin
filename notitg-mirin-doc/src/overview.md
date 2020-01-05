# Getting Started
This book is an overview for how to use the Mirin Template. It will cover all of the features of the Mirin Template with examples. This chapter will describe how to use the template to create a new file, and how to add the template to an existing file. Future chapters will cover how to use the template once you have a file prepared.
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


###### Copyright (c) 2019 mirin (but definitely not XeroOl)