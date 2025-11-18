//
//  GroupRepository.swift
//  Numina
//
//  Repository for group data operations
//

import Foundation
import SwiftData

final class GroupRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Fetch Groups

    func getGroups(filters: GroupFilters? = nil, fromCache: Bool = false) async throws -> [Group] {
        if fromCache {
            return try getCachedGroups()
        }

        let response: GroupListResponse = try await apiClient.request(
            endpoint: .getGroups(filters: filters)
        )

        let groups = response.groups.map { $0.toModel() }

        // Cache groups
        try await cacheGroups(groups)

        return groups
    }

    func getGroupDetails(id: String, fromCache: Bool = false) async throws -> Group {
        if fromCache, let cachedGroup = try getCachedGroup(id: id) {
            return cachedGroup
        }

        let groupDTO: GroupDTO = try await apiClient.request(
            endpoint: .getGroupDetails(id: id)
        )

        let group = groupDTO.toModel()

        // Add to cache
        try await cacheGroup(group)

        return group
    }

    // MARK: - Group Actions

    func createGroup(request: CreateGroupRequest) async throws -> Group {
        let groupDTO: GroupDTO = try await apiClient.request(
            endpoint: .createGroup,
            body: request
        )

        let group = groupDTO.toModel()
        try await cacheGroup(group)

        return group
    }

    func joinGroup(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: .joinGroup(id: id)
        )

        // Update cached group
        if var group = try getCachedGroup(id: id) {
            group.isJoined = true
            group.memberCount += 1
            try await cacheGroup(group)
        }
    }

    func leaveGroup(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: .leaveGroup(id: id)
        )

        // Update cached group
        if var group = try getCachedGroup(id: id) {
            group.isJoined = false
            group.memberCount = max(0, group.memberCount - 1)
            try await cacheGroup(group)
        }
    }

    // MARK: - Group Members

    func getGroupMembers(groupId: String, fromCache: Bool = false) async throws -> [GroupMember] {
        if fromCache {
            return try getCachedMembers(groupId: groupId)
        }

        let response: GroupMemberListResponse = try await apiClient.request(
            endpoint: .getGroupMembers(id: groupId)
        )

        let members = response.members.map { $0.toModel(groupId: groupId) }

        // Cache members
        try await cacheMembers(members, groupId: groupId)

        return members
    }

    func inviteMember(groupId: String, userId: String) async throws {
        struct InviteRequest: Codable {
            let userId: String
        }

        let _: EmptyResponse = try await apiClient.request(
            endpoint: .inviteMember(groupId: groupId),
            body: InviteRequest(userId: userId)
        )
    }

    // MARK: - Group Activities

    func getGroupActivities(groupId: String, fromCache: Bool = false) async throws -> [GroupActivity] {
        if fromCache {
            return try getCachedActivities(groupId: groupId)
        }

        let response: GroupActivityListResponse = try await apiClient.request(
            endpoint: .getGroupActivities(groupId: groupId)
        )

        let activities = response.activities.map { $0.toModel(groupId: groupId) }

        // Cache activities
        try await cacheActivities(activities, groupId: groupId)

        return activities
    }

    func getActivityDetails(groupId: String, activityId: String, fromCache: Bool = false) async throws -> GroupActivity {
        if fromCache, let cachedActivity = try getCachedActivity(id: activityId) {
            return cachedActivity
        }

        let activityDTO: GroupActivityDTO = try await apiClient.request(
            endpoint: .getActivityDetails(groupId: groupId, activityId: activityId)
        )

        let activity = activityDTO.toModel(groupId: groupId)

        // Add to cache
        try await cacheActivity(activity)

        return activity
    }

    func createActivity(groupId: String, request: CreateActivityRequest) async throws -> GroupActivity {
        let activityDTO: GroupActivityDTO = try await apiClient.request(
            endpoint: .createActivity(groupId: groupId),
            body: request
        )

        let activity = activityDTO.toModel(groupId: groupId)
        try await cacheActivity(activity)

        return activity
    }

    func rsvpActivity(groupId: String, activityId: String, response: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: .rsvpActivity(groupId: groupId, activityId: activityId),
            body: RSVPRequest(response: response)
        )

        // Update cached activity
        if var activity = try getCachedActivity(id: activityId) {
            let oldRSVP = activity.userRSVP
            activity.userRSVP = response

            // Update RSVP count
            if oldRSVP == "yes" && response != "yes" {
                activity.rsvpCount = max(0, activity.rsvpCount - 1)
            } else if oldRSVP != "yes" && response == "yes" {
                activity.rsvpCount += 1
            }

            try await cacheActivity(activity)
        }
    }

    // MARK: - Local Cache - Groups

    @MainActor
    private func cacheGroups(_ groups: [Group]) throws {
        guard let context = modelContext else { return }

        // Clear existing groups
        try clearCachedGroups()

        // Insert new groups
        for group in groups {
            context.insert(group)
        }

        try context.save()
    }

    @MainActor
    private func cacheGroup(_ group: Group) throws {
        guard let context = modelContext else { return }

        // Check if group already exists
        let descriptor = FetchDescriptor<Group>(
            predicate: #Predicate { $0.id == group.id }
        )

        let existing = try context.fetch(descriptor)

        // Remove existing
        for existingGroup in existing {
            context.delete(existingGroup)
        }

        // Insert new
        context.insert(group)
        try context.save()
    }

    private func getCachedGroups() throws -> [Group] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Group>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func getCachedGroup(id: String) throws -> Group? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<Group>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func clearCachedGroups() throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Group>()
        let groups = try context.fetch(descriptor)

        for group in groups {
            context.delete(group)
        }

        try context.save()
    }

    // MARK: - Local Cache - Members

    @MainActor
    private func cacheMembers(_ members: [GroupMember], groupId: String) throws {
        guard let context = modelContext else { return }

        // Clear existing members for this group
        try clearCachedMembers(groupId: groupId)

        // Insert new members
        for member in members {
            context.insert(member)
        }

        try context.save()
    }

    private func getCachedMembers(groupId: String) throws -> [GroupMember] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<GroupMember>(
            predicate: #Predicate { $0.groupId == groupId },
            sortBy: [SortDescriptor(\.joinedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    private func clearCachedMembers(groupId: String) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<GroupMember>(
            predicate: #Predicate { $0.groupId == groupId }
        )
        let members = try context.fetch(descriptor)

        for member in members {
            context.delete(member)
        }

        try context.save()
    }

    // MARK: - Local Cache - Activities

    @MainActor
    private func cacheActivities(_ activities: [GroupActivity], groupId: String) throws {
        guard let context = modelContext else { return }

        // Clear existing activities for this group
        try clearCachedActivities(groupId: groupId)

        // Insert new activities
        for activity in activities {
            context.insert(activity)
        }

        try context.save()
    }

    @MainActor
    private func cacheActivity(_ activity: GroupActivity) throws {
        guard let context = modelContext else { return }

        // Check if activity already exists
        let descriptor = FetchDescriptor<GroupActivity>(
            predicate: #Predicate { $0.id == activity.id }
        )

        let existing = try context.fetch(descriptor)

        // Remove existing
        for existingActivity in existing {
            context.delete(existingActivity)
        }

        // Insert new
        context.insert(activity)
        try context.save()
    }

    private func getCachedActivities(groupId: String) throws -> [GroupActivity] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<GroupActivity>(
            predicate: #Predicate { $0.groupId == groupId },
            sortBy: [SortDescriptor(\.scheduledTime, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    private func getCachedActivity(id: String) throws -> GroupActivity? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<GroupActivity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func clearCachedActivities(groupId: String) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<GroupActivity>(
            predicate: #Predicate { $0.groupId == groupId }
        )
        let activities = try context.fetch(descriptor)

        for activity in activities {
            context.delete(activity)
        }

        try context.save()
    }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}
