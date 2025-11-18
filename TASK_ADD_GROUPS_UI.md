# TASK: Add Groups UI to Numina iOS App

> **IMPORTANT**: Check for `.task-groups-ui-completed` before starting.
> **When finished**, create `.task-groups-ui-completed` file.

## 🎯 OBJECTIVE

Build group discovery, creation, and management interfaces with SwiftUI.

## 📋 REQUIREMENTS

### Features
1. **Groups Discovery**
   - Browse public groups
   - Filter by category, location, size
   - Search groups
   - Recommended groups

2. **Group Details**
   - Group info, members, activities
   - Join/leave actions
   - Invite members

3. **Group Creation**
   - Multi-step form
   - Photo picker
   - Category selection

4. **Group Activities**
   - List activities
   - Create activity
   - RSVP system
   - Link to fitness classes

### Files
- `GroupsView.swift` - Browse groups
- `GroupDetailView.swift` - Group details
- `CreateGroupView.swift` - Create group
- `GroupMembersView.swift` - Member list
- `GroupActivityView.swift` - Activity details
- `CreateActivityView.swift` - New activity
- `GroupsViewModel.swift` - State management
- `GroupDetailViewModel.swift` - Group details

### API Integration
- `GET /api/v1/groups` - List/search
- `POST /api/v1/groups` - Create
- `POST /api/v1/groups/{id}/join` - Join
- `GET /api/v1/groups/{id}/activities` - Activities
- `POST /api/v1/groups/{id}/activities/{aid}/rsvp` - RSVP

### Local Storage
- SwiftData models for groups/activities
- Offline caching

## ✅ ACCEPTANCE CRITERIA

- [ ] Groups discovery works
- [ ] Group creation flow complete
- [ ] Join/leave functional
- [ ] Activity RSVP works
- [ ] Dark mode supported
- [ ] iOS 15+ compatible

## 📝 DELIVERABLES

- Group views and components
- ViewModels
- SwiftData models
- Repository
- Navigation
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test
3. Create `.task-groups-ui-completed`
4. Commit: "Add groups UI with discovery and management"
5. Push: `git push -u origin claude/add-groups-ui`

---

**Est. Time**: 75-90 min | **Priority**: HIGH
