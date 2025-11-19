# Task: Add Gamification UI

> **IMPORTANT**: Check for `.task-gamification-ui-completed` before starting.
> If it exists, respond: "✅ This task has already been implemented."
> **When finished**, create `.task-gamification-ui-completed` file.

## Overview
Add comprehensive gamification UI including achievements, challenges, leaderboards, and user statistics using SwiftUI.

## Requirements

### 1. Data Models

Create models matching the backend API in `Numina/Models/`:
- `Achievement.swift`, `UserAchievement.swift`
- `Challenge.swift`, `UserChallenge.swift`
- `UserStats.swift`, `LeaderboardEntry.swift`

### 2. API Service

**File**: `Numina/Services/GamificationService.swift`
```swift
class GamificationService {
    func getAchievements() async throws -> [Achievement]
    func getUserAchievements() async throws -> [UserAchievement]
    func getActiveChallenges() async throws -> [Challenge]
    func joinChallenge(_ id: String) async throws
    func getUserChallenges() async throws -> [Challenge]
    func getUserStats() async throws -> UserStats
    func getLeaderboard(type: String, period: String) async throws -> [LeaderboardEntry]
}
```

### 3. Achievements View

**File**: `Numina/Features/Gamification/AchievementsView.swift`
- Display all achievements grouped by category
- Show locked/unlocked state with visual distinction
- Display progress bars for in-progress achievements
- Show tier badges (Bronze, Silver, Gold, Platinum)

### 4. Challenges View

**File**: `Numina/Features/Gamification/ChallengesView.swift`
- Tab view: "Available" and "My Challenges"
- Display challenge cards with:
  - Title, description, image
  - Goal and progress
  - Date range
  - Points reward
  - Join button
- Challenge detail view with full information

### 5. Leaderboards View

**File**: `Numina/Features/Gamification/LeaderboardsView.swift`
- Segmented control for type: Points, Streak, Classes, Challenges
- Filter chips for period: Weekly, Monthly, All-Time
- List of leaderboard entries with:
  - Rank number
  - User avatar and name
  - Score/value
  - Highlight current user

### 6. Stats Dashboard

**File**: `Numina/Features/Gamification/StatsView.swift`
- Display user statistics in cards:
  - Total Points
  - Classes Attended
  - Current/Longest Streak
  - Achievements Count
  - Challenges Completed
  - Distance & Calories
- Visual indicators and charts if possible

### 7. Navigation

Add to main tab view or navigation:
```swift
NavigationLink("Achievements", destination: AchievementsView())
NavigationLink("Challenges", destination: ChallengesView())
NavigationLink("Leaderboards", destination: LeaderboardsView())
NavigationLink("Stats", destination: StatsView())
```

## Completion Checklist
- [ ] All models created
- [ ] API service implemented
- [ ] Achievements view complete with category grouping
- [ ] Challenges view with tabs functional
- [ ] Leaderboards view with filtering
- [ ] Stats dashboard comprehensive
- [ ] Navigation integrated
- [ ] Proper error handling
- [ ] `.task-gamification-ui-completed` file created

## Success Criteria
1. ✅ All gamification features accessible
2. ✅ Clean SwiftUI implementation
3. ✅ Proper data flow and state management
4. ✅ Visual polish matching app design
