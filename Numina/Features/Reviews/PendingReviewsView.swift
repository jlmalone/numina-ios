//
//  PendingReviewsView.swift
//  Numina
//
//  View for displaying classes that need reviews
//

import SwiftUI
import SwiftData

struct PendingReviewsView: View {
    @State private var pendingClasses: [FitnessClass] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedClass: FitnessClass?
    @State private var showingWriteReview = false

    private let reviewRepository: ReviewRepository

    init(modelContext: ModelContext) {
        self.reviewRepository = ReviewRepository(modelContext: modelContext)
    }

    var body: some View {
        Group {
            if isLoading && pendingClasses.isEmpty {
                LoadingView()
            } else if let errorMessage = errorMessage, pendingClasses.isEmpty {
                ErrorView(message: errorMessage, retryAction: {
                    Task {
                        await loadPendingReviews()
                    }
                })
            } else {
                content
            }
        }
        .navigationTitle("Pending Reviews")
        .task {
            await loadPendingReviews()
        }
        .refreshable {
            await loadPendingReviews()
        }
        .sheet(isPresented: $showingWriteReview) {
            if let classToReview = selectedClass {
                WriteReviewView(classId: classToReview.id) {
                    Task {
                        await loadPendingReviews()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !pendingClasses.isEmpty {
            ScrollView {
                VStack(spacing: 16) {
                    // Info banner
                    infoBanner

                    // Pending classes
                    LazyVStack(spacing: 16) {
                        ForEach(pendingClasses, id: \.id) { fitnessClass in
                            pendingClassCard(fitnessClass)
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

    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Share Your Experience")
                    .font(.headline)

                Text("Help others by reviewing classes you've attended")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }

    private func pendingClassCard(_ fitnessClass: FitnessClass) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Class image
            if let imageURL = fitnessClass.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Class info
            VStack(alignment: .leading, spacing: 8) {
                Text(fitnessClass.name)
                    .font(.headline)

                HStack {
                    Label(fitnessClass.classType, systemImage: "figure.run")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(fitnessClass.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("with \(fitnessClass.trainerName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Review button
            Button {
                selectedClass = fitnessClass
                showingWriteReview = true
            } label: {
                Label("Write Review", systemImage: "square.and.pencil")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("All caught up!")
                .font(.headline)

            Text("You've reviewed all your recent classes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Data Loading

    private func loadPendingReviews() async {
        isLoading = true
        errorMessage = nil

        do {
            pendingClasses = try await reviewRepository.getPendingReviews()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PendingReviewsView(
            modelContext: ModelContext(
                try! ModelContainer(for: Review.self, FitnessClass.self)
            )
        )
    }
}
