# Numina iOS - Release Process

## Prerequisites
- Xcode 15+
- macOS 14+ (Sonoma)
- Apple Developer account
- Fastlane installed: `gem install fastlane`

## Setup

1. **Install dependencies**:
   ```bash
   gem install bundler
   bundle install
   ```

2. **Configure Fastlane**:
   ```bash
   export APPLE_ID="your@email.com"
   export ITC_TEAM_ID="your_team_id"
   export TEAM_ID="your_team_id"
   ```

## Build for TestFlight

```bash
fastlane beta
```

Or manually:
```bash
./scripts/build-release.sh
```

## Build for App Store

```bash
fastlane release
```

## Testing

### Unit Tests
```bash
fastlane test
```

### UI Tests
```bash
./scripts/run-ui-tests.sh
```

### Take Screenshots
```bash
./scripts/take-screenshots.sh
```

## Versioning

Update version in Xcode or via fastlane:
```bash
fastlane run increment_version_number bump_type:patch
fastlane run increment_build_number
```

## App Store Submission Checklist

- [ ] All tests passing
- [ ] Version and build numbers incremented
- [ ] Release notes updated
- [ ] Screenshots captured for all device sizes
- [ ] App icons at all required sizes
- [ ] Privacy policy URL valid
- [ ] Support URL valid
- [ ] App Store description complete
- [ ] Keywords optimized
- [ ] Age rating appropriate
- [ ] Export compliance information provided

## Troubleshooting

### Code Signing Issues
- Verify certificates in Xcode: Preferences > Accounts
- Check provisioning profiles
- Clean build folder: Cmd+Shift+K

### TestFlight Upload Fails
- Check bundle ID matches
- Verify app-specific password for Apple ID
- Check export options in Fastfile
