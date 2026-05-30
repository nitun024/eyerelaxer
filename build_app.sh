#!/bin/bash

set -euo pipefail

APP_NAME="EyeRelaxer"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Keep this stable across builds, otherwise macOS will treat it as a different app and notification permission can disappear.
BUNDLE_ID="${BUNDLE_ID:-com.example.EyeRelaxer}"

# Build the Swift package
swift build -c release

# Recreate the app bundle to avoid stale leftovers.
rm -rf "$APP_BUNDLE"

# Create the App Bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# ---- App icon handling ----
# Expected source: Sources/EyeRelaxer/Resources/AppLogo.svg (used by menu bar) and/or an AppIcon.icns you provide.
ICON_SRC_ICNS="Sources/EyeRelaxer/Resources/AppIcon.icns"
ICON_DST_ICNS="$RESOURCES_DIR/AppIcon.icns"

if [ -f "$ICON_SRC_ICNS" ]; then
  cp "$ICON_SRC_ICNS" "$ICON_DST_ICNS"
else
  # Best-effort: generate an icns from the SVG using built-in macOS tools.
  SVG="Sources/EyeRelaxer/Resources/AppLogo.svg"
  if [ -f "$SVG" ]; then
    TMPDIR=$(mktemp -d)
    ICONSET="$TMPDIR/AppIcon.iconset"
    mkdir -p "$ICONSET"

    # Render SVG to a base PNG using sips (works on macOS for many SVGs).
    # If SVG rendering fails, you can instead drop an AppIcon.icns at Sources/EyeRelaxer/Resources/AppIcon.icns.
    BASEPNG="$TMPDIR/AppLogo.png"
    if sips -s format png "$SVG" --out "$BASEPNG" >/dev/null 2>&1; then
      for size in 16 32 64 128 256 512; do
        sips -z $size $size "$BASEPNG" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null 2>&1
        sips -z $((size*2)) $((size*2)) "$BASEPNG" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null 2>&1
      done

      if iconutil -c icns "$ICONSET" -o "$ICON_DST_ICNS" >/dev/null 2>&1; then
        echo "Generated $ICON_DST_ICNS"
      else
        echo "Warning: failed to create .icns via iconutil."
      fi
    else
      echo "Warning: sips couldn't render SVG to PNG. Provide an AppIcon.icns at $ICON_SRC_ICNS to set a Finder/Dock icon."
    fi

    rm -rf "$TMPDIR"
  fi
fi

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Ad-hoc sign (local, no certificate) so macOS treats this as a proper app bundle.
# IMPORTANT: use /usr/bin/codesign (the system tool). Some environments have a different `codesign` earlier in PATH.
/usr/bin/codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true

echo "App bundle created at $APP_BUNDLE (bundle id: $BUNDLE_ID)"
