# TASK: Add Social Features UI to Numina iOS App

> **IMPORTANT**: Check for `.task-social-ui-completed` before starting.
> **When finished**, create `.task-social-ui-completed` file.

## 🎯 OBJECTIVE

Build social networking: following, activity feed, user discovery with SwiftUI.

## 📋 REQUIREMENTS

### Features
1. **Activity Feed**
   - Home feed with followed users' activities
   - Like and comment
   - Pull-to-refresh
   - Pagination

2. **User Discovery**
   - Search users
   - Filter by interests, location, fitness level
   - Suggested users
   - View profiles

3. **Following System**
   - Follow/unfollow
   - Followers/following lists
   - Mutual connections

4. **User Profiles (Public)**
   - View other users' profiles
   - See stats, interests, history
   - Follow status

### Files
- `FeedView.swift` - Activity feed
- `DiscoverUsersView.swift` - User discovery
- `UserProfileView.swift` - Public profile
- `FollowersView.swift` - Followers list
- `FollowingView.swift` - Following list
- `ActivityDetailView.swift` - Activity detail
- `ActivityFeedItem.swift` - Feed item component
- `UserListRow.swift` - User list item
- `FeedViewModel.swift`
- `DiscoverViewModel.swift`
- `UserProfileViewModel.swift`

### API Integration
- `GET /api/v1/social/feed`
- `POST /api/v1/social/follow/{userId}`
- `DELETE /api/v1/social/unfollow/{userId}`
- `GET /api/v1/social/discover-users`
- `GET /api/v1/social/users/{id}/profile`
- `POST /api/v1/social/activity/{id}/like`
- `POST /api/v1/social/activity/{id}/comment`

### Local Storage
- SwiftData for feed/profiles
- Caching

## ✅ ACCEPTANCE CRITERIA

- [ ] Feed displays and updates
- [ ] Follow/unfollow works
- [ ] User discovery functional
- [ ] Like/comment works
- [ ] Public profiles viewable
- [ ] Dark mode supported

## 📝 DELIVERABLES

- Social views
- ViewModels
- SwiftData models
- Repository
- Navigation
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test
3. Create `.task-social-ui-completed`
4. Commit: "Add social features with feed and discovery"
5. Push: `git push -u origin claude/add-social-ui`

---

**Est. Time**: 75-90 min | **Priority**: MEDIUM-HIGH
