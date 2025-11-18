# TASK: Add Push Notifications to Numina iOS App

> **IMPORTANT**: Check for `.task-notifications-ui-completed` before starting.
> **When finished**, create `.task-notifications-ui-completed` file.

## 🎯 OBJECTIVE

Implement APNs push notifications with in-app notification center.

## 📋 REQUIREMENTS

### Features
1. **APNs Integration**
   - Register for push notifications
   - Register device token with backend
   - Handle incoming notifications
   - Deep linking from notifications

2. **Notification Center**
   - In-app notification list
   - Notification types: messages, matches, groups, reminders
   - Mark as read
   - Clear all
   - Unread badge

3. **Notification Preferences**
   - Settings view for toggles
   - Per-type preferences
   - Quiet hours
   - Email fallback

4. **Notification Handling**
   - Foreground notifications (in-app alert)
   - Background notifications
   - Notification click navigation
   - Badge count updates

### Files
- `NotificationService.swift` - APNs handling
- `NotificationsView.swift` - Notification center
- `NotificationPreferencesView.swift` - Settings
- `NotificationRow.swift` - List item
- `NotificationsViewModel.swift` - State management

### API Integration
- `POST /api/v1/notifications/register-device`
- `GET /api/v1/notifications/history`
- `POST /api/v1/notifications/{id}/mark-read`
- `GET /api/v1/notifications/preferences`
- `PUT /api/v1/notifications/preferences`

### Local Storage
- SwiftData for notifications
- UserDefaults for preferences

### Permissions
- Request notification permissions
- Handle permission denied state
- Settings deep link

## ✅ ACCEPTANCE CRITERIA

- [ ] APNs receives push notifications
- [ ] Notifications display in system
- [ ] In-app center works
- [ ] Deep linking navigates correctly
- [ ] Preferences control delivery
- [ ] Unread badge accurate
- [ ] Dark mode supported

## 📝 DELIVERABLES

- Notification service
- Notification views
- ViewModels
- SwiftData models
- Permission handling
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test on device (APNs doesn't work in simulator)
3. Create `.task-notifications-ui-completed`
4. Commit: "Add push notifications with APNs"
5. Push: `git push -u origin claude/add-notifications-ui`

---

**Est. Time**: 60-75 min | **Priority**: HIGH
