#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: $0 <APK filename>"
    exit -1
fi
if [ ! -z "$2" ]
	then
		debugKeystore=$2
	else
    if [ ! -f ~/.android/debug.keystore ]; then
      if [ ! -d ~/.android ]; then
        mkdir ~/.android
      fi
      echo "No debug keystore was found, creating new one..."
      keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
    fi
		debugKeystore=~/.android/debug.keystore
fi


fullfile=$1
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
new="_new.apk"
newFileName=$filename$new
tmpDir=/tmp/$filename

java -jar "$DIR/apktool.jar" d -f -s -o "$tmpDir" "$fullfile"

if [ ! -d "$tmpDir/res/xml" ]; then
	mkdir "$tmpDir/res/xml"
fi

cp "$DIR/network_security_config.xml" "$tmpDir/res/xml/."
if ! grep -q "networkSecurityConfig" "$tmpDir/AndroidManifest.xml"; then
  sed -E "s/(<application.*)(>)/\1 android\:networkSecurityConfig=\"@xml\/network_security_config\" \2 /" "$tmpDir/AndroidManifest.xml" > "$tmpDir/AndroidManifest.xml.new"
  mv "$tmpDir/AndroidManifest.xml.new" "$tmpDir/AndroidManifest.xml"
fi


java -jar "$DIR/apktool.jar" empty-framework-dir --force "$tmpDir"
echo "Building new APK $newFileName"
java -jar "$DIR/apktool.jar" b -o "./$newFileName" "$tmpDir"
jarsigner -verbose -keystore $debugKeystore -storepass android -keypass android "./$newFileName" androiddebugkey

