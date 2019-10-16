#!/bin/sh
set -e # quit script on error

pushd OmmelStitcher
	git pull origin master
popd
git add OmmelStitcher

version="$(grep -E 'AssemblyVersion' OmmelStitcher/Properties/AssemblyInfo.cs | sed -E 's/\[assembly: AssemblyVersion\("([0-9]+).([0-9]+).([0-9]+)\.\*"\)\]/\1.\2.\3/g')"
zipname="OmmelMod-$version.zip"

mkdir -p out

rm -rf OmmelStitcher/bin
pushd OmmelStitcher
msbuild /p:Configuration=Release /p:Platform=x86
popd

rm -rf .tmp
mkdir .tmp
mkdir .tmp/ommel
cp mod.xml .tmp/ommel/ 
cp init.lua .tmp/ommel/
sed -i 's/%VERSION%/'"$version"'/' .tmp/ommel/mod.xml
sed -i 's/%VERSION%/'"$version"'/' .tmp/ommel/init.lua
mkdir .tmp/ommel/ommel
cp OmmelStitcher/bin/Release/* .tmp/ommel/ommel
pushd .tmp
zip -r "$zipname" ommel
popd
mv .tmp/"$zipname" out/
