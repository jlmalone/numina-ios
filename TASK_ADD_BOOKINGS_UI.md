# TASK: Add Bookings Calendar UI to Numina iOS App

> **IMPORTANT**: Check for `.task-bookings-ui-completed` before starting.
> **When finished**, create `.task-bookings-ui-completed` file.

## 🎯 OBJECTIVE

Build complete bookings and calendar UI using SwiftUI and EventKit.

## 📋 REQUIREMENTS

### Features

1. **Calendar Views**
   - Monthly calendar with booked classes
   - Day view with schedule
   - Week view (horizontal scroll)
   - Tap to see class details
   - Color coding by class type

2. **Bookings Management**
   - List upcoming/past bookings
   - Booking details
   - Mark attended/cancel
   - Add booking flow

3. **Reminders**
   - Reminder preferences
   - Toggle 1h/24h reminders
   - Notification permissions
   - Quiet hours

4. **Stats & Streaks**
   - Current streak widget
   - Total attended
   - Class type breakdown
   - Monthly graph
   - Achievement badges

5. **Calendar Export**
   - Export to iOS Calendar (EventKit)
   - Sync booked classes

### Files to Create

- `BookingsView.swift` - Main bookings list
- `CalendarView.swift` - Calendar views
- `BookingDetailView.swift` - Booking details
- `ReminderPreferencesView.swift` - Settings
- `AttendanceStatsView.swift` - Stats display
- `BookingCard.swift` - List item component
- `CalendarGridView.swift` - Monthly calendar
- `DayScheduleView.swift` - Day view
- `WeekScrollView.swift` - Week view
- `StreakWidget.swift` - Streak display
- `BookingsViewModel.swift` - State management
- `CalendarViewModel.swift` - Calendar state
- `AttendanceStatsViewModel.swift` - Stats logic

### API Integration

- `GET /api/v1/bookings`
- `POST /api/v1/bookings`
- `PUT /api/v1/bookings/{id}`
- `POST /api/v1/bookings/{id}/mark-attended`
- `POST /api/v1/bookings/{id}/cancel`
- `GET /api/v1/calendar/month/{yyyy-MM}`
- `GET /api/v1/calendar/export`
- `GET /api/v1/bookings/reminder-preferences`
- `PUT /api/v1/bookings/reminder-preferences`
- `GET /api/v1/bookings/stats`
- `GET /api/v1/bookings/streak`

### Local Storage

- SwiftData models for bookings
- Cache calendar data
- Offline viewing

### EventKit Integration

- Request calendar permissions
- Create events in iOS Calendar
- Sync booked classes

## ✅ ACCEPTANCE CRITERIA

- [ ] Calendar views work (month/week/day)
- [ ] Bookings list functional
- [ ] Create/cancel bookings
- [ ] Mark attended works
- [ ] Reminder preferences save
- [ ] Stats and streak display correctly
- [ ] iOS Calendar integration works
- [ ] Offline caching functional
- [ ] Dark mode supported
- [ ] iOS 15+ compatible

## 📝 DELIVERABLES

- Bookings views
- Calendar components
- ViewModels
- SwiftData models
- Repository layer
- EventKit integration
- Navigation updates
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test on simulator
3. Create `.task-bookings-ui-completed`
4. Commit: "Add bookings calendar UI with stats and streaks"
5. Push: `git push -u origin claude/add-bookings-ui`

---

**Est. Time**: 60-75 min | **Priority**: HIGH
