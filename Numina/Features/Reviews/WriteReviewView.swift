//
//  WriteReviewView.swift
//  Numina
//
//  View for writing a review
//

import SwiftUI
import SwiftData
import PhotosUI

struct WriteReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: WriteReviewViewModel
    @State private var showingPhotoPicker = false

    let onReviewSubmitted: () -> Void

    init(classId: String, onReviewSubmitted: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: WriteReviewViewModel(
            classId: classId,
            reviewRepository: ReviewRepository()
        ))
        self.onReviewSubmitted = onReviewSubmitted
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Rating section
                    ratingSection

                    // Review text
                    reviewTextSection

                    // Pros section
                    prosSection

                    // Cons section
                    consSection

                    // Photos section
                    photosSection

                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Submit button
                    submitButton
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var ratingSection: some View {
        VStack(spacing: 12) {
            Text("How would you rate this class?")
                .font(.headline)

            StarRatingView(
                rating: viewModel.rating,
                size: 40,
                interactive: true,
                onRatingChanged: { newRating in
                    viewModel.rating = newRating
                }
            )

            if viewModel.rating > 0 {
                Text(ratingDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }

    private var reviewTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Review")
                .font(.headline)

            TextEditor(text: $viewModel.reviewText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            Text("\(viewModel.reviewText.count) characters")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var prosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pros", systemImage: "hand.thumbsup.fill")
                .font(.headline)
                .foregroundStyle(.green)

            // List of pros
            ForEach(Array(viewModel.pros.enumerated()), id: \.offset) { index, pro in
                HStack {
                    Text(pro)
                        .font(.body)

                    Spacer()

                    Button {
                        viewModel.removePro(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Add pro field
            HStack {
                TextField("Add a pro...", text: $viewModel.newPro)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        viewModel.addPro()
                    }

                Button {
                    viewModel.addPro()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
                .disabled(viewModel.newPro.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }

    private var consSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Cons", systemImage: "hand.thumbsdown.fill")
                .font(.headline)
                .foregroundStyle(.red)

            // List of cons
            ForEach(Array(viewModel.cons.enumerated()), id: \.offset) { index, con in
                HStack {
                    Text(con)
                        .font(.body)

                    Spacer()

                    Button {
                        viewModel.removeCon(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Add con field
            HStack {
                TextField("Add a con...", text: $viewModel.newCon)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        viewModel.addCon()
                    }

                Button {
                    viewModel.addCon()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .disabled(viewModel.newCon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Photos (Optional)", systemImage: "photo")
                .font(.headline)

            if !viewModel.photoURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.photoURLs.enumerated()), id: \.offset) { index, url in
                            ZStack(alignment: .topTrailing) {
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(.gray.opacity(0.2))
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                Button {
                                    viewModel.removePhoto(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(.black.opacity(0.6)))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }

            Button {
                showingPhotoPicker = true
            } label: {
                Label("Add Photos", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }

    private var submitButton: some View {
        Button {
            Task {
                let success = await viewModel.submitReview()
                if success {
                    onReviewSubmitted()
                    dismiss()
                }
            }
        } label: {
            if viewModel.isSubmitting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Submit Review")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.isValid ? Color.blue : Color.gray)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(!viewModel.isValid || viewModel.isSubmitting)
    }

    // MARK: - Helpers

    private var ratingDescription: String {
        switch viewModel.rating {
        case 1:
            return "Poor"
        case 2:
            return "Fair"
        case 3:
            return "Good"
        case 4:
            return "Very Good"
        case 5:
            return "Excellent"
        default:
            return ""
        }
    }
}

// MARK: - Preview

#Preview {
    WriteReviewView(classId: "class123")
        .modelContainer(for: Review.self)
}
