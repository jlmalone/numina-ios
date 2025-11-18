//
//  FollowingView.swift
//  Numina
//
//  View showing users that a user is following
//

import SwiftUI

struct FollowingView: View {
    let userId: String
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var selectedUser: SocialProfile?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoadingFollowing && viewModel.following.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.following.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadFollowing(userId: userId)
                        }
                    }
                } else if viewModel.following.isEmpty {
                    EmptyFollowingView()
                } else {
                    followingList
                }
            }
            .navigationTitle("Following")
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
                if viewModel.following.isEmpty {
                    await viewModel.loadFollowing(userId: userId)
                }
            }
        }
    }

    private var followingList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.following, id: \.id) { user in
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

struct EmptyFollowingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("Not Following Anyone")
                .font(.title3.weight(.medium))

            Text("This user isn't following anyone yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    FollowingView(
        userId: "user1",
        viewModel: UserProfileViewModel(socialRepository: SocialRepository())
    )
}
