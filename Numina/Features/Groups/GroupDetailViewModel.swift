//
//  GroupDetailViewModel.swift
//  Numina
//
//  ViewModel for group details
//

import Foundation
import SwiftData

@MainActor
final class GroupDetailViewModel: ObservableObject {
    @Published var group: Group?
    @Published var members: [GroupMember] = []
    @Published var activities: [GroupActivity] = []
    @Published var isLoading = false
    @Published var isLoadingMembers = false
    @Published var isLoadingActivities = false
    @Published var errorMessage: String?

    private let groupRepository: GroupRepository
    let groupId: String

    init(groupId: String, groupRepository: GroupRepository) {
        self.groupId = groupId
        self.groupRepository = groupRepository
    }

    // MARK: - Load Data

    func loadGroupDetails(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            group = try await groupRepository.getGroupDetails(id: groupId, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMembers(fromCache: Bool = false) async {
        isLoadingMembers = true

        do {
            members = try await groupRepository.getGroupMembers(groupId: groupId, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMembers = false
    }

    func loadActivities(fromCache: Bool = false) async {
        isLoadingActivities = true

        do {
            activities = try await groupRepository.getGroupActivities(groupId: groupId, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingActivities = false
    }

    func refreshAll() async {
        await loadGroupDetails(fromCache: false)
        await loadMembers(fromCache: false)
        await loadActivities(fromCache: false)
    }

    // MARK: - Group Actions

    func joinGroup() async {
        guard let group = group else { return }

        do {
            try await groupRepository.joinGroup(id: group.id)

            // Update local state
            self.group?.isJoined = true
            self.group?.memberCount += 1
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveGroup() async {
        guard let group = group else { return }

        do {
            try await groupRepository.leaveGroup(id: group.id)

            // Update local state
            self.group?.isJoined = false
            self.group?.memberCount = max(0, self.group!.memberCount - 1)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func inviteMember(userId: String) async {
        do {
            try await groupRepository.inviteMember(groupId: groupId, userId: userId)
            // Refresh members list
            await loadMembers()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Activity Actions

    func rsvpActivity(_ activity: GroupActivity, response: String) async {
        do {
            try await groupRepository.rsvpActivity(
                groupId: groupId,
                activityId: activity.id,
                response: response
            )

            // Update local state
            if let index = activities.firstIndex(where: { $0.id == activity.id }) {
                let oldRSVP = activities[index].userRSVP
                activities[index].userRSVP = response

                // Update RSVP count
                if oldRSVP == "yes" && response != "yes" {
                    activities[index].rsvpCount = max(0, activities[index].rsvpCount - 1)
                } else if oldRSVP != "yes" && response == "yes" {
                    activities[index].rsvpCount += 1
                }
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Properties

    var upcomingActivities: [GroupActivity] {
        activities.filter { activity in
            guard let scheduledTime = activity.scheduledTime else { return false }
            return scheduledTime > Date()
        }
    }

    var pastActivities: [GroupActivity] {
        activities.filter { activity in
            guard let scheduledTime = activity.scheduledTime else { return false }
            return scheduledTime <= Date()
        }
    }

    var admins: [GroupMember] {
        members.filter { $0.role == "admin" }
    }

    var regularMembers: [GroupMember] {
        members.filter { $0.role == "member" }
    }
}
