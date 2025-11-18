//
//  ReviewRepository.swift
//  Numina
//
//  Repository for review data operations
//

import Foundation
import SwiftData

final class ReviewRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Fetch Reviews

    func getReviews(
        classId: String,
        sort: ReviewSortOption? = nil,
        page: Int = 1,
        limit: Int = 20,
        fromCache: Bool = false
    ) async throws -> ReviewListResponse {
        if fromCache {
            let cachedReviews = try getCachedReviews(classId: classId)
            return ReviewListResponse(
                reviews: cachedReviews.map { $0.toDTO() },
                total: cachedReviews.count,
                averageRating: calculateAverageRating(cachedReviews),
                page: 1,
                limit: cachedReviews.count
            )
        }

        let response: ReviewListResponse = try await apiClient.request(
            endpoint: .getReviews(
                classId: classId,
                sort: sort?.queryValue,
                page: page,
                limit: limit
            )
        )

        // Cache reviews
        let reviews = response.reviews.map { $0.toModel() }
        try await cacheReviews(reviews)

        return response
    }

    func getMyReviews(fromCache: Bool = false) async throws -> [Review] {
        if fromCache {
            return try getCachedMyReviews()
        }

        let response: ReviewListResponse = try await apiClient.request(
            endpoint: .getMyReviews
        )

        let reviews = response.reviews.map { $0.toModel() }
        try await cacheReviews(reviews)

        return reviews
    }

    func getPendingReviews() async throws -> [FitnessClass] {
        // This would return classes that need reviews
        let response: ClassListResponse = try await apiClient.request(
            endpoint: .getPendingReviews
        )

        return response.classes.map { $0.toModel() }
    }

    // MARK: - Create/Update/Delete Reviews

    func createReview(
        classId: String,
        rating: Int,
        reviewText: String,
        pros: [String] = [],
        cons: [String] = [],
        photoURLs: [String] = []
    ) async throws -> Review {
        let request = CreateReviewRequest(
            rating: rating,
            reviewText: reviewText,
            pros: pros,
            cons: cons,
            photoURLs: photoURLs
        )

        let reviewDTO: ReviewDTO = try await apiClient.request(
            endpoint: .createReview(classId: classId),
            body: request
        )

        let review = reviewDTO.toModel()
        try await cacheReview(review)

        return review
    }

    func updateReview(
        reviewId: String,
        rating: Int? = nil,
        reviewText: String? = nil,
        pros: [String]? = nil,
        cons: [String]? = nil,
        photoURLs: [String]? = nil
    ) async throws -> Review {
        let request = UpdateReviewRequest(
            rating: rating,
            reviewText: reviewText,
            pros: pros,
            cons: cons,
            photoURLs: photoURLs
        )

        let reviewDTO: ReviewDTO = try await apiClient.request(
            endpoint: .updateReview(reviewId: reviewId),
            body: request
        )

        let review = reviewDTO.toModel()
        try await cacheReview(review)

        return review
    }

    func deleteReview(reviewId: String) async throws {
        try await apiClient.requestWithoutResponse(
            endpoint: .deleteReview(reviewId: reviewId)
        )

        try await deleteCachedReview(reviewId: reviewId)
    }

    func markReviewHelpful(reviewId: String) async throws -> Int {
        let response: MarkHelpfulResponse = try await apiClient.request(
            endpoint: .markReviewHelpful(reviewId: reviewId)
        )

        return response.helpfulCount
    }

    // MARK: - Local Cache

    @MainActor
    private func cacheReviews(_ reviews: [Review]) throws {
        guard let context = modelContext else { return }

        for review in reviews {
            // Check if review already exists
            let descriptor = FetchDescriptor<Review>(
                predicate: #Predicate { $0.id == review.id }
            )

            let existing = try context.fetch(descriptor)

            // Remove existing
            for existingReview in existing {
                context.delete(existingReview)
            }

            // Insert new
            context.insert(review)
        }

        try context.save()
    }

    @MainActor
    private func cacheReview(_ review: Review) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Review>(
            predicate: #Predicate { $0.id == review.id }
        )

        let existing = try context.fetch(descriptor)

        for existingReview in existing {
            context.delete(existingReview)
        }

        context.insert(review)
        try context.save()
    }

    private func getCachedReviews(classId: String) throws -> [Review] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Review>(
            predicate: #Predicate { $0.classId == classId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func getCachedMyReviews() throws -> [Review] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Review>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    private func deleteCachedReview(reviewId: String) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Review>(
            predicate: #Predicate { $0.id == reviewId }
        )

        let reviews = try context.fetch(descriptor)
        for review in reviews {
            context.delete(review)
        }

        try context.save()
    }

    private func calculateAverageRating(_ reviews: [Review]) -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }
}
