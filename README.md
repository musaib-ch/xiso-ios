# XISO Studio for iOS

A native SwiftUI interface scaffold based on the XISO Studio Stitch design.

## Current status

This repository now contains the first native iOS UI scaffold and a GitHub Actions simulator build workflow.

- Home dashboard with Extract, Create, List, and Rewrite operation cards.
- Files tab using the iOS document picker.
- Activity and Settings tabs.
- Dark appearance with Xbox-inspired green accents.
- GitHub Actions workflow that generates an Xcode project using XcodeGen, builds for the iOS Simulator, and uploads a ZIP artifact.

**Important:** The XISO processing engine is not integrated yet. The operation screens are interface scaffolding only. This build does not yet extract, create, list, or rewrite ISO/XISO data. Device storage figures and sample job statuses from the original HTML mockup are intentionally not represented as real data.

## Build with GitHub Actions

1. Open the repository's **Actions** tab.
2. Select **iOS Build**.
3. Choose **Run workflow**, or push a commit to `main`.
4. When the workflow succeeds, open its run and download the `XISOStudio-iOS-Simulator` artifact.

The artifact is an iOS Simulator app bundle, not a signed IPA for installation on a physical iPhone.

## Local build on macOS

Install Xcode and XcodeGen, then run:

```sh
brew install xcodegen
xcodegen generate --spec project.yml
xcodebuild -project XISOStudio.xcodeproj \
  -scheme XISOStudio \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## Next implementation step

Integrate the upstream `extract-xiso` C engine behind a Swift wrapper, then connect each operation to the engine with progress reporting, cancellation, file validation, and safe output handling. Confirm upstream licensing and supported image formats before redistributing engine code.
