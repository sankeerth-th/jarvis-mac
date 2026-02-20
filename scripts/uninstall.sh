#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Jarvis"
APP_PATH="/Applications/${APP_NAME}.app"

echo "==> Quitting ${APP_NAME} if running…"
osascript -e 'tell application "Jarvis" to quit' >/dev/null 2>&1 || true

if [[ -d "$APP_PATH" ]]; then
  echo "==> Removing $APP_PATH"
  rm -rf "$APP_PATH"
else
  echo "(No app found at $APP_PATH)"
fi

echo "==> (Optional) Removing preferences…"
# Remove app preferences if present.
# Note: if we later add a bundle identifier (com.jarvis.mac), preferences may live under that.
rm -f "$HOME/Library/Preferences/com.jarvis.mac.plist" >/dev/null 2>&1 || true

echo "✅ Uninstall complete."
