#!/bin/bash
# AR Trading: wraps https://ar-trading.netlify.app as an Android app (online)
set -e
mkdir -p www assets
cat > www/index.html << 'HTML'
<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>AR Trading</title></head>
<body style="font-family:sans-serif;text-align:center;padding:40px;background:#162949;color:#fff"><h2>AR Trading</h2><p>Loading...</p><p>Please check your internet connection.</p></body></html>
HTML
cp "$(ls ar-icon-only*.png | head -1)" assets/icon-only.png
cp "$(ls ar-icon-foreground*.png | head -1)" assets/icon-foreground.png
cp "$(ls ar-icon-background*.png | head -1)" assets/icon-background.png
echo '{"name":"ar-trading-app","version":"1.0.0","private":true,"dependencies":{"@capacitor/core":"^7.0.0","@capacitor/android":"^7.0.0"},"devDependencies":{"@capacitor/cli":"^7.0.0"}}' > package.json
echo '{"appId":"com.artrading.tradingapp","appName":"AR Trading","webDir":"www","server":{"url":"https://ar-trading.netlify.app","cleartext":false}}' > capacitor.config.json
npm install
npx cap add android
npx @capacitor/assets generate --android
npx cap sync android
(cd android && chmod +x gradlew && ./gradlew assembleDebug)
cp android/app/build/outputs/apk/debug/app-debug.apk ARTrading-test.apk
(cd android && ./gradlew assembleRelease)
echo "$KS_B64" | base64 -d > ar.jks
BT=$(ls -d $ANDROID_HOME/build-tools/* | sort -V | tail -1)
$BT/zipalign -p 4 android/app/build/outputs/apk/release/app-release-unsigned.apk aligned.apk
$BT/apksigner sign --ks ar.jks --ks-pass pass:"$KS_PASS" --key-pass pass:"$KS_PASS" --ks-key-alias stacktower --out ARTrading-release.apk aligned.apk
