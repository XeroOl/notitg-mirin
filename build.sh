#!/bin/sh
VER=$1
if [[ -z "$VER" ]]
then
    VER="unknown"
fi
FILENAME=mirin-template-"$VER"

mkdir "$FILENAME"
cp -r Song.ogg Song.sm lua template "$FILENAME"
cd "$FILENAME"

sed 's/$VERSION/'"$VER"'/' template/main.xml -i

cd ..
zip "$FILENAME".zip "$FILENAME" -r
rm "$FILENAME" -rf
