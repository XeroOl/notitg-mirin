#!/bin/sh
VER=$1
if [[ -z "$VER" ]]
then
    VER="unknown"
fi
FILENAME=mirin-template-"$VER".zip

mkdir build
cp -r Song.ogg Song.sm lua template build
cd build

sed 's/$VERSION/'"$VER"'/' template/main.xml -i
zip ../"$FILENAME" * -r

cd ..
rm build -rf
