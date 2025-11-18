//
//  ReviewsListView.swift
//  Numina
//
//  View for displaying reviews list
//

import SwiftUI
import SwiftData

struct ReviewsListView: View {
    @StateObject private var viewModel: ReviewsViewModel
    @State private var showingWriteReview = false
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    init(classId: String, modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ReviewsViewModel(
            classId: classId,
            reviewRepository: ReviewRepository(modelContext: modelContext)
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            OfflineBanner()

            Group {
                if viewModel.isLoading && viewModel.reviews.isEmpty {
                    skeletonLoadingView
                } else if let errorMessage = viewModel.errorMessage, viewModel.reviews.isEmpty {
                    if !networkMonitor.isConnected {
                        NetworkErrorView {
                            Task {
                                await viewModel.loadReviews()
                            }
                        }
                    } else {
                        ErrorView(message: errorMessage, retryAction: {
                            Task {
                                await viewModel.loadReviews()
                            }
                        })
                    }
                } else {
                    content
                }
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Write Review") {
                    HapticFeedback.shared.buttonPress()
                    showingWriteReview = true
                }
                .accessibilityLabel("Write a review")
                .accessibilityHint("Opens form to write a review for this class")
            }
        }
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(classId: viewModel.classId) {
                Task {
                    await viewModel.refreshReviews()
                }
            }
        }
        .task {
            await viewModel.loadReviews()
        }
        .refreshable {
            HapticFeedback.shared.refreshStart()
            await viewModel.refreshReviews()
            HapticFeedback.shared.refreshComplete()
        }
    }

    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonReviewRow()
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary header
                summaryHeader

                // Sort options
                sortPicker

                // Reviews list
                if viewModel.hasReviews {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.reviews, id: \.id) { review in
                            ReviewRow(review: review) {
                                Task {
                                    await viewModel.markReviewHelpful(reviewId: review.id)
                                }
                            }
                        }
                    }
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var summaryHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formattedAverageRating)
                        .font(.system(size: 48, weight: .bold))

                    StarRatingView(rating: Int(viewModel.averageRating.rounded()), size: 24)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.totalReviews)")
                        .font(.title2.bold())

                    Text(viewModel.totalReviews == 1 ? "review" : "reviews")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    private var sortPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReviewSortOption.allCases) { option in
                    Button {
                        HapticFeedback.shared.selection()
                        Task {
                            await viewModel.changeSort(option)
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedSort == option ? Color.blue : Color(uiColor: .systemGray6))
                            )
                            .foregroundStyle(viewModel.selectedSort == option ? .white : .primary)
                    }
                    .accessibilityLabel("Sort by \(option.rawValue)")
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.bubble")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))

            Text("No reviews yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Be the first to review this class!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Write Review") {
                showingWriteReview = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReviewsListView(
            classId: "class123",
            modelContext: ModelContext(
                try! ModelContainer(for: Review.self)
            )
        )
    }
}
