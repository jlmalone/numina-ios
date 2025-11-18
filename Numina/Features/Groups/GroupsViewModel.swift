//
//  GroupsViewModel.swift
//  Numina
//
//  ViewModel for group discovery
//

import Foundation
import SwiftData
import CoreLocation

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filters
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var locationRadius: Double = 10.0 // miles
    @Published var minSize: Int?
    @Published var maxSize: Int?
    @Published var useCurrentLocation = false

    private let groupRepository: GroupRepository
    private let locationManager = LocationManager.shared

    let categories = [
        "All", "Fitness", "Yoga", "Running", "Cycling", "Swimming",
        "CrossFit", "HIIT", "Strength Training", "Sports", "Wellness",
        "Social", "Outdoor", "Dance"
    ]

    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }

    // MARK: - Load Groups

    func loadGroups(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        let filters = buildFilters()

        do {
            groups = try await groupRepository.getGroups(filters: filters, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshGroups() async {
        await loadGroups(fromCache: false)
    }

    // MARK: - Filters

    private func buildFilters() -> GroupFilters {
        var filters = GroupFilters()

        if !searchText.isEmpty {
            filters.search = searchText
        }

        if let category = selectedCategory, category != "All" {
            filters.category = category
        }

        if useCurrentLocation {
            filters.latitude = locationManager.latitude
            filters.longitude = locationManager.longitude
            filters.locationRadius = locationRadius
        }

        filters.minSize = minSize
        filters.maxSize = maxSize

        return filters
    }

    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        minSize = nil
        maxSize = nil
        useCurrentLocation = false
    }

    func hasActiveFilters() -> Bool {
        !searchText.isEmpty ||
        (selectedCategory != nil && selectedCategory != "All") ||
        minSize != nil ||
        maxSize != nil ||
        useCurrentLocation
    }

    // MARK: - Filtering Logic

    var filteredGroups: [Group] {
        groups
    }

    // MARK: - Group Actions

    func joinGroup(_ group: Group) async {
        do {
            try await groupRepository.joinGroup(id: group.id)

            // Update local state
            if let index = groups.firstIndex(where: { $0.id == group.id }) {
                groups[index].isJoined = true
                groups[index].memberCount += 1
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveGroup(_ group: Group) async {
        do {
            try await groupRepository.leaveGroup(id: group.id)

            // Update local state
            if let index = groups.firstIndex(where: { $0.id == group.id }) {
                groups[index].isJoined = false
                groups[index].memberCount = max(0, groups[index].memberCount - 1)
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
