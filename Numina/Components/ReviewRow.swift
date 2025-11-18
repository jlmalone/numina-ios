//
//  ReviewRow.swift
//  Numina
//
//  Review card component
//

import SwiftUI

struct ReviewRow: View {
    let review: Review
    let onHelpfulTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with user info and rating
            HStack(alignment: .top) {
                // User photo
                if let photoURL = review.userPhotoURL {
                    AsyncImage(url: URL(string: photoURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(.gray.opacity(0.2))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(review.userName.prefix(1).uppercased())
                                .font(.headline)
                                .foregroundStyle(.gray)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.headline)

                    HStack(spacing: 8) {
                        StarRatingView(rating: review.rating, size: 16)

                        Text(review.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if review.isRecent {
                    Text("NEW")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }

            // Review text
            Text(review.reviewText)
                .font(.body)
                .foregroundStyle(.primary)

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

            // Photos
            if !review.photoURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.photoURLs, id: \.self) { photoURL in
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(.gray.opacity(0.2))
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            // Helpful button
            HStack {
                Button(action: onHelpfulTapped) {
                    HStack(spacing: 4) {
                        Image(systemName: review.isHelpfulByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.caption)

                        Text("Helpful (\(review.helpfulCount))")
                            .font(.caption)
                    }
                    .foregroundStyle(review.isHelpfulByCurrentUser ? .blue : .secondary)
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
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ReviewRow(
                review: Review(
                    id: "1",
                    classId: "class1",
                    userId: "user1",
                    userName: "Sarah Johnson",
                    userPhotoURL: nil,
                    rating: 5,
                    reviewText: "Amazing class! The instructor was very knowledgeable and the workout was challenging but fun.",
                    pros: ["Great instructor", "Good music", "Clean studio"],
                    cons: ["A bit crowded"],
                    photoURLs: [],
                    helpfulCount: 12,
                    isHelpfulByCurrentUser: false,
                    createdAt: Date().addingTimeInterval(-86400 * 2)
                ),
                onHelpfulTapped: {}
            )

            ReviewRow(
                review: Review(
                    id: "2",
                    classId: "class1",
                    userId: "user2",
                    userName: "Mike Chen",
                    userPhotoURL: nil,
                    rating: 4,
                    reviewText: "Solid workout, would recommend!",
                    pros: ["Effective workout"],
                    cons: [],
                    photoURLs: [],
                    helpfulCount: 5,
                    isHelpfulByCurrentUser: true,
                    createdAt: Date().addingTimeInterval(-86400)
                ),
                onHelpfulTapped: {}
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
