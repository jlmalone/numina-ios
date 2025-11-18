//
//  ClassRepository.swift
//  Numina
//
//  Repository for fitness class data operations
//

import Foundation
import SwiftData

final class ClassRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Fetch Classes

    func getClasses(filters: ClassFilters? = nil, fromCache: Bool = false) async throws -> [FitnessClass] {
        if fromCache {
            return try getCachedClasses()
        }

        let response: ClassListResponse = try await apiClient.request(
            endpoint: .getClasses(filters: filters)
        )

        let classes = response.classes.map { $0.toModel() }

        // Cache classes
        try await cacheClasses(classes)

        return classes
    }

    func getClassDetails(id: String, fromCache: Bool = false) async throws -> FitnessClass {
        if fromCache, let cachedClass = try getCachedClass(id: id) {
            return cachedClass
        }

        let classDTO: FitnessClassDTO = try await apiClient.request(
            endpoint: .getClassDetails(id: id)
        )

        let fitnessClass = classDTO.toModel()

        // Add to cache
        try await cacheClass(fitnessClass)

        return fitnessClass
    }

    // MARK: - Local Cache

    @MainActor
    private func cacheClasses(_ classes: [FitnessClass]) throws {
        guard let context = modelContext else { return }

        // Clear existing classes (simple approach for now)
        try clearCachedClasses()

        // Insert new classes
        for fitnessClass in classes {
            context.insert(fitnessClass)
        }

        try context.save()
    }

    @MainActor
    private func cacheClass(_ fitnessClass: FitnessClass) throws {
        guard let context = modelContext else { return }

        // Check if class already exists
        let descriptor = FetchDescriptor<FitnessClass>(
            predicate: #Predicate { $0.id == fitnessClass.id }
        )

        let existing = try context.fetch(descriptor)

        // Remove existing
        for existingClass in existing {
            context.delete(existingClass)
        }

        // Insert new
        context.insert(fitnessClass)
        try context.save()
    }

    private func getCachedClasses() throws -> [FitnessClass] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<FitnessClass>(
            sortBy: [SortDescriptor(\.startTime)]
        )
        return try context.fetch(descriptor)
    }

    private func getCachedClass(id: String) throws -> FitnessClass? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<FitnessClass>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func clearCachedClasses() throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<FitnessClass>()
        let classes = try context.fetch(descriptor)

        for fitnessClass in classes {
            context.delete(fitnessClass)
        }

        try context.save()
    }
}
