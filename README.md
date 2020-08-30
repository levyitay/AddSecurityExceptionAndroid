# Add Security Exception to APK

In Android 7.0, Google introduced changes to the way user Certificate Authorities (CA) are trusted. These changes prevent third-parties from listening to network requests coming out of the application:
More info:

1. https://developer.android.com/training/articles/security-config.html
2. http://android-developers.blogspot.com/2016/07/changes-to-trusted-certificate.html

This script injects into the APK network security exceptions that allow third-party software like Charles Proxy/Fiddler to listen to the network requests and responses of some Android applications.

## Getting Started

Download the script and the XML file and place them in the same directory.

### Prerequisites

APKTOOL is not needed anymore.

~~You will need `apktool` and the Android SDK installed~~
~~I recommend using `brew` on Mac to install `apktool`:~~
~~`brew install apktool`~~

## Usage

The script takes three arguments:

1. (optional) -d to also make the new APK debuggable
2. (required) APK file path.
3. (optional) keystore file path (**optional** - Default is: ~/.android/debug.keystore )

### Examples

```
./addSecurityExceptions.sh myApp.apk

or

./addSecurityExceptions.sh -d myApp.apk ~/.android/debug.keystore

```
