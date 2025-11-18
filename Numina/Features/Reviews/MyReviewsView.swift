//
//  MyReviewsView.swift
//  Numina
//
//  View for displaying user's reviews
//

import SwiftUI
import SwiftData

struct MyReviewsView: View {
    @StateObject private var viewModel: MyReviewsViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MyReviewsViewModel(
            reviewRepository: ReviewRepository(modelContext: modelContext)
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.reviews.isEmpty {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.reviews.isEmpty {
                ErrorView(message: errorMessage, retryAction: {
                    Task {
                        await viewModel.loadMyReviews()
                    }
                })
            } else {
                content
            }
        }
        .navigationTitle("My Reviews")
        .task {
            await viewModel.loadMyReviews()
        }
        .refreshable {
            await viewModel.refreshReviews()
        }
        .alert("Delete Review", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteReview()
                }
            }
        } message: {
            Text("Are you sure you want to delete this review? This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasReviews {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats header
                    statsHeader

                    // Reviews list
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.reviews, id: \.id) { review in
                            reviewCard(review)
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        } else {
            emptyState
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("\(viewModel.totalReviews)")
                    .font(.title.bold())

                Text(viewModel.totalReviews == 1 ? "Review" : "Reviews")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text(viewModel.formattedAverageRating)
                    .font(.title.bold())

                StarRatingView(rating: Int(viewModel.averageRating.rounded()), size: 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Class Review")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        StarRatingView(rating: review.rating, size: 16)

                        Text(review.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button(role: .destructive) {
                        viewModel.confirmDelete(review: review)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Text(review.reviewText)
                .font(.body)

            // Pros and Cons
            if !review.pros.isEmpty || !review.cons.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    if !review.pros.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Pros", systemImage: "hand.thumbsup.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.green)

                            ForEach(review.pros, id: \.self) { pro in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                    Text(pro)
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !review.cons.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Cons", systemImage: "hand.thumbsdown.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.red)

                            ForEach(review.cons, id: \.self) { con in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                    Text(con)
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            // Stats
            HStack(spacing: 16) {
                Label("\(review.helpfulCount)", systemImage: "hand.thumbsup")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !review.photoURLs.isEmpty {
                    Label("\(review.photoURLs.count)", systemImage: "photo")
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.bubble")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))

            Text("No reviews yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Your reviews will appear here after you write them")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyReviewsView(
            modelContext: ModelContext(
                try! ModelContainer(for: Review.self)
            )
        )
    }
}
