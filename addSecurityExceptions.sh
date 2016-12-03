#!/bin/bash
if ! type apktool > /dev/null; then
  echo "Please install apktool"
  echo "Using Homebrew: `brew install apktool`"
  exit -1
fi

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: ./addSecurityExceptions.sh APK filename"
    exit -1
fi
if [ ! -z "$2" ]
	then
		debugKeystore=$2
	else
		debugKeystore=~/.android/debug.keystore
fi


fullfile=$1
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
new="_new.apk"
newFileName=$filename$new
tmpDir=/tmp/$filename

apktool d -f -o $tmpDir $fullfile

if [ ! -d "$tmpDir/res/xml" ]; then
	mkdir $tmpDir/res/xml
fi

cp ./network_security_config.xml $tmpDir/res/xml/.
sed -E "s/(<application.*)(>)/\1 android\:networkSecurityConfig=\"@xml\/network_security_config\" \2 /" $tmpDir/AndroidManifest.xml > $tmpDir/AndroidManifest.xml.new
mv $tmpDir/AndroidManifest.xml.new $tmpDir/AndroidManifest.xml

apktool empty-framework-dir --force $tmpDir
echo "Building new APK $newFileName"
apktool b -o ./$newFileName $tmpDir
jarsigner -verbose -keystore $debugKeystore -storepass android -keypass android ./$newFileName androiddebugkey

