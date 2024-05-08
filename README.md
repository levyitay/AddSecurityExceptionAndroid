
## ***Important***
**The latest update including some breaking changes in the arguments.**

# Add Security Exception to APK

In Android 7.0, Google introduced changes to the way user Certificate Authorities (CA) are trusted. These changes prevent third-parties from listening to network requests coming out of the application:
More info: 
1. https://developer.android.com/training/articles/security-config.html
2. http://android-developers.blogspot.com/2016/07/changes-to-trusted-certificate.html

This script injects into the APK network security exceptions that allow third-party software like Charles Proxy/Fiddler to listen to the network requests and responses of some Android applications.


## Getting Started

Download the script and the XML file and place them in the same directory.

### Prerequisites
* Java Installed

## Usage

The script arguments: 

`-d`, `--debuggable` (**optional**)

Make the new APK also debuggable

`-k`, `--key-store` `<keystore>` (**optional**) 

Path to signing key (default *~/.android/debug.keystore*)

`-s`, `--ks-key-alias` `<alias>` (**optional**) 

Path to signing key (default *androiddebugkey*)

`-b`, `--build-tools` `<sdk-path>` (**optional**) 

Set custom android build tools path (default *~/Library/Android/sdk/build-tools/*)


### Examples


Using default options:
```
./addSecurityExceptions.sh myApp.apk

```

Specifying build-tools and keystore:
```
./addSecurityExceptions.sh -d --build-tools ~/Library/Android/sdk/build-tools/ -k ~/.android/debug.keystore myApp.apk

```

Specifying keystore and alias:
```
./addSecurityExceptions.sh -d -k ~/.android/debug.keystore myApp.apk -s androiddebugkey

```
