//
//  UserProfileViewModel.swift
//  Numina
//
//  ViewModel for viewing user profiles
//

import Foundation
import SwiftData

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var profile: SocialProfile?
    @Published var followers: [SocialProfile] = []
    @Published var following: [SocialProfile] = []
    @Published var isLoading = false
    @Published var isLoadingFollowers = false
    @Published var isLoadingFollowing = false
    @Published var errorMessage: String?

    private let socialRepository: SocialRepository
    private var currentUserId: String?

    init(socialRepository: SocialRepository) {
        self.socialRepository = socialRepository
    }

    // MARK: - Load Profile

    func loadProfile(userId: String, fromCache: Bool = false) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentUserId = userId

        do {
            profile = try await socialRepository.getUserProfile(userId: userId, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshProfile() async {
        if let userId = currentUserId {
            await loadProfile(userId: userId, fromCache: false)
        }
    }

    // MARK: - Follow/Unfollow

    func toggleFollow() async {
        guard let profile = profile else { return }

        let previousFollowState = profile.isFollowing
        let previousFollowersCount = profile.followersCount

        // Optimistic update
        profile.isFollowing.toggle()
        profile.followersCount += profile.isFollowing ? 1 : -1

        do {
            if profile.isFollowing {
                try await socialRepository.followUser(userId: profile.id)
            } else {
                try await socialRepository.unfollowUser(userId: profile.id)
            }
        } catch {
            // Revert on error
            profile.isFollowing = previousFollowState
            profile.followersCount = previousFollowersCount
            errorMessage = "Failed to update follow status"
        }
    }

    // MARK: - Load Followers/Following

    func loadFollowers(userId: String) async {
        guard !isLoadingFollowers else { return }

        isLoadingFollowers = true

        do {
            followers = try await socialRepository.getFollowers(userId: userId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingFollowers = false
    }

    func loadFollowing(userId: String) async {
        guard !isLoadingFollowing else { return }

        isLoadingFollowing = true

        do {
            following = try await socialRepository.getFollowing(userId: userId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingFollowing = false
    }

    // MARK: - Helpers

    func clearError() {
        errorMessage = nil
    }

    func reset() {
        profile = nil
        followers = []
        following = []
        currentUserId = nil
        errorMessage = nil
    }
}
