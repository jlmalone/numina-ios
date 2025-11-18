//
//  ActivityDetailView.swift
//  Numina
//
//  Detailed view for an activity with comments
//

import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @ObservedObject var viewModel: FeedViewModel
    @State private var comments: [Comment] = []
    @State private var newCommentText: String = ""
    @State private var isLoadingComments = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Activity Content (similar to feed item but expanded)
                    activityContent

                    Divider()
                        .padding(.horizontal)

                    // Comments Section
                    commentsSection
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadComments()
            }
        }
    }

    private var activityContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User Info Header
            HStack(spacing: 12) {
                if let photoURL = activity.userPhotoURL {
                    AsyncImage(url: URL(string: photoURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .red.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(activity.userName.prefix(1).uppercased())
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.userName)
                        .font(.headline)

                    Text(activity.timeAgoDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Activity Content
            Text(activity.title)
                .font(.title3.weight(.semibold))

            if let description = activity.activityDescription {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Class Info
            if let className = activity.className {
                HStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(className)
                            .font(.body.weight(.medium))

                        if let classType = activity.classType {
                            Text(classType)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            // Activity Image
            if let imageURL = activity.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .cornerRadius(12)
            }

            // Action Buttons
            HStack(spacing: 32) {
                Button(action: {
                    Task {
                        await viewModel.toggleLike(activity: activity)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: activity.isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(activity.isLiked ? .red : .primary)

                        Text("\(activity.likesCount)")
                            .font(.body.weight(.medium))
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "bubble.right")
                        .font(.title3)

                    Text("\(activity.commentsCount)")
                        .font(.body.weight(.medium))
                }
            }
        }
        .padding()
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)

            if isLoadingComments {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(comments, id: \.id) { comment in
                    CommentRow(comment: comment)
                        .padding(.horizontal)
                }
            }

            // Add Comment
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...4)

                    Button(action: {
                        Task {
                            await postComment()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .orange)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }

    private func loadComments() async {
        isLoadingComments = true

        do {
            comments = try await viewModel.socialRepository.getActivityComments(activityId: activity.id)
        } catch {
            // Handle error silently or show a message
        }

        isLoadingComments = false
    }

    private func postComment() async {
        let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        newCommentText = ""

        await viewModel.addComment(to: activity, text: text)
        await loadComments()
    }
}

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let photoURL = comment.userPhotoURL {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.orange.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(comment.userName.prefix(1).uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(comment.userName)
                        .font(.subheadline.weight(.semibold))

                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(comment.text)
                    .font(.body)
            }

            Spacer()
        }
    }
}

#Preview {
    ActivityDetailView(
        activity: Activity(
            id: "1",
            userId: "user1",
            userName: "Sarah Johnson",
            activityType: "class_completed",
            title: "Completed a Power Yoga class!",
            activityDescription: "Feeling energized after this amazing session",
            className: "Power Yoga Flow",
            classType: "Yoga",
            likesCount: 12,
            commentsCount: 3
        ),
        viewModel: FeedViewModel(socialRepository: SocialRepository())
    )
}
