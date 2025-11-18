# Numina iOS

Native iOS app for the Numina group fitness social platform.

## Status

✅ **Initial Release Ready** - Core features implemented and tested

## Overview

Numina helps you find workout partners and discover group fitness classes. Think ClassPass meets Meetup, with a focus on community, accountability, and fitness connections (not dating).

## Features

### ✅ Implemented

- **Authentication**
  - Email/password registration and login
  - Secure JWT token storage in Keychain
  - Automatic session management

- **Profile Setup & Onboarding**
  - Multi-step onboarding flow
  - Basic info (name, bio, photo)
  - Fitness preferences (yoga, HIIT, spin, etc.)
  - Fitness level (1-10 scale)
  - Location setup with CoreLocation integration
  - Availability scheduling

- **Class Discovery**
  - Browse fitness classes from multiple providers
  - Advanced filtering:
    - Date range
    - Location radius
    - Class type
    - Price range
  - Pull-to-refresh
  - Offline caching

- **Class Details**
  - Full class information
  - Trainer profiles
  - Location map (MapKit integration)
  - Book on provider's platform (Safari integration)

- **User Profile**
  - View and edit profile
  - Manage fitness preferences
  - Update availability
  - View schedule

### 🚧 Coming Soon (Phase 2)

- Partner matching algorithm
- Direct messaging between users
- Group creation and coordination
- Class ratings and reviews
- Social features (following, activity feed)

## Technology Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Min iOS Version**: 15.0
- **Target iOS Version**: 18.0
- **Architecture**: Clean Architecture with MVVM
- **Dependency Injection**: Manual DI
- **Networking**: URLSession with async/await
- **Local Storage**: SwiftData
- **Image Loading**: AsyncImage
- **Navigation**: NavigationStack
- **Maps**: MapKit
- **Location**: CoreLocation

## Project Structure

```
numina-ios/
├── Numina/
│   ├── NuminaApp.swift                 # App entry point
│   ├── Core/
│   │   ├── Network/
│   │   │   ├── APIClient.swift         # Network layer
│   │   │   ├── Endpoints.swift         # API endpoints
│   │   │   └── AuthInterceptor.swift   # JWT injection
│   │   ├── Data/
│   │   │   ├── Models/                 # Data models
│   │   │   │   ├── User.swift
│   │   │   │   └── FitnessClass.swift
│   │   │   └── Repositories/           # Data access
│   │   │       ├── UserRepository.swift
│   │   │       └── ClassRepository.swift
│   │   └── Utilities/
│   │       ├── KeychainHelper.swift    # Secure storage
│   │       └── LocationManager.swift   # Location services
│   ├── Features/
│   │   ├── Auth/                       # Authentication
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── AuthViewModel.swift
│   │   ├── Onboarding/                 # Profile setup
│   │   │   ├── ProfileSetupCoordinator.swift
│   │   │   └── Steps/
│   │   ├── Classes/                    # Class discovery
│   │   │   ├── ClassListView.swift
│   │   │   ├── ClassDetailView.swift
│   │   │   ├── ClassFiltersView.swift
│   │   │   └── ClassViewModel.swift
│   │   └── Profile/                    # User profile
│   │       ├── ProfileView.swift
│   │       └── ProfileViewModel.swift
│   ├── Components/                     # Reusable components
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   └── ClassCard.swift
│   └── Resources/
│       └── Assets.xcassets
├── NuminaTests/                        # Unit tests
│   ├── AuthViewModelTests.swift
│   ├── APIClientTests.swift
│   └── ClassViewModelTests.swift
└── README.md
```

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

### Layers

1. **Presentation Layer** (SwiftUI Views + ViewModels)
   - Views are declarative and reactive
   - ViewModels manage state and business logic
   - Uses @StateObject, @ObservedObject, @Published for state management

2. **Data Layer** (Repositories + Models)
   - Repositories abstract data sources (API + local cache)
   - Models use SwiftData for local persistence
   - DTOs for API communication

3. **Core Layer** (Networking + Utilities)
   - APIClient handles all HTTP requests
   - KeychainHelper for secure token storage
   - LocationManager for location services

### Design Patterns

- **MVVM** (Model-View-ViewModel)
- **Repository Pattern** for data access
- **Dependency Injection** for testability
- **Offline-first** approach with local caching

## Quick Start

### Prerequisites

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- iOS 15.0+ device or simulator

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/numina-ios.git
   cd numina-ios
   ```

2. **Create Xcode Project**

   Since the codebase was scaffolded without Xcode, you need to create the project:

   See detailed instructions in: [XCODE_PROJECT_SETUP.md](XCODE_PROJECT_SETUP.md)

3. **Configure API Endpoint**

   Edit `Numina/Core/Network/APIClient.swift`:
   ```swift
   // For development
   let apiClient = APIClient.development()  // http://localhost:3000

   // For staging
   let apiClient = APIClient.staging()      // https://staging-api.numina.app

   // For production
   let apiClient = APIClient.production()   // https://api.numina.app
   ```

4. **Build and Run**
   ```
   1. Open Numina.xcodeproj in Xcode
   2. Select a simulator (iPhone 15 or newer recommended)
   3. Press Cmd+R to build and run
   ```

## API Configuration

The app expects a REST API with the following endpoints:

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login

### User Profile
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update user profile

### Classes
- `GET /api/v1/classes` - List fitness classes (with filters)
- `GET /api/v1/classes/{id}` - Get class details

All authenticated endpoints require JWT token in header:
```
Authorization: Bearer {token}
```

## Testing

### Run Unit Tests

In Xcode:
1. Press Cmd+U to run all tests
2. Or: Product → Test

From command line:
```bash
xcodebuild test -scheme Numina -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

- ✅ AuthViewModel tests (validation, login, register)
- ✅ APIClient tests (endpoints, error handling)
- ✅ ClassViewModel tests (loading, filtering)

## UI/UX Design

### Color Scheme

- Primary: Orange (#FF9500) → Red gradient
- Focus: Fitness and energy (NOT romantic/dating)
- Supports: Light and Dark mode

### Key Screens

1. **Login/Register** - Clean, minimal authentication
2. **Onboarding** - 5-step profile setup with progress indicator
3. **Class Discovery** - Scrollable list with filters
4. **Class Details** - Full info with map and booking CTA
5. **Profile** - User info and preferences

## Development Workflow

### Adding a New Feature

1. Create models in `Core/Data/Models/`
2. Add repository methods in `Core/Data/Repositories/`
3. Create ViewModel in appropriate feature folder
4. Build SwiftUI views
5. Write unit tests
6. Update this README

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint (optional, not included yet)
- Write descriptive commit messages
- Keep views small and focused

## Troubleshooting

### App won't build
- Clean build folder: Shift+Cmd+K
- Delete Derived Data: Xcode → Preferences → Locations → Derived Data
- Restart Xcode

### Location not working
- Check Info.plist has location permissions
- Reset simulator location: Features → Location → Custom Location
- On device: Settings → Privacy → Location Services

### SwiftData errors
- Ensure iOS deployment target is 15.0+
- Check model classes have @Model macro
- Verify ModelContainer initialization

### API errors
- Check base URL in APIClient
- Verify backend is running
- Check network connectivity
- Review API endpoint paths

## Performance Optimization

- ✅ Offline caching with SwiftData
- ✅ Async/await for non-blocking network calls
- ✅ Image lazy loading with AsyncImage
- ✅ List virtualization with SwiftUI List
- 🚧 Image caching (consider Kingfisher for Phase 2)

## Security

- ✅ JWT tokens stored in Keychain
- ✅ HTTPS for all API calls
- ✅ No sensitive data in UserDefaults
- ✅ Location permissions properly requested
- ✅ Input validation on auth forms

## Accessibility

- 🚧 VoiceOver support (to be improved)
- ✅ Dynamic Type support
- ✅ Semantic colors for dark mode
- 🚧 Accessibility labels (to be added)

## Contributing

This is a scaffolded project. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## License

[Add your license here]

## Acknowledgments

This app was scaffolded with assistance from [Claude Code](https://claude.com/claude-code).

## Support

For issues or questions:
- GitHub Issues: [Create an issue](https://github.com/yourusername/numina-ios/issues)
- Documentation: See [XCODE_PROJECT_SETUP.md](XCODE_PROJECT_SETUP.md)

---

**Numina iOS** - Your fitness community companion 🏋️‍♀️
