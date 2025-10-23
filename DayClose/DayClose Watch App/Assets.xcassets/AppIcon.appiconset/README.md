# App Icons - DayClose

## Required Sizes for watchOS

The `AppIcon.appiconset` requires the following icon sizes:

### Apple Watch Sizes
- **38mm** (Series 1, 2, 3): 80x80 @ 2x (160x160 pixels)
- **40mm** (Series 4, 5, 6, SE): 88x88 @ 2x (176x176 pixels)
- **41mm** (Series 7, 8, 9): 92x92 @ 2x (184x184 pixels)
- **44mm** (Series 4, 5, 6, SE): 100x100 @ 2x (200x200 pixels)
- **45mm** (Series 7, 8, 9): 102x102 @ 2x (204x204 pixels)
- **49mm** (Ultra, Ultra 2): 108x108 @ 2x (216x216 pixels)

### Marketing
- **App Store**: 1024x1024 pixels (PNG, no transparency)

## Design Guidelines

### Visual Identity
- **Primary Color**: Blue/Purple gradient (representing mood/wellness)
- **Icon Shape**: Circular (matches watch face aesthetic)
- **Symbol**: Stylized emoji or abstract mood indicator
- **Style**: Minimalist, clear at small sizes

### watchOS Specific Requirements
- ✅ **No transparency**: Solid background required
- ✅ **Corner radius**: Applied automatically by system
- ✅ **Safe area**: Keep important elements within 90% of canvas
- ✅ **High contrast**: Readable on all watch faces
- ✅ **Dark mode**: Consider how icon looks on dark backgrounds

### Suggested Concepts

#### Concept 1: Stacked Emojis
- Three emotion indicators (😊😐😔) stacked vertically
- Gradient background (blue to purple)
- Modern, clear, instantly communicates app purpose

#### Concept 2: Abstract Mood Wave
- Wavy line representing emotional fluctuation
- Single color with subtle gradient
- Sophisticated, privacy-focused aesthetic

#### Concept 3: Calendar Check
- Stylized calendar with checkmark
- Represents daily check-in routine
- Clean, professional look

## Creating Icons

### Option 1: SF Symbols (Quick)
```swift
// Generate placeholder icons using SF Symbols
import SwiftUI

struct IconGenerator: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "face.smiling")
                .font(.system(size: 500))
                .foregroundStyle(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}
```

### Option 2: Design Tools
- **Figma**: Use watchOS icon template
- **Sketch**: Apple Design Resources (free)
- **Affinity Designer**: Export at multiple resolutions
- **Icon Slate** (Mac app): Specifically for app icons

### Option 3: Icon Services
- **App Icon Generator**: appicon.co (upload 1024×1024, get all sizes)
- **MakeAppIcon**: makeappicon.com
- **Appicon.build**: appicon.build

## Placeholder Icons

The current asset catalog contains **placeholder entries**. Replace with actual designed icons before App Store submission.

### Quick Setup Steps

1. **Design master icon** (1024×1024 PNG)
2. **Generate all sizes** using online tool or Xcode
3. **Drag into** `Assets.xcassets/AppIcon.appiconset/`
4. **Verify** in Xcode that all sizes are assigned
5. **Build** and check on device/simulator

## Testing Icons

- **Simulator**: Build and check home screen
- **Physical Device**: Best for color accuracy
- **Watch Face**: Test as complication icon (may be tinted)
- **App Store Connect**: Upload and preview in metadata

## File Naming Convention

Current expected filenames in `AppIcon.appiconset/`:
- `app-icon-38mm.png` (160×160)
- `app-icon-40mm.png` (176×176)
- `app-icon-41mm.png` (184×184)
- `app-icon-44mm.png` (200×200)
- `app-icon-45mm.png` (204×204)
- `app-icon-49mm.png` (216×216)
- `app-icon-marketing.png` (1024×1024)

## Compliance

✅ **No misleading elements**: Icon accurately represents app function  
✅ **No offensive content**: Family-friendly design  
✅ **No system elements**: Don't mimic Apple UI/icons  
✅ **Proper branding**: Consistent with app name and purpose  

## Color Palette Suggestion

Based on mood theme:
- **Primary**: #5B87FC (Calm Blue)
- **Accent**: #8B5FBF (Soothing Purple)
- **Background**: Gradient or solid
- **Foreground**: White or very light color

## Before Submission

- [ ] All 7 icon sizes created and added
- [ ] Marketing icon (1024×1024) meets App Store requirements
- [ ] Icons tested on multiple watch sizes
- [ ] Icons look good on light and dark watch faces
- [ ] No transparency in icons
- [ ] Colors are vibrant but not overwhelming

---

**Current Status**: ⚠️ Placeholder icons in place. Replace before App Store submission.

For quick testing, Xcode will use default icon. For production, professional icon design recommended.
