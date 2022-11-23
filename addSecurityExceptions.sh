#!/bin/bash

if [ $# -eq 0 ]
  then
    echo ""
    echo "No arguments supplied"
    echo ""
    echo "Usage: $0 [-d] <APK filename> [Signing Keystore]"
    echo ""
    echo "Options:"
    echo ""
    echo "  -d      Make the new APK also debuggable"
    echo "  [Signing Keystore]  path to signing key"
    echo ""
    exit -1
fi

if [[ "$1" == "-d" ]]; then 
  echo "Will create the new APK also debuggable."
  makeDebuggable=true
  shift
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
search_dir=~/Library/Android/sdk/build-tools

BUILD_TOOLS_DIR_ARR=($search_dir/*/)

arr_storted=($(echo "${BUILD_TOOLS_DIR_ARR[@]}" | LC_ALL=C sort -d));
echo "Using build tools in: ${arr_storted[${#arr_storted[@]}-1]}"

BUILD_TOOLS_DIR=${arr_storted[${#arr_storted[@]}-1]}

if [ ! -z "$2" ]
	then
    echo "Using custom keystore for signing."
		debugKeystore=$2
	else
    if [ ! -f ~/.android/keystore.jks ]; then
      if [ ! -d ~/.android ]; then
        mkdir ~/.android
      fi
      echo "No debug keystore was found, creating new one..."
      keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
    fi
		debugKeystore=~/.android/keystore.jks
fi


fullfile=$1
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
new="_new.apk"
temp="_temp.apk"
tempFileName=$filename$temp
newFileName=$filename$new
tmpDir=/tmp/$filename

java -jar "$DIR/apktool.jar" d -s -f -o "$tmpDir" "$fullfile"

if [ ! -d "$tmpDir/res/xml" ]; then
	mkdir "$tmpDir/res/xml"
fi
cp "$DIR/network_security_config.xml" "$tmpDir/res/xml/."
if [ ! -f "$tmpDir/res/xml/network_security_config.xml" ]; then 
  cp "$DIR/network_security_config.xml" "$tmpDir/res/xml/."
fi

if ! grep -q "networkSecurityConfig" "$tmpDir/AndroidManifest.xml"; then
  echo "Injecting the networkSecurityConfig attribute in AndroidManifest.xml..."
  sed -E "s/(<application.*)(>)/\1 android\:networkSecurityConfig=\"@xml\/network_security_config\" \2 /" "$tmpDir/AndroidManifest.xml" > "$tmpDir/AndroidManifest.xml.new"
  mv "$tmpDir/AndroidManifest.xml.new" "$tmpDir/AndroidManifest.xml"
fi

if [ $makeDebuggable ] && ! grep -q "debuggable" "$tmpDir/AndroidManifest.xml"; then
  echo "Injecting the debuggable attribute in AndroidManifest.xml..."
  sed -E "s/(<application.*)(>)/\1 android\:debuggable=\"true\" \2 /" "$tmpDir/AndroidManifest.xml" > "$tmpDir/AndroidManifest.xml.new"
  mv "$tmpDir/AndroidManifest.xml.new" "$tmpDir/AndroidManifest.xml"
fi


java -jar "$DIR/apktool.jar"  --use-aapt2 empty-framework-dir --force "$tmpDir"
echo "Building temp APK $tempFileName"
java -jar "$DIR/apktool.jar" --use-aapt2 b -o "./$tempFileName" "$tmpDir"

echo "Running Zip Align on $tempFileName and creating $newFileName"
$BUILD_TOOLS_DIR/zipalign -p 4 $tempFileName $newFileName

echo "Signing temp file $newFileName"
$BUILD_TOOLS_DIR/apksigner sign --ks $debugKeystore --ks-pass pass:android "./$newFileName"

rm -rf $tempFileName
echo "Resigned APK successfully $newFileName"

