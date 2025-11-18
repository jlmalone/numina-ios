# 🤖 CLAUDE CODE WEB AGENT PROMPT

> **IMPORTANT**: Before starting, check if `.agent-completed` file exists in the root directory.
> If it exists, respond: "✅ This task has already been completed. See README.md for details."
> **When finished**, create `.agent-completed` file with timestamp and summary.

---

# TASK: Build Numina iOS App

## Repository Purpose
You are working on `numina-ios`, the native iOS app for Numina - a group fitness social platform. Users create rich profiles, discover fitness classes, match with workout partners, and coordinate meetups.

## Current State
Repository initialized with basic README. Starting from scratch.

## Your Task
Create a modern iOS app with SwiftUI, following Apple's design guidelines and Clean Architecture patterns.

### Core Requirements

1. **Project Structure**
   - Swift with SwiftUI
   - Minimum iOS 15.0, Target iOS 18.0
   - Xcode project structure
   - Manual DI or Swinject
   - URLSession with async/await for networking
   - SwiftData or Core Data for persistence

2. **Feature Modules**

   **A. Authentication Flow**
   - Splash screen
   - Login screen (email + password)
   - Registration screen (email, password, name)
   - JWT token storage (Keychain)

   **B. Profile Setup Flow**
   - Multi-step onboarding (NavigationStack):
     1. Basic info (name, bio, photo)
     2. Fitness preferences (interests: yoga, HIIT, spin, etc.)
     3. Fitness level (slider 1-10)
     4. Location (use CoreLocation + manual override)
     5. Availability (select preferred days/times)
   - Save to backend via API

   **C. Class Discovery Screen**
   - List of fitness classes (List/ScrollView)
   - Filters: date range, location radius, class type, price range
   - Each class card shows: name, time, location, trainer, intensity, price
   - Tap to view class details
   - "Find Partner" button → future feature
   - Pull-to-refresh

   **D. Class Details Screen**
   - Full class information
   - Trainer bio
   - Location map (MapKit)
   - "Book on [Provider]" button → open Safari
   - "Find Workout Partner" button → future feature

3. **Backend Integration**
   - Base API URL configurable (for dev/prod)
   - URLSession with async/await
   - JWT authentication in request headers
   - API endpoints:
     - POST `/api/v1/auth/register`
     - POST `/api/v1/auth/login`
     - GET/PUT `/api/v1/users/me`
     - GET `/api/v1/classes` (with query params)
     - GET `/api/v1/classes/{id}`

4. **Local Database**
   - SwiftData (preferred) or Core Data
   - Cache user profile locally
   - Cache recently viewed classes
   - Offline-first approach where possible

5. **UI/UX Design**
   - Native iOS design with SwiftUI
   - Fitness-focused color scheme (energetic, empowering)
   - NOT romantic/dating app aesthetics - focus on community/fitness
   - Smooth animations and transitions
   - Loading states, error states, empty states
   - Support both light and dark mode

### Technical Constraints

- **Language**: Swift
- **UI**: SwiftUI
- **Min iOS**: 15.0, Target iOS: 18.0
- **Networking**: URLSession + async/await
- **Local DB**: SwiftData (or Core Data)
- **Image Loading**: AsyncImage or Kingfisher
- **Navigation**: NavigationStack
- **State**: @State, @StateObject, @ObservedObject, @Published

### File Structure
```
numina-ios/
├── Numina.xcodeproj
├── Numina/
│   ├── NuminaApp.swift
│   ├── Core/
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   ├── Endpoints.swift
│   │   │   └── AuthInterceptor.swift
│   │   ├── Data/
│   │   │   ├── Models/
│   │   │   └── Repositories/
│   │   └── Utilities/
│   │       ├── KeychainHelper.swift
│   │       └── LocationManager.swift
│   ├── Features/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── AuthViewModel.swift
│   │   ├── Onboarding/
│   │   │   ├── ProfileSetupCoordinator.swift
│   │   │   └── Steps/
│   │   ├── Classes/
│   │   │   ├── ClassListView.swift
│   │   │   ├── ClassDetailView.swift
│   │   │   └── ClassViewModel.swift
│   │   └── Profile/
│   │       ├── ProfileView.swift
│   │       └── ProfileViewModel.swift
│   ├── Components/
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   └── ClassCard.swift
│   └── Resources/
│       └── Assets.xcassets
└── README.md
```

### Acceptance Criteria

1. ✅ User can register and login successfully
2. ✅ JWT token stored securely in Keychain
3. ✅ Complete onboarding flow with all profile fields
4. ✅ Classes screen displays list of fitness classes from backend
5. ✅ Filters work correctly (date, location, type, price)
6. ✅ Class details screen shows full information with MapKit
7. ✅ External booking link opens in Safari
8. ✅ Offline caching for recently viewed content
9. ✅ Proper error handling and user feedback
10. ✅ Native iOS design with light/dark mode support
11. ✅ App builds and runs on iOS 15.0+ devices
12. ✅ Unit tests for ViewModels and network layer

### Deliverables

- Complete iOS app with all features above
- Clean Architecture implementation
- Dependency injection setup
- SwiftData/Core Data persistence
- `.gitignore` file (exclude .DS_Store, *.xcuserstate, xcuserdata/, DerivedData/)
- README with:
  - Setup instructions
  - Architecture overview
  - API configuration
  - Build and run guide
  - Screenshots (or descriptions)
- TODO.md with next features: matching, messaging, ratings

### How to Report Back

1. **Update README.md** with:
   - Quick start guide (clone, open in Xcode, run)
   - Architecture explanation (layers, modules, patterns)
   - API configuration instructions
   - Feature list with completion status
   - UI screenshots or descriptions
   - Testing instructions
   - Next steps and roadmap

2. **Create TODO.md** with prioritized features for the next phase

3. **Create `.agent-completed` file** with content:
   ```
   Completed: [timestamp]
   Summary: Numina iOS app scaffolded successfully
   Features: Auth, Onboarding, Class Discovery
   Status: All acceptance criteria met
   Build: Successful (runs in simulator)
   Next: See TODO.md
   ```

4. **Commit and push** all changes with message:
   ```
   feat: Complete iOS app with auth and class discovery

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
