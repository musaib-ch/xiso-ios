# XISO Studio for iOS

XISO Studio is a native SwiftUI interface for the existing XISO engine build in this repository. The dashboard is based on the supplied Google Stitch design.

## Features in the current build

- Home dashboard with Extract, Create, List, Rewrite, and Convert to GOD operations.
- Files tab for browsing through the iOS document picker.
- Activity tab showing the current operation, progress, cancellation, and engine logs.
- Settings tab with file safety information.
- Dark theme with Xbox-inspired green accents.
- Existing GitHub Actions workflow builds an unsigned iOS app package.

## Build with GitHub Actions

1. Open the repository's **Actions** tab.
2. Select **Build iOS (unsigned IPA)**.
3. Choose **Run workflow**, or push a commit to the repository.
4. Open the completed workflow run and download the **XisoGUI-ipa** artifact.

The generated IPA is unsigned. It is not directly installable through normal iOS installation until it is signed using a suitable certificate and provisioning profile.

## Implementation notes

The workflow fetches the upstream XISO engine sources and the pinned `iso2god-rs` source, generates the Xcode project with XcodeGen, and builds the iOS app. The Stitch-inspired dashboard is stored in `Sources/StudioDashboard.swift`; the workflow-generated app entry point routes the Home, Files, Activity, and Settings tabs to those views.

Review upstream licenses before redistributing binaries or source. Test image handling against known-good disc images before relying on output. Keep original images unless the user explicitly enables an operation that deletes them.
