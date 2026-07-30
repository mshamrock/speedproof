#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/.build/SpeedProof.app"
LEGACY_APP_DIR="$ROOT_DIR/.build/Grace AI.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SIGNING_IDENTITY="SpeedProof Local"
LOCAL_KEYCHAIN="$HOME/Library/Keychains/SpeedProof.keychain-db"
LOCAL_KEYCHAIN_PASSWORD_FILE="$HOME/Library/Application Support/SpeedProof/signing-keychain-password"

cd "$ROOT_DIR"
mkdir -p "$ROOT_DIR/.build/cache/clang"
export CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.build/cache/clang"

rm -rf "$APP_DIR" "$LEGACY_APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

clang \
  -fobjc-arc \
  -fmodules \
  -mmacosx-version-min=13.0 \
  -framework Cocoa \
  -framework Carbon \
  "$ROOT_DIR"/Sources/SpeedProof/main.m \
  -o "$MACOS_DIR/SpeedProof"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/SpeedProof.icns" "$RESOURCES_DIR/SpeedProof.icns"

if [[ -f "$LOCAL_KEYCHAIN" && -f "$LOCAL_KEYCHAIN_PASSWORD_FILE" ]]; then
  security unlock-keychain \
    -p "$(cat "$LOCAL_KEYCHAIN_PASSWORD_FILE")" \
    "$LOCAL_KEYCHAIN"
fi

SIGNING_HASH="$(
  security find-identity -v -p codesigning "$LOCAL_KEYCHAIN" 2>/dev/null |
    awk -v name="\"$SIGNING_IDENTITY\"" '$0 ~ name { print $2; exit }'
)"
if [[ -z "$SIGNING_HASH" && -f "$LOCAL_KEYCHAIN" ]]; then
  SIGNING_HASH="$(
    security find-certificate -c "$SIGNING_IDENTITY" -Z "$LOCAL_KEYCHAIN" 2>/dev/null |
      awk '/SHA-1 hash:/{ print $3; exit }'
  )"
fi

if [[ -n "$SIGNING_HASH" ]]; then
  codesign --force --deep --sign "$SIGNING_HASH" "$APP_DIR"
else
  codesign --force --deep --sign - "$APP_DIR"
fi

echo "$APP_DIR"
