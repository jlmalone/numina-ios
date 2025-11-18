//
//  UserListRow.swift
//  Numina
//
//  Reusable user list row component
//

import SwiftUI

struct UserListRow: View {
    let user: SocialProfile
    let showFollowButton: Bool
    let onFollow: (() -> Void)?

    init(user: SocialProfile, showFollowButton: Bool = true, onFollow: (() -> Void)? = nil) {
        self.user = user
        self.showFollowButton = showFollowButton
        self.onFollow = onFollow
    }

    var body: some View {
        HStack(spacing: 12) {
            // User Photo
            if let photoURL = user.photoURL {
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
                .frame(width: 60, height: 60)
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
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(user.name.prefix(1).uppercased())
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                    )
            }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.headline)

                    if user.isMutualConnection {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                if let bio = user.bio {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Stats and Info
                HStack(spacing: 12) {
                    if !user.fitnessInterests.isEmpty {
                        Text(user.fitnessInterests.prefix(2).joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if let location = user.locationName {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)

                            Text(location)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }

                // Connection status
                if !user.connectionStatus.isEmpty {
                    Text(user.connectionStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Follow Button
            if showFollowButton {
                Button(action: {
                    onFollow?()
                }) {
                    Text(user.isFollowing ? "Following" : "Follow")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(user.isFollowing ? .primary : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(user.isFollowing ? Color(.systemGray5) : Color.orange)
                        .cornerRadius(20)
                }
            }
        }
        .padding(12)
    }
}

#Preview {
    VStack(spacing: 0) {
        UserListRow(
            user: SocialProfile(
                id: "1",
                name: "Sarah Johnson",
                bio: "Yoga enthusiast and fitness lover",
                fitnessInterests: ["Yoga", "HIIT"],
                fitnessLevel: 7,
                locationName: "San Francisco, CA",
                followersCount: 234,
                followingCount: 189,
                classesAttended: 45,
                isFollowing: false
            ),
            onFollow: {}
        )

        Divider()

        UserListRow(
            user: SocialProfile(
                id: "2",
                name: "Mike Chen",
                bio: "CrossFit coach and marathon runner",
                fitnessInterests: ["CrossFit", "Running"],
                fitnessLevel: 9,
                locationName: "New York, NY",
                followersCount: 456,
                followingCount: 234,
                classesAttended: 120,
                isFollowing: true,
                isMutualConnection: true
            ),
            onFollow: {}
        )
    }
    .background(Color(.systemBackground))
}
