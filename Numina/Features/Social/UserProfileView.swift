//
//  UserProfileView.swift
//  Numina
//
//  Public user profile view
//

import SwiftUI

struct UserProfileView: View {
    let userId: String
    @StateObject var viewModel: UserProfileViewModel
    @State private var showingFollowers = false
    @State private var showingFollowing = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.profile == nil {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadProfile(userId: userId)
                        }
                    }
                } else if let profile = viewModel.profile {
                    profileContent(profile: profile)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFollowers) {
                FollowersView(
                    userId: userId,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $showingFollowing) {
                FollowingView(
                    userId: userId,
                    viewModel: viewModel
                )
            }
            .task {
                await viewModel.loadProfile(userId: userId)
            }
        }
    }

    private func profileContent(profile: SocialProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                profileHeader(profile: profile)

                // Stats
                statsSection(profile: profile)

                // Follow Button
                followButton(profile: profile)

                // Bio
                if let bio = profile.bio {
                    bioSection(bio: bio)
                }

                // Interests
                if !profile.fitnessInterests.isEmpty {
                    interestsSection(interests: profile.fitnessInterests)
                }

                // Location
                if let location = profile.locationName {
                    locationSection(location: location)
                }

                Spacer()
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshProfile()
        }
    }

    private func profileHeader(profile: SocialProfile) -> some View {
        VStack(spacing: 16) {
            // Profile Photo
            if let photoURL = profile.photoURL {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 120, height: 120)
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
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(profile.name.prefix(1).uppercased())
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            // Name and Status
            VStack(spacing: 4) {
                Text(profile.name)
                    .font(.title2.weight(.bold))

                if profile.isMutualConnection {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.orange)

                        Text("Mutual Connection")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                } else if profile.isFollowedBy {
                    Text("Follows You")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func statsSection(profile: SocialProfile) -> some View {
        HStack(spacing: 40) {
            StatView(
                count: profile.classesAttended,
                label: "Classes",
                action: nil
            )

            StatView(
                count: profile.followersCount,
                label: "Followers",
                action: {
                    showingFollowers = true
                }
            )

            StatView(
                count: profile.followingCount,
                label: "Following",
                action: {
                    showingFollowing = true
                }
            )
        }
    }

    private func followButton(profile: SocialProfile) -> some View {
        Button(action: {
            Task {
                await viewModel.toggleFollow()
            }
        }) {
            Text(profile.isFollowing ? "Following" : "Follow")
                .font(.body.weight(.semibold))
                .foregroundColor(profile.isFollowing ? .primary : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(profile.isFollowing ? Color(.systemGray5) : Color.orange)
                .cornerRadius(12)
        }
    }

    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            Text(bio)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func interestsSection(interests: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fitness Interests")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func locationSection(location: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "location.fill")
                .foregroundColor(.secondary)

            Text(location)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatView: View {
    let count: Int
    let label: String
    let action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .disabled(action == nil)
    }
}

// Simple flow layout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }
        totalHeight += lineHeight

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if lineX + size.width > bounds.maxX {
                lineX = bounds.minX
                lineY += lineHeight + spacing
                lineHeight = 0
            }

            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: .unspecified)
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    UserProfileView(
        userId: "user1",
        viewModel: UserProfileViewModel(socialRepository: SocialRepository())
    )
}
