//
//  NuminaApp.swift
//  Numina
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct NuminaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var classViewModel: ClassViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @StateObject private var notificationService: NotificationService
    @StateObject private var notificationsViewModel: NotificationsViewModel

    let modelContainer: ModelContainer

    init() {
        // Initialize SwiftData model container
        do {
            let schema = Schema([
                User.self,
                FitnessClass.self,
                AvailabilitySlot.self,
                AppNotification.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }

        // Initialize repositories with model context
        let modelContext = ModelContext(modelContainer)
        let userRepository = UserRepository(modelContext: modelContext)
        let classRepository = ClassRepository(modelContext: modelContext)

        // Initialize view models
        let authVM = AuthViewModel(userRepository: userRepository)
        let classVM = ClassViewModel(classRepository: classRepository)
        let profileVM = ProfileViewModel(userRepository: userRepository)
        let notificationSvc = NotificationService(modelContext: modelContext)
        let notificationsVM = NotificationsViewModel(modelContext: modelContext)

        _authViewModel = StateObject(wrappedValue: authVM)
        _classViewModel = StateObject(wrappedValue: classVM)
        _profileViewModel = StateObject(wrappedValue: profileVM)
        _notificationService = StateObject(wrappedValue: notificationSvc)
        _notificationsViewModel = StateObject(wrappedValue: notificationsVM)

        // Set notification service in app delegate
        AppDelegate.notificationService = notificationSvc
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                authViewModel: authViewModel,
                classViewModel: classViewModel,
                profileViewModel: profileViewModel,
                notificationService: notificationService,
                notificationsViewModel: notificationsViewModel
            )
            .modelContainer(modelContainer)
        }
    }
}

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var classViewModel: ClassViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var notificationService: NotificationService
    @ObservedObject var notificationsViewModel: NotificationsViewModel

    @State private var showingOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if let user = authViewModel.currentUser {
                    if needsOnboarding(user: user) {
                        ProfileSetupCoordinator(
                            viewModel: ProfileSetupViewModel(
                                userRepository: UserRepository(),
                                currentUser: user
                            )
                        )
                    } else {
                        MainTabView(
                            authViewModel: authViewModel,
                            classViewModel: classViewModel,
                            profileViewModel: profileViewModel,
                            notificationService: notificationService,
                            notificationsViewModel: notificationsViewModel
                        )
                    }
                } else {
                    MainTabView(
                        authViewModel: authViewModel,
                        classViewModel: classViewModel,
                        profileViewModel: profileViewModel,
                        notificationService: notificationService,
                        notificationsViewModel: notificationsViewModel
                    )
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }

    private func needsOnboarding(user: User) -> Bool {
        // Check if user has completed basic profile setup
        return user.fitnessInterests.isEmpty ||
               user.locationName == nil ||
               user.availability.isEmpty
    }
}

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var classViewModel: ClassViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var notificationService: NotificationService
    @ObservedObject var notificationsViewModel: NotificationsViewModel

    var body: some View {
        TabView {
            ClassListView(viewModel: classViewModel)
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }

            NotificationsView(
                viewModel: notificationsViewModel,
                notificationService: notificationService
            )
            .tabItem {
                Label("Notifications", systemImage: "bell.fill")
            }
            .badge(notificationsViewModel.unreadCount > 0 ? notificationsViewModel.unreadCount : nil)

            ProfileView(
                viewModel: profileViewModel,
                authViewModel: authViewModel
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(.orange)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    static var notificationService: NotificationService?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            AppDelegate.notificationService?.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            AppDelegate.notificationService?.didFailToRegisterForRemoteNotifications(withError: error)
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: User.self, FitnessClass.self, AppNotification.self))
    ContentView(
        authViewModel: AuthViewModel(userRepository: UserRepository()),
        classViewModel: ClassViewModel(classRepository: ClassRepository()),
        profileViewModel: ProfileViewModel(userRepository: UserRepository()),
        notificationService: NotificationService(modelContext: modelContext),
        notificationsViewModel: NotificationsViewModel(modelContext: modelContext)
    )
}
