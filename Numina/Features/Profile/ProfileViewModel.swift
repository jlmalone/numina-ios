//
//  ProfileViewModel.swift
//  Numina
//
//  ViewModel for user profile
//

import Foundation
import SwiftData

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingProfileSetup = false

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await userRepository.getCurrentUser()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func editProfile() {
        showingProfileSetup = true
    }

    var fitnessInterestsText: String {
        guard let interests = user?.fitnessInterests, !interests.isEmpty else {
            return "No interests selected"
        }
        return interests.joined(separator: ", ")
    }

    var locationText: String {
        user?.locationName ?? "No location set"
    }

    var availabilityText: String {
        guard let slots = user?.availability, !slots.isEmpty else {
            return "No availability set"
        }
        return "\(slots.count) time slot\(slots.count == 1 ? "" : "s")"
    }
}
