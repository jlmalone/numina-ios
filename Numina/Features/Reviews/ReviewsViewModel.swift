//
//  ReviewsViewModel.swift
//  Numina
//
//  ViewModel for viewing reviews
//

import Foundation
import SwiftData

@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var averageRating: Double = 0.0
    @Published var totalReviews: Int = 0
    @Published var selectedSort: ReviewSortOption = .mostRecent

    private let reviewRepository: ReviewRepository
    private let classId: String

    init(classId: String, reviewRepository: ReviewRepository) {
        self.classId = classId
        self.reviewRepository = reviewRepository
    }

    // MARK: - Load Reviews

    func loadReviews(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await reviewRepository.getReviews(
                classId: classId,
                sort: selectedSort,
                fromCache: fromCache
            )

            reviews = response.reviews.map { $0.toModel() }
            averageRating = response.averageRating
            totalReviews = response.total
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshReviews() async {
        await loadReviews(fromCache: false)
    }

    // MARK: - Sort

    func changeSort(_ newSort: ReviewSortOption) async {
        selectedSort = newSort
        await loadReviews()
    }

    // MARK: - Helpful

    func markReviewHelpful(reviewId: String) async {
        do {
            let newCount = try await reviewRepository.markReviewHelpful(reviewId: reviewId)

            // Update local review
            if let index = reviews.firstIndex(where: { $0.id == reviewId }) {
                reviews[index].helpfulCount = newCount
                reviews[index].isHelpfulByCurrentUser = true
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Properties

    var hasReviews: Bool {
        !reviews.isEmpty
    }

    var formattedAverageRating: String {
        String(format: "%.1f", averageRating)
    }
}
