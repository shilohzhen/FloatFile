#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="FloatFile"
BUILD_DIR="$PROJECT_DIR/build"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"

echo "==> Building $APP_NAME (Release)..."

# Clean and build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build 2>&1 | tail -5

# Copy app to build dir
cp -R "$BUILD_DIR/DerivedData/Build/Products/Release/$APP_NAME.app" "$APP_PATH"

echo "==> Build complete: $APP_PATH"

# Create DMG
echo "==> Creating DMG installer..."

# Create a temporary directory for DMG contents
DMG_STAGING="$BUILD_DIR/dmg-staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"

# Create symlink to /Applications for drag-to-install
ln -s /Applications "$DMG_STAGING/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_STAGING" \
    -ov -format UDZO \
    "$DMG_PATH"

rm -rf "$DMG_STAGING"

echo "==> DMG created: $DMG_PATH"
echo ""
echo "To install: open the DMG and drag FloatFile to Applications."
echo "To run directly: open $APP_PATH"
