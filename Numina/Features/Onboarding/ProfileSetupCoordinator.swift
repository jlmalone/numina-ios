//
//  ProfileSetupCoordinator.swift
//  Numina
//
//  Coordinates multi-step profile setup flow
//

import SwiftUI
import SwiftData

enum ProfileSetupStep: Int, CaseIterable {
    case basicInfo = 0
    case fitnessPreferences = 1
    case fitnessLevel = 2
    case location = 3
    case availability = 4

    var title: String {
        switch self {
        case .basicInfo: return "Basic Info"
        case .fitnessPreferences: return "Interests"
        case .fitnessLevel: return "Fitness Level"
        case .location: return "Location"
        case .availability: return "Availability"
        }
    }

    var progress: Double {
        return Double(rawValue + 1) / Double(ProfileSetupStep.allCases.count)
    }
}

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var currentStep: ProfileSetupStep = .basicInfo
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Profile data
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var photoURL: String?

    @Published var fitnessInterests: Set<String> = []
    @Published var fitnessLevel: Double = 5

    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var locationName: String = ""

    @Published var availability: [AvailabilitySlot] = []

    private let userRepository: UserRepository
    var onComplete: (() -> Void)?

    init(userRepository: UserRepository, currentUser: User? = nil) {
        self.userRepository = userRepository

        // Pre-populate if user exists
        if let user = currentUser {
            self.name = user.name
            self.bio = user.bio ?? ""
            self.photoURL = user.photoURL
            self.fitnessInterests = Set(user.fitnessInterests)
            self.fitnessLevel = Double(user.fitnessLevel)
            self.latitude = user.latitude
            self.longitude = user.longitude
            self.locationName = user.locationName ?? ""
            self.availability = user.availability
        }
    }

    func nextStep() {
        if let nextStep = ProfileSetupStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        }
    }

    func previousStep() {
        if let previousStep = ProfileSetupStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = previousStep
            }
        }
    }

    func canProceed() -> Bool {
        switch currentStep {
        case .basicInfo:
            return !name.isEmpty
        case .fitnessPreferences:
            return !fitnessInterests.isEmpty
        case .fitnessLevel:
            return true
        case .location:
            return !locationName.isEmpty
        case .availability:
            return !availability.isEmpty
        }
    }

    func saveProfile() async {
        isLoading = true
        errorMessage = nil

        let request = UpdateProfileRequest(
            name: name,
            bio: bio.isEmpty ? nil : bio,
            photoURL: photoURL,
            fitnessInterests: Array(fitnessInterests),
            fitnessLevel: Int(fitnessLevel),
            latitude: latitude,
            longitude: longitude,
            locationName: locationName.isEmpty ? nil : locationName,
            availability: availability.map { $0.toDTO() }
        )

        do {
            _ = try await userRepository.updateProfile(request: request)
            onComplete?()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ProfileSetupCoordinator: View {
    @StateObject var viewModel: ProfileSetupViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: viewModel.currentStep.progress)
                    .tint(.orange)
                    .padding()

                // Current Step Content
                Group {
                    switch viewModel.currentStep {
                    case .basicInfo:
                        BasicInfoStep(viewModel: viewModel)
                    case .fitnessPreferences:
                        FitnessPreferencesStep(viewModel: viewModel)
                    case .fitnessLevel:
                        FitnessLevelStep(viewModel: viewModel)
                    case .location:
                        LocationStep(viewModel: viewModel)
                    case .availability:
                        AvailabilityStep(viewModel: viewModel)
                    }
                }
                .transition(.slide)

                Spacer()

                // Navigation Buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep != .basicInfo {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }

                    if viewModel.currentStep == .availability {
                        Button(action: {
                            Task {
                                await viewModel.saveProfile()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(!viewModel.canProceed() || viewModel.isLoading)
                    } else {
                        Button("Next") {
                            viewModel.nextStep()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .frame(maxWidth: .infinity)
                        .disabled(!viewModel.canProceed())
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
