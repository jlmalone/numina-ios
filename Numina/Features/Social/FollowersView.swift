//
//  FollowersView.swift
//  Numina
//
//  View showing a user's followers
//

import SwiftUI

struct FollowersView: View {
    let userId: String
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var selectedUser: SocialProfile?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoadingFollowers && viewModel.followers.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.followers.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadFollowers(userId: userId)
                        }
                    }
                } else if viewModel.followers.isEmpty {
                    EmptyFollowersView()
                } else {
                    followersList
                }
            }
            .navigationTitle("Followers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedUser) { user in
                UserProfileView(
                    userId: user.id,
                    viewModel: UserProfileViewModel(socialRepository: viewModel.socialRepository)
                )
            }
            .task {
                if viewModel.followers.isEmpty {
                    await viewModel.loadFollowers(userId: userId)
                }
            }
        }
    }

    private var followersList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.followers, id: \.id) { user in
                    UserListRow(
                        user: user,
                        showFollowButton: false
                    )
                    .onTapGesture {
                        selectedUser = user
                    }

                    Divider()
                        .padding(.leading, 84)
                }
            }
        }
    }
}

struct EmptyFollowersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Followers Yet")
                .font(.title3.weight(.medium))

            Text("This user doesn't have any followers yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    FollowersView(
        userId: "user1",
        viewModel: UserProfileViewModel(socialRepository: SocialRepository())
    )
}
