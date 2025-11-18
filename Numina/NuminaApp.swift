//
//  NuminaApp.swift
//  Numina
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct NuminaApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var classViewModel: ClassViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    let modelContainer: ModelContainer

    init() {
        // Initialize SwiftData model container
        do {
            let schema = Schema([
                User.self,
                FitnessClass.self,
                AvailabilitySlot.self
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

        _authViewModel = StateObject(wrappedValue: authVM)
        _classViewModel = StateObject(wrappedValue: classVM)
        _profileViewModel = StateObject(wrappedValue: profileVM)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                authViewModel: authViewModel,
                classViewModel: classViewModel,
                profileViewModel: profileViewModel
            )
            .modelContainer(modelContainer)
        }
    }
}

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var classViewModel: ClassViewModel
    @ObservedObject var profileViewModel: ProfileViewModel

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
                            profileViewModel: profileViewModel
                        )
                    }
                } else {
                    MainTabView(
                        authViewModel: authViewModel,
                        classViewModel: classViewModel,
                        profileViewModel: profileViewModel
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

    var body: some View {
        TabView {
            ClassListView(viewModel: classViewModel)
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }

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

#Preview {
    ContentView(
        authViewModel: AuthViewModel(userRepository: UserRepository()),
        classViewModel: ClassViewModel(classRepository: ClassRepository()),
        profileViewModel: ProfileViewModel(userRepository: UserRepository())
    )
}
