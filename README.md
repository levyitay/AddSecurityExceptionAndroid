# Add Securiy Exception to APK

Google introduced on Android 7.0 new network security enhancements.
Those new enhancements prevents 3rd party to listen to network requests coming out of the app.
More info: 
1) https://developer.android.com/training/articles/security-config.html
2) http://android-developers.blogspot.com/2016/07/changes-to-trusted-certificate.html

This script injects into the APK network security exceptions that allow 3rd party softwares, like Charles Proxy / Fidler to listen to the network requests and resposes of the app. 


## Getting Started

Download the sciprt and the xml file and place them in the same directory.

### Prerequisites

You will need apktool and android sdk installed

I recommend using brew on Mac to install apktool

```
brew install apktool
```

## Usage

The script take 2 arguments: 
1) Apk file path.
2) keystore file path (**optional** - Default is: ~/.android/debug.keystore )

### Examples

```
./addSecurityExceptions.sh myApp.apk

or

./addSecurityExceptions.sh myApp.apk ~/.android/debug.keystore

```
