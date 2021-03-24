# ===========================================
FROM haxe:4.1 AS haxe-build

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install dependencies
COPY game-js.hxml /usr/src/app/
RUN yes | haxelib --quiet install all

# compile the project
COPY . /usr/src/app
RUN haxe game-js.hxml


# ===========================================
FROM scratch AS haxe-output
COPY --from=haxe-build /usr/src/app/build /


# ===========================================
FROM beevelop/cordova:v2021.02.1 AS cordova-build

RUN apt-get -y update && apt-get -y install git

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/cordova

COPY . /usr/src/app
RUN rm -rf www/build
COPY --from=haxe-build /usr/src/app/build /usr/src/app/cordova/www/build

# Debug: not sure why I need this but on Github Actions it's needed.
RUN cordova platform add android; exit 0


# ===========================================
FROM cordova-build AS build-unsigned-apk

RUN cordova build android

# ===========================================
FROM cordova-build AS build-signed-apk

RUN --mount=type=secret,id=keystore-base64 cat /run/secrets/keystore-base64 | base64 --decode > android.keystore
RUN --mount=type=secret,id=keystore-password KEYSTORE_PASSWORD="$(cat /run/secrets/keystore-password)" \
    && cordova build --release android -- --keystore=your-android.keystore --alias=your-alias --storePassword=${KEYSTORE_PASSWORD} --password=${KEYSTORE_PASSWORD} --packageType=apk


# ===========================================
FROM scratch AS cordova-output-unsigned

COPY --from=build-unsigned-apk /usr/src/app/cordova/platforms/android/app/build/outputs/apk/debug/app-debug.apk /

FROM scratch AS cordova-output-signed

COPY --from=build-signed-apk /usr/src/app/cordova/platforms/android/app/build/outputs/apk/release/app-release.apk /


# ===========================================
FROM node:15.11 AS upload-to-play

RUN npm i -g apkup@1.3 && apkup --version

COPY --from=cordova-output-signed /usr/src/app/cordova/platforms/android/app/build/outputs/apk/release/app-release.apk .

RUN --mount=type=secret,id=service-account DEBUG=* apkup \
    --key /run/secrets/service-account \
    --apk app-release.apk \
    --track internal
