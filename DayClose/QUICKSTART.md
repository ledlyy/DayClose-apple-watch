# Quick Start Guide - DayClose

Get up and running with DayClose in 5 minutes.

## Prerequisites

- ✅ Mac with macOS Sonoma or later
- ✅ Xcode 15.0 or later installed
- ✅ Apple Watch (for physical device testing) or Simulator
- ✅ Apple Developer account (free tier works for testing)

## Step 1: Open Project (30 seconds)

```bash
cd /Users/ibrahimyasin/Desktop/apple-watch/DayClose
open DayClose.xcodeproj
```

If you don't have an Xcode project file yet, create one:
1. Open Xcode
2. File → New → Project
3. Select "Watch App"
4. Name: "DayClose"
5. Save to this directory
6. Add all existing `.swift` files to the target

## Step 2: Configure Signing (1 minute)

1. In Xcode, select the **DayClose Watch App** target
2. Go to **Signing & Capabilities** tab
3. **Team**: Select your Apple Developer team
4. **Bundle Identifier**: Keep `com.dayclose.app` or change to your domain

### Enable Capabilities
Click **+ Capability** and add:
- ✅ **HealthKit**
- ✅ **Push Notifications** (already in Info.plist)

## Step 3: Select Destination (10 seconds)

In Xcode toolbar:
- For **Simulator**: Select "Apple Watch Series 9 (45mm)" or similar
- For **Device**: Connect iPhone with paired Watch, select your watch name

## Step 4: Build and Run (1 minute)

Press **⌘R** (Cmd+R) or click the **Run** button ▶️

First build takes ~2 minutes. Subsequent builds ~30 seconds.

## Step 5: Use the App (30 seconds)

### On First Launch
1. Allow **Notifications** (optional)
2. Allow **HealthKit** (optional, can skip)

### Check In
1. Tap **"Check In"** button
2. Select a mood: 😊 Good, 😐 Neutral, or 😔 Difficult
3. Use **Digital Crown** to scroll through options
4. Tap **"Confirm"**
5. See instant feedback message
6. Tap **"Done"**

### View Trends
1. Swipe up to second tab
2. See your entry history (requires 1+ entries)
3. Tap **"View Analysis"** (after 3+ entries)

### Configure Settings
1. Swipe up twice to third tab
2. Toggle **Evening Reminder**
3. Set **Reminder Time**
4. Toggle **Use Health Data**

## Common Issues & Quick Fixes

### ❌ "No provisioning profiles found"
**Fix**: Xcode → Settings → Accounts → Download Manual Profiles

### ❌ "HealthKit entitlement not found"
**Fix**: Add HealthKit capability (Step 2 above)

### ❌ "Simulator doesn't show watch"
**Fix**: Window → Devices and Simulators → Add paired watch to simulator

### ❌ "Gestures not working"
**Note**: Double Tap requires physical Apple Watch Series 9+. Use buttons as fallback.

### ❌ "App crashes on launch"
**Fix**: 
1. Clean build: Shift+Cmd+K
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/DayClose-*`
3. Rebuild: Cmd+B

### ❌ "Strings appear as keys (e.g., 'mood.good')"
**Fix**: Verify `Base.lproj/Localizable.strings` is in target membership

## Testing in 2 Minutes

### Run Unit Tests
```bash
# In Xcode
Cmd+U

# Or terminal
xcodebuild test \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### Run UI Tests
```bash
# In Xcode
Cmd+U (includes all tests)

# Or just UI tests
xcodebuild test \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -only-testing:DayCloseUITests
```

## Next Steps

### For Development
- [ ] Customize mood options in `MoodType.swift`
- [ ] Modify insights in `InsightsEngine.swift`
- [ ] Add more localizations (copy `Base.lproj` to new `.lproj`)
- [ ] Run tests: Cmd+U

### For App Store Submission
- [ ] Create app icons (see `Assets.xcassets/AppIcon.appiconset/README.md`)
- [ ] Update Bundle ID to your domain
- [ ] Take screenshots on real devices (all watch sizes)
- [ ] Create support website with privacy policy
- [ ] Follow `APPSTORE_METADATA.md` submission guide

## File Quick Reference

| Need to... | File to Edit |
|------------|--------------|
| Change app name | `Info.plist` → `CFBundleDisplayName` |
| Modify mood options | `MoodType.swift` |
| Edit insights messages | `InsightsEngine.swift` |
| Change default reminder time | `UserPreferences.swift` → line 13 |
| Update localization | `Base.lproj/Localizable.strings` |
| Adjust colors | `Assets.xcassets/Mood*.colorset/` |
| Configure HealthKit | `HealthKitManager.swift` |
| Modify notifications | `NotificationManager.swift` |

## Keyboard Shortcuts in Xcode

- **⌘R**: Build and Run
- **⌘B**: Build only
- **⌘U**: Run tests
- **Shift+⌘K**: Clean build folder
- **⌘.**: Stop running app
- **⌘0**: Show/hide Navigator
- **⌘⌥0**: Show/hide Inspector
- **Shift+⌘Y**: Show/hide Debug area
- **⌘⇧O**: Open quickly (search files)

## Debugging Tips

### View Console Logs
1. Run app (⌘R)
2. Open Debug area (Shift+⌘Y)
3. Look for `print()` statements from code

### Set Breakpoints
1. Click line number gutter (blue arrow appears)
2. Run in debug mode (⌘R)
3. App pauses at breakpoint
4. Use LLDB commands or step through

### Inspect Core Data
```swift
// In MoodPromptView or any view with viewContext
let entries = try? viewContext.fetch(MoodEntry.fetchRequest())
print("Entries: \(entries?.count ?? 0)")
```

### Test Notifications
```bash
# Trigger notification immediately (after 5 seconds)
# Modify NotificationManager.swift temporarily:
# trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
```

## Performance Profiling

### Check Binary Size
```bash
# After building
du -h ~/Library/Developer/Xcode/DerivedData/DayClose-*/Build/Products/Debug-watchos/DayClose\ Watch\ App.app
# Target: < 10 MB
```

### Profile Memory
1. Product → Profile (⌘I)
2. Choose "Leaks" instrument
3. Record while using app
4. Look for red bars (leaks)

### Profile Time
1. Product → Profile (⌘I)
2. Choose "Time Profiler"
3. Record during mood selection
4. Look for slow functions

## Customization Examples

### Change Mood Emoji
```swift
// In MoodType.swift
var emoji: String {
    switch self {
    case .good: return "🎉"  // Changed from 😊
    case .neutral: return "🤔"  // Changed from 😐
    case .difficult: return "😢"  // Changed from 😔
    }
}
```

### Add Fourth Mood Option
```swift
// In MoodType.swift
enum MoodType: String, CaseIterable, Codable {
    case excellent = "excellent"  // NEW
    case good = "good"
    case neutral = "neutral"
    case difficult = "difficult"
}
```
Then update labels, emojis, colors, and localization strings.

### Change Default Reminder Time
```swift
// In UserPreferences.swift, line 13
@AppStorage("reminderHour") var reminderHour: Int = 19  // Changed from 20 (8 PM → 7 PM)
```

## Deployment Checklist (5 minutes)

Before showing to others:
- [ ] Change Bundle ID
- [ ] Update Team ID
- [ ] Test on physical device
- [ ] Verify all permissions work
- [ ] Check VoiceOver accessibility
- [ ] Test in Turkish (if applicable)
- [ ] Run all tests (Cmd+U)

Before App Store:
- [ ] Add app icons (7 sizes)
- [ ] Capture screenshots (7 watch sizes × 3-5 each)
- [ ] Create privacy policy page
- [ ] Set version to 1.0, build to 1
- [ ] Archive (Product → Archive)
- [ ] Upload to App Store Connect

## Support Resources

- **Full Documentation**: `README.md`
- **Build Issues**: `BUILD_GUIDE.md`
- **App Store Prep**: `APPSTORE_METADATA.md`
- **Project Overview**: `PROJECT_SUMMARY.md`
- **All Files**: `FILE_STRUCTURE.md`

## Getting Help

1. Check `README.md` → Troubleshooting section
2. Review inline code comments
3. Search Xcode error messages
4. Apple Developer Forums: https://developer.apple.com/forums/
5. Stack Overflow tag: `watchos`

## Estimated Time to Ship

- ✅ Code: **Complete** (0 hours)
- ⚠️ App Icons: **2-4 hours** (design or commission)
- ⚠️ Screenshots: **1-2 hours** (capture and annotate)
- ⚠️ Support Site: **1-2 hours** (simple static page)
- 📝 App Store Submission: **30 minutes** (fill forms)
- ⏳ Review Time: **1-3 days** (Apple's timeline)

**Total to launch**: ~1 business day of work + Apple review time

---

## One-Command Demo (Simulator)

If you just want to see it run immediately:

```bash
cd /Users/ibrahimyasin/Desktop/apple-watch/DayClose
# Create minimal Xcode project wrapper first
xcodebuild \
  -scheme "DayClose Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  build
```

Then open simulator and install the `.app` from DerivedData.

---

**🎉 You're ready to build!**

Press **⌘R** in Xcode and start exploring DayClose.

**Questions?** See `README.md` for comprehensive documentation.

**Ready to ship?** See `APPSTORE_METADATA.md` for submission guide.

**Last Updated**: October 13, 2025
