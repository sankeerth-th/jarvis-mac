#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Jarvis"
PKG_DIR="$ROOT_DIR/apps/macos/Jarvis"
BUILD_DIR="$ROOT_DIR/dist"
DERIVED_DATA="$BUILD_DIR/DerivedData"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"

mkdir -p "$BUILD_DIR"
rm -rf "$DERIVED_DATA" "$APP_BUNDLE" "$DMG_PATH" "$BUILD_DIR/dmg-src"

echo "==> Building $APP_NAME (Release)…"
(
  cd "$PKG_DIR"
  /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
    -scheme "$APP_NAME" \
    -destination 'platform=macOS' \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    build
)

BIN_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME"
if [[ ! -f "$BIN_PATH" ]]; then
  echo "Build output not found at $BIN_PATH" >&2
  exit 1
fi

echo "==> Creating .app bundle…"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Minimal Info.plist for unsigned local distribution.
cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>com.jarvis.mac</string>
  <key>CFBundleVersion</key>
  <string>0.1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>

  <!-- Menu bar app behavior -->
  <key>LSUIElement</key>
  <true/>

  <!-- Permissions -->
  <key>NSMicrophoneUsageDescription</key>
  <string>Jarvis uses the microphone for push-to-talk voice commands.</string>
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>Jarvis uses speech recognition to convert voice commands into text.</string>
</dict>
</plist>
PLIST

echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "==> Creating DMG…"
DMG_SRC="$BUILD_DIR/dmg-src"
mkdir -p "$DMG_SRC"
cp -R "$APP_BUNDLE" "$DMG_SRC/"

# Create a simple read-only DMG.
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_SRC" \
  -ov -format UDZO \
  "$DMG_PATH" > /dev/null

echo "✅ DMG created: $DMG_PATH"
