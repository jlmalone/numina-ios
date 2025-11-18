# Task: Add Testing & Production Build Setup

> **IMPORTANT**: Check for `.task-testing-production-completed` before starting.
> If it exists, respond: "✅ This task has already been implemented."
> **When finished**, create `.task-testing-production-completed` file.

## Overview
Add comprehensive UI testing, production build configuration, and App Store preparation for the Numina iOS app.

## Requirements

### 1. UI Testing Suite (XCUITest)

Create test target if not exists, then add test files:

#### Test Infrastructure
**File**: `NuminaUITests/TestHelpers/TestHelper.swift`
```swift
import XCTest

class TestHelper {
    static func loginTestUser(app: XCUIApplication) {
        // Navigate to login if not already logged in
        if app.buttons["Login"].exists {
            app.buttons["Login"].tap()

            let emailField = app.textFields["emailField"]
            emailField.tap()
            emailField.typeText("test@example.com")

            let passwordField = app.secureTextFields["passwordField"]
            passwordField.tap()
            passwordField.typeText("test123")

            app.buttons["Sign In"].tap()

            // Wait for home screen
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        }
    }

    static func logoutTestUser(app: XCUIApplication) {
        if app.tabBars.buttons["Profile"].exists {
            app.tabBars.buttons["Profile"].tap()
            app.buttons["Logout"].tap()
        }
    }

    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
```

#### Test Files
**File**: `NuminaUITests/AuthFlowTests.swift`
```swift
import XCTest

final class AuthFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginFlow() throws {
        // Tap login button
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // Enter credentials
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2))
        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("test123")

        // Submit
        app.buttons["Sign In"].tap()

        // Verify navigation to home
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["Home"].exists)
    }

    func testRegistrationFlow() throws {
        let registerButton = app.buttons["Register"]
        XCTAssertTrue(registerButton.waitForExistence(timeout: 5))
        registerButton.tap()

        // Fill registration form
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test User")

        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("newuser@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")

        // Submit
        app.buttons["Create Account"].tap()

        // Verify success
        let welcomeText = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }

    func testInvalidCredentials() throws {
        let loginButton = app.buttons["Login"]
        loginButton.tap()

        app.textFields["emailField"].tap()
        app.textFields["emailField"].typeText("wrong@example.com")

        app.secureTextFields["passwordField"].tap()
        app.secureTextFields["passwordField"].typeText("wrongpass")

        app.buttons["Sign In"].tap()

        // Verify error message
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3))
    }
}
```

**File**: `NuminaUITests/ClassesFlowTests.swift`
```swift
import XCTest

final class ClassesFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        TestHelper.loginTestUser(app: app)
    }

    override func tearDownWithError() throws {
        TestHelper.logoutTestUser(app: app)
        app = nil
    }

    func testSearchAndViewClassDetails() throws {
        // Navigate to classes tab
        app.tabBars.buttons["Classes"].tap()

        // Search for classes
        let searchField = app.searchFields["Search classes"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("yoga")

        // Wait for results
        let firstClassCard = app.buttons.matching(identifier: "classCard").firstMatch
        XCTAssertTrue(firstClassCard.waitForExistence(timeout: 5))

        // Tap first result
        firstClassCard.tap()

        // Verify details screen
        let detailsView = app.otherElements["classDetailsView"]
        XCTAssertTrue(detailsView.waitForExistence(timeout: 3))
    }

    func testFilterClasses() throws {
        app.tabBars.buttons["Classes"].tap()

        // Open filters
        app.buttons["Filters"].tap()

        // Select a category
        app.buttons["Yoga"].tap()

        // Apply filters
        app.buttons["Apply Filters"].tap()

        // Verify filtered results
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Yoga Classes"]))
    }

    func testBookmarkClass() throws {
        app.tabBars.buttons["Classes"].tap()

        let firstClassCard = app.buttons.matching(identifier: "classCard").firstMatch
        XCTAssertTrue(firstClassCard.waitForExistence(timeout: 5))

        // Tap bookmark button
        let bookmarkButton = app.buttons.matching(identifier: "bookmarkButton").firstMatch
        bookmarkButton.tap()

        // Verify feedback
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Bookmarked"]))
    }
}
```

**File**: `NuminaUITests/GroupsFlowTests.swift`
```swift
import XCTest

final class GroupsFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        TestHelper.loginTestUser(app: app)
    }

    override func tearDownWithError() throws {
        TestHelper.logoutTestUser(app: app)
        app = nil
    }

    func testCreateGroupFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        // Tap create group button
        app.buttons["createGroupButton"].tap()

        // Fill form
        let nameField = app.textFields["groupNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test Yoga Group")

        let descriptionField = app.textViews["groupDescriptionField"]
        descriptionField.tap()
        descriptionField.typeText("A group for yoga enthusiasts")

        // Select category
        app.buttons["Yoga"].tap()

        // Submit
        app.buttons["Create Group"].tap()

        // Verify navigation to group details
        let groupTitle = app.staticTexts["Test Yoga Group"]
        XCTAssertTrue(groupTitle.waitForExistence(timeout: 5))
    }

    func testJoinGroupFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        // Tap on first group
        let firstGroup = app.buttons.matching(identifier: "groupCard").firstMatch
        XCTAssertTrue(firstGroup.waitForExistence(timeout: 5))
        firstGroup.tap()

        // Join group
        let joinButton = app.buttons["Join Group"]
        if joinButton.exists {
            joinButton.tap()

            // Verify membership
            XCTAssertTrue(TestHelper.waitForElement(app.buttons["Leave Group"]))
        }
    }

    func testCreateActivityFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        let firstGroup = app.buttons.matching(identifier: "groupCard").firstMatch
        firstGroup.tap()

        // Create activity
        app.buttons["Create Activity"].tap()

        let titleField = app.textFields["activityTitleField"]
        titleField.tap()
        titleField.typeText("Morning Yoga Session")

        let descriptionField = app.textViews["activityDescriptionField"]
        descriptionField.tap()
        descriptionField.typeText("Join us for a relaxing morning yoga session")

        // Select date
        app.buttons["Select Date"].tap()
        // Date picker interaction...

        app.buttons["Create Activity"].tap()

        // Verify activity created
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Morning Yoga Session"]))
    }
}
```

**File**: `NuminaUITests/MessagingFlowTests.swift`
```swift
import XCTest

final class MessagingFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        TestHelper.loginTestUser(app: app)
    }

    override func tearDownWithError() throws {
        TestHelper.logoutTestUser(app: app)
        app = nil
    }

    func testSendMessageFlow() throws {
        app.tabBars.buttons["Messages"].tap()

        // Tap on first conversation
        let firstConversation = app.buttons.matching(identifier: "conversationItem").firstMatch
        XCTAssertTrue(firstConversation.waitForExistence(timeout: 5))
        firstConversation.tap()

        // Send message
        let messageField = app.textFields["messageInput"]
        XCTAssertTrue(messageField.waitForExistence(timeout: 2))
        messageField.tap()
        messageField.typeText("Test message")

        app.buttons["sendButton"].tap()

        // Verify message appears
        let sentMessage = app.staticTexts["Test message"]
        XCTAssertTrue(sentMessage.waitForExistence(timeout: 3))
    }

    func testStartNewConversationFlow() throws {
        app.tabBars.buttons["Messages"].tap()

        app.buttons["New Chat"].tap()

        // Search for user
        let searchField = app.searchFields["Search users"]
        searchField.tap()
        searchField.typeText("Test User")

        // Select user
        let userResult = app.buttons.matching(identifier: "userSearchResult").firstMatch
        XCTAssertTrue(userResult.waitForExistence(timeout: 3))
        userResult.tap()

        // Verify conversation started
        let messageField = app.textFields["messageInput"]
        XCTAssertTrue(messageField.waitForExistence(timeout: 2))
    }
}
```

**File**: `NuminaUITests/SocialFlowTests.swift`
```swift
import XCTest

final class SocialFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        TestHelper.loginTestUser(app: app)
    }

    override func tearDownWithError() throws {
        TestHelper.logoutTestUser(app: app)
        app = nil
    }

    func testViewFeedAndLikeActivity() throws {
        app.tabBars.buttons["Feed"].tap()

        // Wait for feed to load
        let firstActivity = app.buttons.matching(identifier: "activityCard").firstMatch
        XCTAssertTrue(firstActivity.waitForExistence(timeout: 5))

        // Like activity
        let likeButton = app.buttons.matching(identifier: "likeButton").firstMatch
        likeButton.tap()

        // Verify like registered
        XCTAssertTrue(likeButton.isSelected)
    }

    func testFollowUserFlow() throws {
        app.tabBars.buttons["Feed"].tap()

        // Tap on user profile
        let userAvatar = app.buttons.matching(identifier: "userAvatar").firstMatch
        userAvatar.tap()

        // Follow user
        let followButton = app.buttons["Follow"]
        if followButton.exists {
            followButton.tap()

            // Verify following
            XCTAssertTrue(TestHelper.waitForElement(app.buttons["Following"]))
        }
    }
}
```

### 2. Production Build Configuration

**File**: Update `Numina.xcodeproj/project.pbxproj` or configure in Xcode:
1. Create new configuration: Product > Scheme > Edit Scheme > Run > Build Configuration > Release
2. Set build settings for Release:
   - Swift Optimization Level: `-O` (Optimize for Speed)
   - Enable Bitcode: No
   - Strip Debug Symbols During Copy: Yes
   - Strip Swift Symbols: Yes
   - Validate Product: Yes

**File**: `Numina/Config/Config.swift`
```swift
import Foundation

enum Config {
    enum Environment {
        case development
        case production

        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }

    static var apiBaseURL: String {
        switch Environment.current {
        case .development:
            return "http://localhost:8080"
        case .production:
            return "https://api.numina.app"
        }
    }

    static var websocketURL: String {
        switch Environment.current {
        case .development:
            return "ws://localhost:8080/ws"
        case .production:
            return "wss://api.numina.app/ws"
        }
    }
}
```

### 3. App Store Configuration

**File**: `fastlane/Fastfile`
```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "Numina.xcodeproj")

    build_app(
      scheme: "Numina",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          "com.numina.app" => "Numina Production"
        }
      }
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build and upload to App Store"
  lane :release do
    increment_build_number(xcodeproj: "Numina.xcodeproj")
    increment_version_number(
      bump_type: "patch",
      xcodeproj: "Numina.xcodeproj"
    )

    build_app(
      scheme: "Numina",
      export_method: "app-store"
    )

    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      submission_information: {
        add_id_info_uses_idfa: false
      }
    )
  end

  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: "Numina",
      devices: ["iPhone 15 Pro"],
      clean: true
    )
  end

  desc "Take screenshots"
  lane :screenshots do
    capture_screenshots(
      scheme: "Numina",
      devices: [
        "iPhone 15 Pro Max",
        "iPhone 15 Pro",
        "iPhone 15",
        "iPad Pro (12.9-inch) (6th generation)"
      ]
    )
  end
end
```

**File**: `fastlane/Appfile`
```ruby
app_identifier("com.numina.app")
apple_id(ENV["APPLE_ID"])
itc_team_id(ENV["ITC_TEAM_ID"])
team_id(ENV["TEAM_ID"])
```

**File**: `fastlane/metadata/en-US/name.txt`
```
Numina - Fitness & Social
```

**File**: `fastlane/metadata/en-US/subtitle.txt`
```
Find Classes, Connect Community
```

**File**: `fastlane/metadata/en-US/description.txt`
```
Numina - Your Fitness Social Network

Discover, book, and attend fitness classes in your area while connecting with a community of like-minded fitness enthusiasts.

FEATURES:
• Browse thousands of fitness classes from top providers
• Get personalized class recommendations based on your interests
• Book classes directly through provider platforms
• Join fitness groups and coordinate activities
• Real-time messaging with other members
• Track your bookings and attendance
• Share your fitness journey and achievements
• Receive push notifications for group activities and messages

SUPPORTED ACTIVITIES:
Yoga, CrossFit, Running, Cycling, Dance, Martial Arts, Swimming, Hiking, Climbing, and more!

Whether you're a beginner or an experienced athlete, Numina helps you find the perfect class and the right community to support your fitness goals.

Download Numina today and start your fitness journey!
```

**File**: `fastlane/metadata/en-US/keywords.txt`
```
fitness,classes,workout,gym,yoga,crossfit,social,community,health
```

**File**: `fastlane/metadata/en-US/promotional_text.txt`
```
Join thousands of fitness enthusiasts! Discover classes and build your fitness community.
```

**File**: `fastlane/metadata/en-US/release_notes.txt`
```
New in this version:
- Find and book fitness classes nearby
- Connect with other fitness enthusiasts
- Join fitness groups and activities
- Real-time messaging
- Track your fitness journey
```

### 4. Build Scripts

**File**: `scripts/build-release.sh`
```bash
#!/bin/bash
set -e

echo "🏗️  Building Numina iOS Release..."

# Check for fastlane
if ! command -v fastlane &> /dev/null; then
    echo "❌ Fastlane not found. Install with: gem install fastlane"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
fastlane test

# Build and upload to TestFlight
echo "📦 Building and uploading to TestFlight..."
fastlane beta

echo "✅ Build complete and uploaded to TestFlight!"
```

**File**: `scripts/run-ui-tests.sh`
```bash
#!/bin/bash
set -e

echo "🧪 Running Numina iOS UI Tests..."

# Run UI tests
xcodebuild test \
  -project Numina.xcodeproj \
  -scheme Numina \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -testPlan NuminaUITests

echo "✅ Tests complete!"
```

**File**: `scripts/take-screenshots.sh`
```bash
#!/bin/bash
set -e

echo "📸 Taking App Store screenshots..."

fastlane screenshots

echo "✅ Screenshots saved to fastlane/screenshots/"
```

### 5. CI Configuration

**File**: `.github/workflows/ios-ci.yml`
```yaml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build-and-test:
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_15.2.app

    - name: Install dependencies
      run: |
        gem install bundler
        bundle install

    - name: Run tests
      run: fastlane test

    - name: Build app
      run: |
        xcodebuild build \
          -project Numina.xcodeproj \
          -scheme Numina \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
          CODE_SIGNING_ALLOWED=NO

    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: fastlane/test_output/
```

### 6. Documentation

**File**: `RELEASE.md`
```markdown
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
```

**File**: `Gemfile`
```ruby
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
```

## Completion Checklist
- [ ] UI test suite created with XCUITest
- [ ] Production build configuration complete
- [ ] Fastlane setup with lanes
- [ ] App Store metadata complete
- [ ] Build scripts working
- [ ] CI/CD pipeline configured
- [ ] Documentation complete
- [ ] `.task-testing-production-completed` file created

## Testing
Run unit tests:
```bash
fastlane test
```

Run UI tests:
```bash
./scripts/run-ui-tests.sh
```

Build release:
```bash
./scripts/build-release.sh
```

## Success Criteria
1. ✅ Comprehensive UI test coverage for main flows
2. ✅ Release build configuration optimized
3. ✅ App Store assets complete and professional
4. ✅ Fastlane automation functional
5. ✅ CI/CD pipeline working
6. ✅ Documentation clear and comprehensive
