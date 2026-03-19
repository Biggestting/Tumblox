# Tumblox — Xcode Setup

## Creating the Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**, click Next
3. Set:
   - Product Name: `Tumblox`
   - Bundle Identifier: `com.tumblox.app`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 16.0**
4. Save the project to `/Users/kendrab./Desktop/Tumblox/`
5. Xcode will create `Tumblox.xcodeproj` and a default `TumbloxApp.swift` / `ContentView.swift` — **delete those from the project** (move to trash)
6. In Xcode's Project Navigator, right-click the `Tumblox` folder → **Add Files to "Tumblox"**
7. Select all `.swift` files from this directory (including all subfolders). Make sure **"Create groups"** is selected and **"Copy items if needed"** is unchecked.

## Folder Groups to Add

Add each folder as a group:
- `Navigation/`
- `State/`
- `Models/`
- `Theme/`
- `Services/`
- `Engine/`
- `Views/Common/`
- `Views/ModeSelect/`
- `Views/GameSetup/`
- `Views/Game/`
- `Views/Settings/`

## StoreKit Configuration (for IAP testing)

1. **File → New → File → StoreKit Configuration File** → name it `Tumblox.storekit`
2. Add an **In-App Purchase**:
   - Type: Non-Consumable
   - Product ID: `com.tumblox.fullgame`
   - Reference Name: Full Game Unlock
   - Price: $4.99
3. In your scheme: **Edit Scheme → Run → Options → StoreKit Configuration** → select `Tumblox.storekit`

## Build Requirements

- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+
- No third-party dependencies (pure SwiftUI + StoreKit 2)

## File Count

Sprint 1 + 2: **35 Swift files**
