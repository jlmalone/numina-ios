//
//  MyReviewsViewModel.swift
//  Numina
//
//  ViewModel for managing user's reviews
//

import Foundation
import SwiftData

@MainActor
final class MyReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false
    @Published var reviewToDelete: Review?

    private let reviewRepository: ReviewRepository

    init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    // MARK: - Load Reviews

    func loadMyReviews(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            reviews = try await reviewRepository.getMyReviews(fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshReviews() async {
        await loadMyReviews(fromCache: false)
    }

    // MARK: - Delete Review

    func confirmDelete(review: Review) {
        reviewToDelete = review
        showDeleteConfirmation = true
    }

    func deleteReview() async {
        guard let review = reviewToDelete else { return }

        do {
            try await reviewRepository.deleteReview(reviewId: review.id)
            reviews.removeAll { $0.id == review.id }
            reviewToDelete = nil
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

    var totalReviews: Int {
        reviews.count
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }

    var formattedAverageRating: String {
        String(format: "%.1f", averageRating)
    }
}
