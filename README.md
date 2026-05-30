# Eye Relaxer

Eye Relaxer is a macOS menu bar app that helps prevent eye strain by reminding you to take breaks.

## Requirements

- macOS 13.0 or later
- Xcode or Apple Command Line Tools with Swift 5.9
- `swift` available in your `PATH`

## Build from scratch

1. Open Terminal and change into the project folder:

```bash
cd EyeRelaxer
```

2. Install Xcode Command Line Tools if needed:

```bash
xcode-select --install
```

3. Make the build script executable (only required once):

```bash
chmod +x build_app.sh
```

4. Build the app bundle:

```bash
./build_app.sh
```

This will:

- build the Swift package in release mode
- create `EyeRelaxer.app`
- generate `Contents/Info.plist`
- copy the built executable into the app bundle
- generate an `.icns` icon if `Sources/EyeRelaxer/Resources/AppIcon.icns` is missing and `Sources/EyeRelaxer/Resources/AppLogo.svg` is available
- perform an ad-hoc codesign so macOS recognizes the bundle structure

## Run the app

After building, launch the app by opening the generated bundle:

```bash
open EyeRelaxer.app
```

## Notes

- The bundle identifier used by default is `com.example.EyeRelaxer`.
- To override the bundle identifier, set the `BUNDLE_ID` environment variable before running the build script:

```bash
BUNDLE_ID=com.yourname.EyeRelaxer ./build_app.sh
```

- If icon generation fails, add a proper `AppIcon.icns` to `Sources/EyeRelaxer/Resources/AppIcon.icns`.

- The app entry point is defined by `Package.swift` as an executable target named `EyeRelaxer`.

## Troubleshooting

- If `swift build` fails, verify that your Swift toolchain is installed and that you are running on macOS 13 or newer.
- If the built app does not launch, check for missing executable permissions or corrupted bundle structure.
- If notifications are not working, macOS may require user permission or the fallback AppleScript-based notification path may help.
