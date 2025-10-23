# Build and Configuration Guide

## Xcode Project Configuration

### Target: DayClose Watch App

**Platform**: watchOS  
**Deployment Target**: 10.0 (with 11.0 features conditionally available)  
**Swift Version**: 5.9  
**Architecture**: arm64 (Apple Silicon), arm64_32 (older watches)

### Build Settings

#### Privacy & Security
```
ENABLE_BITCODE = NO (deprecated in Xcode 14+)
SWIFT_COMPILATION_MODE = wholemodule (for release)
SWIFT_OPTIMIZATION_LEVEL = -O (for release)
GCC_OPTIMIZATION_LEVEL = s (for release, size optimization)
```

#### Code Signing
```
CODE_SIGN_STYLE = Automatic (or Manual if using specific provisioning)
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = Apple Watch Development / Distribution
```

#### App Capabilities
- ✅ HealthKit
- ✅ Push Notifications
- ✅ Background Modes: Processing
- ✅ App Groups: `group.com.dayclose.app`

### Info.plist Key Configuration

Critical keys already set in `Info.plist`:
- `WKApplication`: true
- `WKWatchOnly`: true
- `NSHealthShareUsageDescription`: [Set]
- `NSUserNotificationsUsageDescription`: [Set]
- `UIBackgroundModes`: ["processing"]
- `CFBundleLocalizations`: ["en", "tr"]

### Entitlements

File: `DayClose.entitlements`
- `com.apple.developer.healthkit`: true
- `com.apple.security.application-groups`: ["group.com.dayclose.app"]

## Build Schemes

### Debug Scheme
```
Build Configuration: Debug
Executable: DayClose Watch App.app
```

**Debug Settings:**
- Optimization: None (-Onone)
- Debug Symbols: Yes
- Assertions: Enabled

### Release Scheme
```
Build Configuration: Release
Executable: DayClose Watch App.app
```

**Release Settings:**
- Optimization: Optimize for Size (-Os)
- Debug Symbols: No (unless uploading to App Store Connect)
- Assertions: Disabled
- Strip Debug Symbols: Yes

## Build Commands

### Build for Simulator
```bash
xcodebuild \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  build
```

### Build for Device
```bash
xcodebuild \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS,name=Your Watch Name' \
  build
```

### Archive for Distribution
```bash
xcodebuild \
  -scheme "DayClose Watch App" \
  -destination 'generic/platform=watchOS' \
  -archivePath ./build/DayClose.xcarchive \
  archive
```

### Export Archive for App Store
```bash
xcodebuild \
  -exportArchive \
  -archivePath ./build/DayClose.xcarchive \
  -exportPath ./build/Export \
  -exportOptionsPlist ExportOptions.plist
```

## ExportOptions.plist

Create this file for automated exports:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>[Your Team ID]</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

## Testing Configuration

### Unit Tests Target
- **Name**: DayCloseTests
- **Host Application**: None (watchOS unit tests)
- **Test Framework**: XCTest

### UI Tests Target
- **Name**: DayCloseUITests
- **Test Application**: DayClose Watch App
- **Test Framework**: XCTest

### Running Tests
```bash
# All tests
xcodebuild test \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'

# Unit tests only
xcodebuild test \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -only-testing:DayCloseTests

# Specific test
xcodebuild test \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -only-testing:DayCloseTests/PersistenceTests/testCreateMoodEntry
```

## Performance Optimization

### Compile-Time
- Use whole module optimization in release
- Enable Link-Time Optimization (LTO) for smaller binary
- Strip unused code with Dead Code Stripping

### Runtime
- Lazy loading of HealthKit data
- Efficient Core Data fetch requests (limits & predicates)
- Background thread for insights generation
- Minimal view state updates

### Memory
- In-memory Core Data for tests
- Proper @StateObject usage
- Release strong references in deinit
- Limit fetch request results

## Size Optimization

Target: < 10 MB uncompressed app bundle

**Current Strategies:**
- No embedded frameworks (pure Apple SDKs)
- Optimized asset catalog (no unnecessary images)
- Stripped debug symbols in release
- Localized strings only (no embedded fonts)

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v3
      
      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Build
        run: |
          xcodebuild \
            -scheme "DayClose Watch App" \
            -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
            build
      
      - name: Test
        run: |
          xcodebuild test \
            -scheme "DayClose Watch App" \
            -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

## Debugging Tips

### Common Build Issues

**Issue**: "No suitable application records were found"  
**Fix**: Ensure WKApplication = true in Info.plist

**Issue**: "HealthKit entitlement not found"  
**Fix**: Add HealthKit capability in Signing & Capabilities tab

**Issue**: "Code signing failed"  
**Fix**: Update Team ID and ensure provisioning profile includes watch

**Issue**: "Localizable.strings not found"  
**Fix**: Verify .lproj folders are in target membership

### Debugging on Device

1. Connect Apple Watch via iPhone in Xcode
2. Select your watch in device dropdown
3. Build and Run (Cmd+R)
4. View console logs in Xcode → Window → Devices and Simulators → Open Console

### Debugging Simulators

```bash
# List available simulators
xcrun simctl list devices watchOS

# Boot simulator
xcrun simctl boot "Apple Watch Series 9 (45mm)"

# Install app
xcrun simctl install booted ./build/Debug-watchsimulator/DayClose\ Watch\ App.app

# Launch app
xcrun simctl launch booted com.dayclose.app
```

## Instruments Profiling

### Memory Leaks
```bash
instruments -t Leaks -D ./trace.trace \
  /path/to/DayClose\ Watch\ App.app
```

### Time Profiler
```bash
instruments -t "Time Profiler" -D ./trace.trace \
  /path/to/DayClose\ Watch\ App.app
```

## Archive and Distribution

### Manual Archive Steps

1. **Product → Archive** in Xcode
2. Wait for archive to complete
3. Organizer opens automatically
4. Select archive → **Distribute App**
5. Choose **App Store Connect**
6. Select **Upload**
7. Follow wizard (automatic signing recommended)
8. Wait for processing (~10-60 minutes)
9. Check App Store Connect for build availability

### TestFlight Beta

Before public release:
1. Upload build to App Store Connect
2. Fill out beta information
3. Add internal testers (up to 100)
4. External beta review (1-2 days)
5. Add external testers (up to 10,000)
6. Collect feedback

## Build Troubleshooting

### Clean Build
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/DayClose-*

# Clean build folder
xcodebuild clean \
  -scheme "DayClose Watch App"

# Reset package cache (if using SPM)
xcodebuild -resolvePackageDependencies
```

### Reset Simulator
```bash
# Erase specific simulator
xcrun simctl erase "Apple Watch Series 9 (45mm)"

# Erase all simulators
xcrun simctl erase all
```

## Production Checklist

Before final build:

- [ ] Update version number (CFBundleShortVersionString)
- [ ] Increment build number (CFBundleVersion)
- [ ] Switch to Release configuration
- [ ] Verify all assets present (icons, colors)
- [ ] Test on physical device
- [ ] Run all tests (green pass)
- [ ] Profile for memory leaks
- [ ] Check binary size (< 10 MB target)
- [ ] Verify no debug code (print statements, etc.)
- [ ] Update release notes in APPSTORE_METADATA.md
- [ ] Archive with distribution certificate

## Versioning Strategy

Semantic versioning: **MAJOR.MINOR.PATCH**

- **MAJOR** (1.x.x): Breaking changes, major features
- **MINOR** (x.1.x): New features, backward compatible
- **PATCH** (x.x.1): Bug fixes only

**Build Number**: Increment for each upload to App Store Connect, regardless of version.

Example:
- Version 1.0, Build 1 (initial release)
- Version 1.0, Build 2 (fix crash, re-upload)
- Version 1.1, Build 3 (new feature)

## Support Contact

For build issues specific to this project, refer to:
- README.md (general troubleshooting)
- Inline code comments
- Apple Developer Forums
- Stack Overflow (tag: watchos, xcode)

---

**Ready to Build** ✅
