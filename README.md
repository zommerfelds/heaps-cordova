# Heaps + Cordova

This demo showcases how to setup a basic Android app using [Heaps](https://heaps.io/) and [Cordova](https://cordova.apache.org/). This uses:

* Heaps for building an HTML5 package
* Cordova for generating a WebView based app (Android Studio not needed)
* Optional: Docker to automate the entire setup

Notes:

* Feel free to commend by opening an issue on Github!
* Compiling Heaps to native code and building using NDK seems hard, but so far I'm happy with the performance of the WebView approach.
* Cordova supports iOS too so this demo should work without much change. Feel free to contribute if you have an iPhone.
* It would be nice to extend this demo to use more Cordova features like for example the accelerometer.

## Option 1: use Docker

This option is much easier since you don't need to have anything istalled on your system, but it requires Docker (a recent version supporting buildx).

The provided Dockerfile can build the entire app in one go, so feel free to skip to the last subsection.

### Build the web app
```
docker buildx build --target haxe-output --output build --progress plain .
```
This will produce a `build/` output. Before even having an app, you can develop and test it on your computer by opening `index.html` in the root folder.

### Build the debug APK
```
docker buildx build --target cordova-output-unsigned --output build-android --progress plain .
```
This will produce an APK in `build-android/` that you can save an run to your phone. No Android tools required at all, but for development it would be potentially usefull to instal ADB for sending and running the APK on a phone.

### Building a signed APK
If you want to upload your APK to Google Play, you'll need to setup signing keys and sign your app. Signing is supported by this Docker image but you need to setup the keys first.

```
keytool -genkey -v -keystore your-android.keystore -alias your-alias -validity 10000
# Manually save your password in secret-keystore-password.txt
openssl base64 -A -in your-android.keystore > secret-keystore-base64.txt
```

Generate the signed APK:

```
docker buildx build --target cordova-output-signed --output build-android --progress plain --secret id=keystore-base64,src=secret-keystore-base64.txt --secret id=keystore-password,src=secret-keystore-password.txt .
```

### Upload to Google Play Internal Testing track

You can automate publishing to Google Play by using a command like:

```
docker buildx build --target upload-to-play --progress plain --secret id=keystore-base64,src=secret-keystore-base64.txt --secret id=keystore-password,src=secret-keystore-password.txt --secret id=service-account,src=secret-service-account.json .
```

If you are interested in more instructions, see the Dockerfile and/or create a Github issue.

## Option 2: install everything manually

### Install Haxe
Ubuntu:
```
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
```

Arch Linux:
```
sudo pacman -S haxe
```

### Install Haxe dependencies (Heaps)
```
# If running for first time:
mkdir ~/.local/lib/haxelib && haxelib setup ~/.local/lib/haxelib

haxelib install game-js.hxml
```

### Build Android app
* Install Cordova
* Then build the app:

```
cd cordova
rm -rf www/build && cp ../build -r www
cordova build
cordova run
```
