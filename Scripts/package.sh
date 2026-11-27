#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$PROJECT_DIR/LyricsX.xcodeproj"
SCHEME="LyricsX"
CONFIGURATION="Release"
BUILD_DIR="$PROJECT_DIR/.build/package"
DERIVED_DATA="$BUILD_DIR/DerivedData"
OUTPUT_DIR="$BUILD_DIR/output"
APP_PATH="$OUTPUT_DIR/LyricsX.app"
ZIP_PATH="$BUILD_DIR/LyricsX.zip"

rm -rf "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

export CX_COMBINE_IMPLEMENTATION=Combine

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  -skipPackageSignatureValidation \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_ENTITLEMENTS="" \
  ENABLE_HARDENED_RUNTIME=NO \
  build

BUILT_APP="$DERIVED_DATA/Build/Products/$CONFIGURATION/LyricsX.app"
if [[ ! -d "$BUILT_APP" ]]; then
  echo "error: built app not found at $BUILT_APP" >&2
  exit 1
fi

cp -R "$BUILT_APP" "$APP_PATH"

find "$APP_PATH" -type d \( -name '*.app' -o -name '*.framework' \) -print0 | while IFS= read -r -d '' nested; do
  codesign --force --sign - "$nested"
done
codesign --force --deep --sign - "$APP_PATH"

ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "APP: $APP_PATH"
echo "ZIP: $ZIP_PATH"
