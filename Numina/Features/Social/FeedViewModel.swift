//
//  FeedViewModel.swift
//  Numina
//
//  ViewModel for social activity feed
//

import Foundation
import SwiftData

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true

    private let socialRepository: SocialRepository
    private let pageLimit = 20

    init(socialRepository: SocialRepository) {
        self.socialRepository = socialRepository
    }

    // MARK: - Load Feed

    func loadFeed(fromCache: Bool = false) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await socialRepository.getFeed(page: currentPage, limit: pageLimit, fromCache: fromCache)
            activities = response.activities.map { $0.toModel() }
            hasMorePages = activities.count >= pageLimit
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshFeed() async {
        await loadFeed(fromCache: false)
    }

    func loadMoreActivities() async {
        guard !isLoadingMore && hasMorePages else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let response = try await socialRepository.getFeed(page: currentPage, limit: pageLimit)
            let newActivities = response.activities.map { $0.toModel() }
            activities.append(contentsOf: newActivities)
            hasMorePages = newActivities.count >= pageLimit
        } catch let error as APIError {
            errorMessage = error.errorDescription
            currentPage -= 1 // Revert page increment on error
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1
        }

        isLoadingMore = false
    }

    // MARK: - Like/Unlike

    func toggleLike(activity: Activity) async {
        let previousLikeState = activity.isLiked
        let previousLikesCount = activity.likesCount

        // Optimistic update
        activity.isLiked.toggle()
        activity.likesCount += activity.isLiked ? 1 : -1

        do {
            if activity.isLiked {
                try await socialRepository.likeActivity(activityId: activity.id)
            } else {
                try await socialRepository.unlikeActivity(activityId: activity.id)
            }
        } catch {
            // Revert on error
            activity.isLiked = previousLikeState
            activity.likesCount = previousLikesCount
            errorMessage = "Failed to update like status"
        }
    }

    // MARK: - Comments

    func addComment(to activity: Activity, text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        do {
            _ = try await socialRepository.commentOnActivity(activityId: activity.id, text: text)

            // Optimistically update comments count
            activity.commentsCount += 1
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    func clearError() {
        errorMessage = nil
    }
}
