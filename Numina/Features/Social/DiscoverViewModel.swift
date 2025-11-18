//
//  DiscoverViewModel.swift
//  Numina
//
//  ViewModel for user discovery
//

import Foundation
import SwiftData
import CoreLocation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var users: [SocialProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Search and filters
    @Published var searchQuery: String = ""
    @Published var selectedInterests: [String] = []
    @Published var selectedFitnessLevel: Int?
    @Published var useLocationFilter = false
    @Published var locationRadius: Double = 10.0 // miles

    private let socialRepository: SocialRepository
    private let locationManager = LocationManager.shared

    let fitnessInterests = [
        "Yoga", "HIIT", "Spin", "Pilates", "Boxing", "Barre",
        "CrossFit", "Running", "Cycling", "Swimming", "Dance",
        "Strength Training", "Bootcamp", "Kickboxing", "Zumba"
    ]

    init(socialRepository: SocialRepository) {
        self.socialRepository = socialRepository
    }

    // MARK: - Search Users

    func searchUsers() async {
        isLoading = true
        errorMessage = nil

        let filters = buildFilters()

        do {
            let response = try await socialRepository.discoverUsers(filters: filters)
            users = response.users.map { $0.toModel() }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearSearch() {
        searchQuery = ""
        selectedInterests = []
        selectedFitnessLevel = nil
        useLocationFilter = false
        users = []
    }

    // MARK: - Follow/Unfollow

    func toggleFollow(user: SocialProfile) async {
        let previousFollowState = user.isFollowing
        let previousFollowersCount = user.followersCount

        // Optimistic update
        user.isFollowing.toggle()
        user.followersCount += user.isFollowing ? 1 : -1

        do {
            if user.isFollowing {
                try await socialRepository.followUser(userId: user.id)
            } else {
                try await socialRepository.unfollowUser(userId: user.id)
            }
        } catch {
            // Revert on error
            user.isFollowing = previousFollowState
            user.followersCount = previousFollowersCount
            errorMessage = "Failed to update follow status"
        }
    }

    // MARK: - Filters

    private func buildFilters() -> UserSearchFilters {
        let locationFilter: LocationFilterDTO?
        if useLocationFilter,
           let lat = locationManager.latitude,
           let lon = locationManager.longitude {
            locationFilter = LocationFilterDTO(
                latitude: lat,
                longitude: lon,
                radiusMiles: locationRadius
            )
        } else {
            locationFilter = nil
        }

        return UserSearchFilters(
            query: searchQuery.isEmpty ? nil : searchQuery,
            fitnessInterests: selectedInterests.isEmpty ? nil : selectedInterests,
            fitnessLevel: selectedFitnessLevel,
            location: locationFilter,
            page: 1,
            limit: 50
        )
    }

    func hasActiveFilters() -> Bool {
        !searchQuery.isEmpty ||
        !selectedInterests.isEmpty ||
        selectedFitnessLevel != nil ||
        useLocationFilter
    }

    // MARK: - Helpers

    func clearError() {
        errorMessage = nil
    }
}
