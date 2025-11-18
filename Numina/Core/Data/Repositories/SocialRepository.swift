//
//  SocialRepository.swift
//  Numina
//
//  Repository for social data operations
//

import Foundation
import SwiftData

final class SocialRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Feed

    func getFeed(page: Int = 1, limit: Int = 20, fromCache: Bool = false) async throws -> FeedResponse {
        if fromCache {
            if let cachedActivities = try getCachedActivities() {
                return FeedResponse(
                    activities: cachedActivities.map { $0.toDTO() },
                    total: cachedActivities.count,
                    page: 1,
                    limit: cachedActivities.count
                )
            }
        }

        let response: FeedResponse = try await apiClient.request(
            endpoint: .getFeed(page: page, limit: limit)
        )

        // Cache activities
        try await cacheActivities(response.activities.map { $0.toModel() })

        return response
    }

    func likeActivity(activityId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: .likeActivity(activityId: activityId)
        )

        // Update cached activity
        try await updateActivityLikeStatus(activityId: activityId, isLiked: true)
    }

    func unlikeActivity(activityId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: .unlikeActivity(activityId: activityId)
        )

        // Update cached activity
        try await updateActivityLikeStatus(activityId: activityId, isLiked: false)
    }

    func commentOnActivity(activityId: String, text: String) async throws -> Comment {
        let request = CommentRequest(text: text)
        let commentDTO: CommentDTO = try await apiClient.request(
            endpoint: .commentOnActivity(activityId: activityId),
            body: request
        )

        return commentDTO.toModel()
    }

    func getActivityComments(activityId: String) async throws -> [Comment] {
        let response: CommentsResponse = try await apiClient.request(
            endpoint: .getActivityComments(activityId: activityId)
        )

        return response.comments.map { $0.toModel() }
    }

    // MARK: - User Discovery

    func discoverUsers(filters: UserSearchFilters? = nil) async throws -> DiscoverUsersResponse {
        let response: DiscoverUsersResponse = try await apiClient.request(
            endpoint: .discoverUsers(filters: filters)
        )

        return response
    }

    // MARK: - User Profile

    func getUserProfile(userId: String, fromCache: Bool = false) async throws -> SocialProfile {
        if fromCache, let cachedProfile = try getCachedProfile(userId: userId) {
            return cachedProfile
        }

        let profileDTO: SocialProfileDTO = try await apiClient.request(
            endpoint: .getUserProfile(userId: userId)
        )
        let profile = profileDTO.toModel()

        // Cache profile
        try await cacheProfile(profile)

        return profile
    }

    // MARK: - Following System

    func followUser(userId: String) async throws {
        let _: FollowResponse = try await apiClient.request(
            endpoint: .followUser(userId: userId)
        )

        // Update cached profile
        try await updateFollowStatus(userId: userId, isFollowing: true)
    }

    func unfollowUser(userId: String) async throws {
        let _: FollowResponse = try await apiClient.request(
            endpoint: .unfollowUser(userId: userId)
        )

        // Update cached profile
        try await updateFollowStatus(userId: userId, isFollowing: false)
    }

    func getFollowers(userId: String) async throws -> [SocialProfile] {
        let response: FollowListResponse = try await apiClient.request(
            endpoint: .getFollowers(userId: userId)
        )

        return response.users.map { $0.toModel() }
    }

    func getFollowing(userId: String) async throws -> [SocialProfile] {
        let response: FollowListResponse = try await apiClient.request(
            endpoint: .getFollowing(userId: userId)
        )

        return response.users.map { $0.toModel() }
    }

    // MARK: - Local Cache - Activities

    @MainActor
    private func cacheActivities(_ activities: [Activity]) throws {
        guard let context = modelContext else { return }

        for activity in activities {
            // Check if activity already exists
            let descriptor = FetchDescriptor<Activity>(
                predicate: #Predicate { $0.id == activity.id }
            )
            let existing = try context.fetch(descriptor)

            if existing.isEmpty {
                context.insert(activity)
            } else {
                // Update existing
                if let existingActivity = existing.first {
                    existingActivity.likesCount = activity.likesCount
                    existingActivity.commentsCount = activity.commentsCount
                    existingActivity.isLiked = activity.isLiked
                }
            }
        }

        try context.save()
    }

    private func getCachedActivities() throws -> [Activity]? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let activities = try context.fetch(descriptor)
        return activities.isEmpty ? nil : activities
    }

    @MainActor
    private func updateActivityLikeStatus(activityId: String, isLiked: Bool) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate { $0.id == activityId }
        )
        let activities = try context.fetch(descriptor)

        if let activity = activities.first {
            activity.isLiked = isLiked
            activity.likesCount += isLiked ? 1 : -1
            try context.save()
        }
    }

    // MARK: - Local Cache - Profiles

    @MainActor
    private func cacheProfile(_ profile: SocialProfile) throws {
        guard let context = modelContext else { return }

        // Check if profile already exists
        let descriptor = FetchDescriptor<SocialProfile>(
            predicate: #Predicate { $0.id == profile.id }
        )
        let existing = try context.fetch(descriptor)

        if existing.isEmpty {
            context.insert(profile)
        } else {
            // Update existing
            if let existingProfile = existing.first {
                existingProfile.name = profile.name
                existingProfile.bio = profile.bio
                existingProfile.photoURL = profile.photoURL
                existingProfile.fitnessInterests = profile.fitnessInterests
                existingProfile.fitnessLevel = profile.fitnessLevel
                existingProfile.locationName = profile.locationName
                existingProfile.followersCount = profile.followersCount
                existingProfile.followingCount = profile.followingCount
                existingProfile.classesAttended = profile.classesAttended
                existingProfile.isFollowing = profile.isFollowing
                existingProfile.isFollowedBy = profile.isFollowedBy
                existingProfile.isMutualConnection = profile.isMutualConnection
                existingProfile.updatedAt = profile.updatedAt
            }
        }

        try context.save()
    }

    private func getCachedProfile(userId: String) throws -> SocialProfile? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<SocialProfile>(
            predicate: #Predicate { $0.id == userId }
        )
        let profiles = try context.fetch(descriptor)
        return profiles.first
    }

    @MainActor
    private func updateFollowStatus(userId: String, isFollowing: Bool) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<SocialProfile>(
            predicate: #Predicate { $0.id == userId }
        )
        let profiles = try context.fetch(descriptor)

        if let profile = profiles.first {
            profile.isFollowing = isFollowing
            profile.followersCount += isFollowing ? 1 : -1
            try context.save()
        }
    }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}
