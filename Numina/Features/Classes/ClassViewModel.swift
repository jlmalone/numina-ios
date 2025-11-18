//
//  ClassViewModel.swift
//  Numina
//
//  ViewModel for class discovery
//

import Foundation
import SwiftData
import CoreLocation

@MainActor
final class ClassViewModel: ObservableObject {
    @Published var classes: [FitnessClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filters
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var selectedClassType: String?
    @Published var locationRadius: Double = 10.0 // miles
    @Published var minPrice: Double?
    @Published var maxPrice: Double?
    @Published var useCurrentLocation = false

    private let classRepository: ClassRepository
    private let locationManager = LocationManager.shared

    let classTypes = [
        "All", "Yoga", "HIIT", "Spin", "Pilates", "Boxing", "Barre",
        "CrossFit", "Running", "Cycling", "Swimming", "Dance",
        "Strength Training", "Bootcamp", "Kickboxing", "Zumba"
    ]

    init(classRepository: ClassRepository) {
        self.classRepository = classRepository
    }

    // MARK: - Load Classes

    func loadClasses(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        let filters = buildFilters()

        do {
            classes = try await classRepository.getClasses(filters: filters, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshClasses() async {
        await loadClasses(fromCache: false)
    }

    // MARK: - Filters

    private func buildFilters() -> ClassFilters {
        var filters = ClassFilters()

        filters.startDate = startDate
        filters.endDate = endDate

        if let type = selectedClassType, type != "All" {
            filters.classType = type
        }

        if useCurrentLocation {
            filters.latitude = locationManager.latitude
            filters.longitude = locationManager.longitude
            filters.locationRadius = locationRadius
        }

        filters.minPrice = minPrice
        filters.maxPrice = maxPrice

        return filters
    }

    func clearFilters() {
        startDate = nil
        endDate = nil
        selectedClassType = nil
        minPrice = nil
        maxPrice = nil
        useCurrentLocation = false
    }

    func hasActiveFilters() -> Bool {
        startDate != nil ||
        endDate != nil ||
        (selectedClassType != nil && selectedClassType != "All") ||
        minPrice != nil ||
        maxPrice != nil ||
        useCurrentLocation
    }

    // MARK: - Filtering Logic

    var filteredClasses: [FitnessClass] {
        classes
    }
}
