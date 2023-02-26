#!/bin/bash

usage(){
    echo ""
    echo "No arguments supplied"
    echo ""
    echo "Usage: $0 [-d] [-k] [Signing Keystore] <APK filename>"
    echo ""
    echo "Options:"
    echo ""
    echo "  -d  --debuggable     Make the new APK also debuggable"
    echo ""
    echo "  -k  --key-store       [Signing Keystore]  path to signing key"
    echo ""
    echo "  -b  --build-tools     Set custom android build tools path"
    echo "  for example: --build-tools ~/Library/Android/sdk/build-tools/"
    echo ""
    echo "  --help               Show this help"
    echo ""
    exit -1
}


if [ $# -eq 0 ]
then
    usage;
fi


POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do

  case $1 in
    -d | --debuggable)
      makeDebuggable=true
      shift 1
      ;;
    -k | --key-store)
    	debugKeystore="$2"
      shift 2
      ;;
    -b | --build-tools)
      search_dir="$2"
      shift 2
      ;;
    --help)
      usage;
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      apkfile_arg="$1"
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
    esac
done



DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! $search_dir ]
  then
    # echo "no search dir"
    search_dir=~/Library/Android/sdk/build-tools/
fi

BUILD_TOOLS_DIR_ARR=($search_dir*/)

arr_storted=($(echo "${BUILD_TOOLS_DIR_ARR[@]}" | LC_ALL=C sort -d));
echo "Using build tools in: ${arr_storted[${#arr_storted[@]}-1]}"

BUILD_TOOLS_DIR=${arr_storted[${#arr_storted[@]}-1]}

if [ ! $debugKeystore ]; then
    debugKeystore=~/.android/debug.keystore
    if [ ! -f $debugKeystore ]; then
      if [ ! -d ~/.android ]; then
        mkdir ~/.android
      fi
      echo "No debug keystore was found, creating new one..."
      keytool -genkey -v -keystore $debugKeystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
    fi
fi



fullfile=$apkfile_arg
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

