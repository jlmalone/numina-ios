//
//  ActivityFeedItem.swift
//  Numina
//
//  Reusable activity feed item component
//

import SwiftUI

struct ActivityFeedItem: View {
    let activity: Activity
    let onLike: () -> Void
    let onComment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info Header
            HStack(spacing: 12) {
                // User Photo
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
                    .frame(width: 48, height: 48)
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
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(activity.userName.prefix(1).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.userName)
                        .font(.headline)

                    Text(activity.timeAgoDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Activity Content
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title)
                    .font(.body.weight(.semibold))

                if let description = activity.activityDescription {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Class Info (if available)
                if let className = activity.className {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(className)
                                .font(.subheadline.weight(.medium))

                            if let classType = activity.classType {
                                Text(classType)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(12)
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
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                }
            }

            // Action Buttons
            HStack(spacing: 24) {
                // Like Button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: activity.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(activity.isLiked ? .red : .primary)

                        if activity.likesCount > 0 {
                            Text("\(activity.likesCount)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }

                // Comment Button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.primary)

                        if activity.commentsCount > 0 {
                            Text("\(activity.commentsCount)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ActivityFeedItem(
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
        onLike: {},
        onComment: {}
    )
    .padding()
}
