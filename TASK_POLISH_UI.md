# TASK: iOS UI Polish & Improvements

> **IMPORTANT**: Check for `.task-polish-completed` before starting.
> **When finished**, create `.task-polish-completed` file.

## 🎯 OBJECTIVE

Polish the iOS app with better loading states, error handling, and UX improvements.

## 📋 REQUIREMENTS

### 1. Skeleton Loading States

**Replace generic ProgressViews with skeleton screens**:
- Class list: Skeleton class cards
- Messages: Skeleton conversation items
- Groups: Skeleton group cards
- Feed: Skeleton activity items
- Profile: Skeleton profile layout

**Implementation**:
- Create `SkeletonView.swift` component
- Add shimmer animation (`.redacted(reason: .placeholder)`)
- Use for all loading states

### 2. Improved Error Handling

**Better error UI**:
- Rich error cards with retry buttons
- Specific error messages (network, auth, server)
- Error illustrations (SF Symbols)
- Empty state views

**Create**:
- `ErrorView.swift` with retry closure
- `NetworkErrorView.swift` for offline
- `EmptyStateView.swift` for empty lists

### 3. Pull-to-Refresh Everywhere

**Add to**:
- Class list
- Messages/conversations
- Groups list
- Activity feed
- Bookings list
- My reviews

**Use**: `.refreshable { }` modifier

### 4. Smooth Animations

**Add animations**:
- Screen transitions (slide/fade)
- List item animations
- Button press feedback
- Loading transitions
- Success/error transitions

**Use**: `.transition()`, `.animation()`, `.withAnimation {}`

### 5. Better Input Validation

**Improve forms**:
- Real-time validation
- Inline error messages
- Disable submit when invalid
- Character counts
- Clear errors on edit

**Forms**:
- Login/register
- Write review
- Create group
- Message compose
- Edit profile

### 6. Haptic Feedback

**Add on**:
- Button presses (light)
- Pull-to-refresh (medium)
- Errors (error)
- Success (success)

**Use**: `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`

### 7. Image Loading Optimization

**Improvements**:
- Add placeholder images
- Loading shimmer
- Error fallback images
- AsyncImage with proper states
- Compress uploads

### 8. Accessibility

**Add**:
- Accessibility labels for images/icons
- Semantic labels for buttons
- Proper VoiceOver support
- Dynamic Type support
- Min touch target sizes (44pt)
- Color contrast checks

### 9. Offline Indicators

**Add**:
- Network status banner
- "Offline" badge on cached data
- Disable network actions when offline
- Queue actions for reconnect

### 10. Polish Details

**Misc**:
- Badges (unread counts)
- First-time tooltips
- Consistent spacing
- Dividers where needed
- Typography hierarchy
- Status bar style theming
- Safe area handling

## ✅ ACCEPTANCE CRITERIA

- [ ] All screens have skeleton loaders
- [ ] Proper error handling with retry
- [ ] Pull-to-refresh on all lists
- [ ] Smooth animations throughout
- [ ] Real-time form validation
- [ ] Haptic feedback on interactions
- [ ] Images load with placeholders
- [ ] VoiceOver support works
- [ ] Offline state handled
- [ ] App feels native and polished

## 📝 DELIVERABLES

- Skeleton view components
- Error view components
- Pull-to-refresh integration
- Animations
- Form validation improvements
- Haptic feedback
- Accessibility labels
- Offline handling
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test on simulator
3. Create `.task-polish-completed`
4. Commit: "Polish iOS UI (loading states, errors, animations)"
5. Push: `git push -u origin claude/polish-ios-ui`

---

**Est. Time**: 60-75 min | **Priority**: MEDIUM-HIGH
