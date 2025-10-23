# Contributing to DayClose

Thank you for your interest in contributing to DayClose! This document provides guidelines for contributing to this privacy-first Apple Watch mood tracking app.

## 🎯 Project Mission

DayClose is a **100% on-device, privacy-first** mood tracking app for Apple Watch. Our core principles:
- ✅ **Privacy by Design**: All data stays on-device, zero network requests
- ✅ **Accessibility First**: WCAG 2.1 Level AA compliant
- ✅ **Modern watchOS**: Latest gesture patterns and APIs
- ✅ **Zero Dependencies**: Pure Apple frameworks only

## 🤝 Ways to Contribute

### 1. Bug Reports
Found a bug? Please create an issue with:
- **Description**: Clear explanation of the issue
- **Steps to Reproduce**: How to trigger the bug
- **Expected vs Actual**: What should happen vs what happens
- **Environment**: watchOS version, device model
- **Screenshots**: If applicable

### 2. Feature Requests
Have an idea? We'd love to hear it! Please:
- Check existing issues first
- Explain the use case
- Consider privacy implications
- Respect our "zero networking" principle

### 3. Code Contributions
Want to submit code? Great! Please:

#### Before You Start
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Check existing issues** to avoid duplicate work
4. **Discuss major changes** in an issue first

#### Code Standards
- ✅ **Swift 5.9+** syntax
- ✅ **SwiftUI** for all UI
- ✅ **No external dependencies** (pure Apple frameworks)
- ✅ **No networking code** (privacy requirement)
- ✅ **VoiceOver labels** on all interactive elements
- ✅ **Localized strings** (support EN + TR minimum)
- ✅ **Unit tests** for business logic
- ✅ **Clean comments** (avoid obvious comments, document complex logic only)

#### Commit Messages
Use clear, descriptive commit messages:
```
Good:
✅ Add HRV trend visualization to insights engine
✅ Fix VoiceOver label for mood selection button
✅ Improve Core Data query performance for 30-day trends

Bad:
❌ Update
❌ Fix bug
❌ WIP
```

#### Pull Request Process
1. **Update documentation** if needed
2. **Add tests** for new functionality
3. **Run CI verification**: `./scripts/CI_VERIFY.sh`
4. **Update CHANGELOG.md** with your changes
5. **Ensure accessibility**: Test with VoiceOver
6. **Submit PR** with clear description

### 4. Documentation
Help improve our docs:
- Fix typos or unclear explanations
- Add examples or tutorials
- Translate to new languages
- Update outdated information

### 5. Localization
Help translate DayClose:
- Copy `Resources/Base.lproj/Localizable.strings`
- Create `Resources/[lang].lproj/Localizable.strings`
- Translate all strings (keep keys unchanged)
- Test with system language set to your locale
- Submit PR with translation

**Current Languages**:
- 🇬🇧 English (complete)
- 🇹🇷 Turkish (complete)

**Wanted**:
- 🇪🇸 Spanish
- 🇩🇪 German
- 🇫🇷 French
- 🇯🇵 Japanese
- 🇰🇷 Korean
- And more!

## 🚫 What We Won't Accept

To maintain our privacy and quality standards:

❌ **Networking code** - No external API calls, analytics, or cloud sync  
❌ **Third-party SDKs** - Pure Apple frameworks only  
❌ **Tracking/Analytics** - No user behavior tracking  
❌ **Ads or monetization** - Keep it clean and simple  
❌ **Data export to cloud** - On-device only (local export OK)  
❌ **Breaking changes** without discussion  
❌ **Code without tests** - Critical features need unit tests  

## 📋 Development Setup

### Prerequisites
- macOS Sonoma or later
- Xcode 16+ (for watchOS 11 SDK)
- Apple Watch (for gesture testing) or Simulator

### Getting Started
```bash
# Clone the repository
git clone https://github.com/yourusername/DayClose.git
cd DayClose

# Open in Xcode
open DayClose.xcodeproj

# Or create new project and import files (see QUICKSTART.md)

# Run tests
./scripts/CI_VERIFY.sh

# Build and run
# Press Cmd+R in Xcode
```

### Project Structure
```
DayClose/
├── DayClose Watch App/
│   ├── Views/          # SwiftUI views
│   ├── Models/         # Data models
│   ├── Managers/       # Business logic
│   ├── Intents/        # Siri shortcuts
│   ├── Widgets/        # Complications
│   └── Resources/      # Localizations, assets
├── DayCloseTests/      # Unit tests
├── DayCloseUITests/    # UI tests
└── docs/               # Validation reports
```

## 🧪 Testing Requirements

### Unit Tests
- Required for all business logic
- Use in-memory Core Data for tests
- Mock HealthKit data where needed
- Aim for >80% coverage on managers

### UI Tests
- Test critical flows (mood selection, trends)
- Verify accessibility labels
- Test on multiple watch sizes (simulator)

### Manual Testing
Before submitting:
- [ ] Test on physical Apple Watch (if possible)
- [ ] Test with VoiceOver enabled
- [ ] Test with largest Dynamic Type size
- [ ] Test in Turkish (or your language)
- [ ] Test with HealthKit permission denied
- [ ] Verify no network requests (Network Link Conditioner)

## 🔒 Privacy Requirements

**CRITICAL**: Every contribution must maintain our privacy guarantees.

### Before Submitting Code
1. ✅ No `URLSession`, `URLRequest`, or networking imports
2. ✅ No third-party SDKs (except Apple frameworks)
3. ✅ No analytics or crash reporting
4. ✅ No user identifiers or device IDs stored
5. ✅ HealthKit data never stored outside Core Data
6. ✅ File protection enabled on Core Data store

### Verify Privacy
```bash
# Run automated privacy check
./scripts/CI_VERIFY.sh

# Manual check for networking code
grep -r "URLSession" "DayClose Watch App/"
grep -r "import Network" "DayClose Watch App/"
```

If any matches found → **Do not submit**.

## ♿ Accessibility Requirements

Every UI contribution must be accessible:

### Checklist
- [ ] VoiceOver labels on all interactive elements
- [ ] Descriptive hints where needed
- [ ] Dynamic Type support (no hardcoded font sizes)
- [ ] Minimum 44pt touch targets
- [ ] Color not sole indicator (use icons + text)
- [ ] Test with VoiceOver enabled

### Testing
```swift
// Good: Accessible button
Button("Check In") {
    // action
}
.accessibilityHint("Log your mood for today")

// Bad: Missing accessibility
Image(systemName: "checkmark")
    .onTapGesture { }
```

## 📝 Code Style

### Swift
- Use meaningful variable names
- Prefer `let` over `var`
- Use guard statements for early returns
- Group related code with `// MARK: -`
- Document complex algorithms (not obvious code)

### SwiftUI
- Extract complex views into subviews
- Use `@StateObject` for observed objects
- Use `@EnvironmentObject` for shared state
- Provide previews for all views

### Example
```swift
// Good
struct MoodSelectionView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var selectedMood: MoodType?
    
    var body: some View {
        // Clear, structured code
    }
}

#Preview {
    MoodSelectionView()
        .environmentObject(HealthKitManager.shared)
}

// Bad
struct MoodSelectionView: View {
    var manager: HealthKitManager // Not observed
    var mood: MoodType? // Mutable without @State
    
    var body: some View {
        // Implementation
    }
}
// No preview
```

## 🌐 Localization Guidelines

### Adding New Language
1. Create `Resources/[lang].lproj/` folder
2. Copy `Base.lproj/Localizable.strings`
3. Translate values (keep keys unchanged)
4. Add language to `Info.plist` → `CFBundleLocalizations`
5. Test with system language

### Translation Tips
- Keep it concise (watchOS has limited space)
- Use native idioms (not literal translations)
- Test on actual watch (text may be too long)
- Include gendered forms if language requires

## 📊 Performance Guidelines

- Use `lazy` loading where appropriate
- Limit Core Data fetch results
- Perform heavy work off main thread
- Use instruments to profile before optimizing

## 🏆 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Mentioned in release notes (if significant contribution)
- Given credit in app "About" section (if desired)

## 📞 Questions?

- **General questions**: Open a GitHub issue
- **Security concerns**: Email security@dayclose.app (if public repo)
- **Major features**: Discuss in issue first

## 📜 Code of Conduct

### Our Pledge
We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity, level of experience, nationality, personal appearance, race, religion, or sexual orientation.

### Our Standards
**Positive behavior**:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior**:
- Trolling, insulting/derogatory comments, personal or political attacks
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

### Enforcement
Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by opening an issue. All complaints will be reviewed and investigated.

## 🎉 Thank You!

Your contributions make DayClose better for everyone. Whether you're fixing a typo, translating strings, or adding major features, we appreciate your time and effort.

**Let's build the most private, accessible mood tracking app together!** 🚀

---

**Project Maintainers**: DayClose Team  
**License**: MIT (see LICENSE)  
**Privacy Policy**: See APPSTORE_METADATA.md

**Last Updated**: October 13, 2025
