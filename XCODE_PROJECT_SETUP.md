# Xcode Project Setup Instructions

## Creating the Xcode Project

Since this codebase was scaffolded without an actual Xcode installation, you'll need to create the Xcode project manually.

### Steps:

1. **Open Xcode** (requires macOS with Xcode installed)

2. **Create New Project:**
   - File → New → Project
   - Choose "iOS" → "App"
   - Click "Next"

3. **Configure Project:**
   - Product Name: `Numina`
   - Team: Select your development team
   - Organization Identifier: `com.numina` (or your own)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
   - Click "Next"

4. **Save Location:**
   - Choose this directory: `numina-ios/`
   - Click "Create"

5. **Replace Default Files:**
   - Delete the default `ContentView.swift` and `NuminaApp.swift` files Xcode created
   - The project already contains all necessary Swift files in the proper structure
   - Ensure all files in the `Numina/` directory are added to the Xcode project target

6. **Add Files to Project:**
   - Right-click on the `Numina` folder in Xcode Navigator
   - Select "Add Files to Numina..."
   - Select all the directories: `Core/`, `Features/`, `Components/`
   - Make sure "Copy items if needed" is **unchecked** (files are already in place)
   - Make sure "Create groups" is selected
   - Make sure the "Numina" target is checked
   - Click "Add"

7. **Configure Build Settings:**
   - Select the Numina project in the Navigator
   - Select the "Numina" target
   - Go to "General" tab:
     - Minimum Deployments: iOS 15.0
     - iPhone Orientation: Portrait, Landscape Left, Landscape Right
   - Go to "Build Settings" tab:
     - Search for "Swift Language Version"
     - Ensure it's set to Swift 5 or later

8. **Configure Info.plist:**
   - The `Info.plist` file is already created with necessary permissions
   - Make sure it's linked in the project settings:
     - Select project → Target → Build Settings
     - Search for "Info.plist File"
     - Set to: `Numina/Info.plist`

9. **Add Privacy Permissions:**
   - Already configured in `Info.plist`:
     - Location When In Use: ✓
     - Location Always And When In Use: ✓

10. **Build and Run:**
    - Select a simulator or device
    - Press Cmd+R to build and run
    - The app should launch successfully

## Project Structure

```
numina-ios/
├── Numina.xcodeproj/          # Will be created by Xcode
├── Numina/
│   ├── NuminaApp.swift        # ✓ Created
│   ├── Info.plist             # ✓ Created
│   ├── Core/
│   │   ├── Network/           # ✓ Created
│   │   ├── Data/              # ✓ Created
│   │   └── Utilities/         # ✓ Created
│   ├── Features/
│   │   ├── Auth/              # ✓ Created
│   │   ├── Onboarding/        # ✓ Created
│   │   ├── Classes/           # ✓ Created
│   │   └── Profile/           # ✓ Created
│   ├── Components/            # ✓ Created
│   └── Resources/
│       └── Assets.xcassets    # ✓ Created
└── NuminaTests/               # Add your tests here
```

## Troubleshooting

### Missing Files in Project Navigator
- Right-click on Numina folder → "Add Files to Numina"
- Select missing directories
- Ensure target membership is correct

### Build Errors
- Clean build folder: Shift+Cmd+K
- Derived data: File → Project Settings → Delete Derived Data
- Restart Xcode

### SwiftData Errors
- Ensure iOS deployment target is 15.0+
- Check that SwiftData is available in your Xcode version

### Location Permission Not Working
- Check Info.plist has location usage descriptions
- Reset location permissions in Simulator: Settings → Privacy → Location Services

## Next Steps

After project setup:
1. Run the app in simulator
2. Test authentication flow
3. Test onboarding flow
4. Test class discovery and filters
5. Run unit tests (see NuminaTests/ directory)
