# Numina iOS - Roadmap & TODO

## Phase 2: Social & Matching Features

### 🎯 High Priority

#### Partner Matching Algorithm
- [ ] Create matching engine based on:
  - Fitness interests overlap
  - Skill level compatibility
  - Location proximity
  - Schedule alignment
- [ ] MatchViewModel for managing matches
- [ ] MatchListView to browse potential partners
- [ ] Match details view with compatibility score
- [ ] "Request to Match" flow with notifications
- [ ] Accept/decline match requests

#### Direct Messaging
- [ ] Chat data models (Message, Conversation)
- [ ] Real-time messaging (WebSocket or polling)
- [ ] ConversationListView
- [ ] ChatView with message bubbles
- [ ] Push notifications for new messages
- [ ] Message status (sent, delivered, read)
- [ ] Image sharing in chats

#### Group Creation & Coordination
- [ ] Group model (name, members, classes, schedule)
- [ ] Create group flow
- [ ] Invite members to group
- [ ] Group chat
- [ ] Shared class calendar
- [ ] Group profile page
- [ ] Leave/delete group functionality

### 🎨 Medium Priority

#### Class Ratings & Reviews
- [ ] Rating model (1-5 stars, review text)
- [ ] Submit review after class
- [ ] Display reviews on class details
- [ ] Review moderation flags
- [ ] Average rating display
- [ ] Sort/filter by rating

#### Enhanced Discovery
- [ ] "Classes Your Matches Are Attending" feed
- [ ] Trending classes
- [ ] Personalized recommendations
- [ ] Save/bookmark favorite classes
- [ ] Class history/past bookings
- [ ] "Find classes with open spots"

#### Social Features
- [ ] User following/followers
- [ ] Activity feed (friends' bookings, reviews)
- [ ] User search
- [ ] Share class to social media
- [ ] Invite friends (SMS/email)
- [ ] Leaderboards/challenges

### 🔧 Low Priority / Nice-to-Have

#### UI/UX Improvements
- [ ] Onboarding tutorial/walkthrough
- [ ] Empty state illustrations
- [ ] Skeleton loading screens
- [ ] Custom animations and transitions
- [ ] Haptic feedback
- [ ] Dark mode refinements
- [ ] iPad optimization
- [ ] Accessibility improvements (VoiceOver labels)

#### Performance & Optimization
- [ ] Image caching with Kingfisher/SDWebImage
- [ ] Pagination for class lists
- [ ] Infinite scroll
- [ ] Background refresh
- [ ] Memory optimization
- [ ] Network request caching strategy

#### User Experience
- [ ] Password reset flow
- [ ] Email verification
- [ ] Profile photo upload from camera/library
- [ ] Edit profile inline
- [ ] Delete account
- [ ] Export user data (GDPR)
- [ ] Multiple location support

#### Analytics & Monitoring
- [ ] Analytics integration (Firebase/Mixpanel)
- [ ] Crash reporting (Crashlytics/Sentry)
- [ ] Performance monitoring
- [ ] User behavior tracking
- [ ] A/B testing framework

#### Advanced Features
- [ ] Apple Sign In
- [ ] Google Sign In
- [ ] Touch ID / Face ID for login
- [ ] Calendar integration (add classes to Calendar)
- [ ] Reminders/notifications for upcoming classes
- [ ] Apple Watch companion app
- [ ] Widget for upcoming classes
- [ ] Siri Shortcuts

## Phase 3: Business & Growth

### Monetization
- [ ] In-app subscriptions (premium features)
- [ ] Commission on class bookings
- [ ] Partner/studio accounts
- [ ] Featured class promotions
- [ ] Referral rewards program

### Admin & Moderation
- [ ] Admin dashboard (web or separate app)
- [ ] Content moderation tools
- [ ] User report/block functionality
- [ ] Analytics dashboard
- [ ] Studio/trainer verification

### Platform Expansion
- [ ] Android app (React Native or native)
- [ ] Web app (React/Vue)
- [ ] API for third-party integrations
- [ ] Public API documentation

## Technical Debt & Refactoring

### Code Quality
- [ ] Add SwiftLint configuration
- [ ] Increase test coverage to >80%
- [ ] Add integration tests
- [ ] Add UI tests with XCTest
- [ ] Code documentation (DocC)
- [ ] API documentation

### Architecture Improvements
- [ ] Consider Swinject for DI
- [ ] Add Use Cases layer (Clean Architecture)
- [ ] Repository caching strategy refinement
- [ ] Error handling improvements
- [ ] Logging framework

### DevOps
- [ ] CI/CD pipeline (GitHub Actions/Fastlane)
- [ ] Automated testing
- [ ] Automated deployments to TestFlight
- [ ] Code signing automation
- [ ] App Store screenshots automation

## Bug Fixes & Issues

### Known Issues
- [ ] Handle network timeout gracefully
- [ ] Improve error messages for API failures
- [ ] Fix potential memory leaks in image loading
- [ ] Handle large datasets better (pagination)

### Future Considerations
- [ ] Localization (i18n) for multiple languages
- [ ] RTL language support
- [ ] Accessibility audit
- [ ] Security audit
- [ ] Performance profiling

## Documentation

- [x] README with setup instructions
- [x] Architecture overview
- [x] API documentation (basic)
- [ ] Contributing guidelines
- [ ] Code style guide
- [ ] Release process documentation
- [ ] User guide/help center

---

## Priority Order for Next Sprint

1. **Partner Matching Algorithm** - Core feature for MVP
2. **Direct Messaging** - Essential for user engagement
3. **Group Creation** - Key differentiator
4. **Ratings & Reviews** - Build trust and quality
5. **Enhanced Discovery** - Improve retention
6. **Social Features** - Viral growth

## Notes

- Focus on stability and UX before adding too many features
- Gather user feedback early and often
- Consider beta testing program
- Monitor app performance and crash rates
- Keep accessibility in mind for all new features

---

Last Updated: 2025-11-18
