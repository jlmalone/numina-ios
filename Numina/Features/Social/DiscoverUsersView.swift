//
//  DiscoverUsersView.swift
//  Numina
//
//  User discovery and search view
//

import SwiftUI

struct DiscoverUsersView: View {
    @StateObject var viewModel: DiscoverViewModel
    @State private var showingFilters = false
    @State private var selectedUser: SocialProfile?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Content
                ZStack {
                    if viewModel.isLoading && viewModel.users.isEmpty {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await viewModel.searchUsers()
                            }
                        }
                    } else if viewModel.users.isEmpty && viewModel.hasActiveFilters() {
                        EmptySearchView()
                    } else if viewModel.users.isEmpty {
                        DiscoverPlaceholderView()
                    } else {
                        usersList
                    }
                }
            }
            .navigationTitle("Discover Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: viewModel.hasActiveFilters() ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                DiscoverFiltersView(viewModel: viewModel)
            }
            .sheet(item: $selectedUser) { user in
                UserProfileView(
                    userId: user.id,
                    viewModel: UserProfileViewModel(socialRepository: viewModel.socialRepository)
                )
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search users...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.searchUsers()
                    }
                }

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }

    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.users, id: \.id) { user in
                    UserListRow(
                        user: user,
                        onFollow: {
                            Task {
                                await viewModel.toggleFollow(user: user)
                            }
                        }
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

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Users Found")
                .font(.title3.weight(.medium))

            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct DiscoverPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("Discover Fitness Friends")
                .font(.title3.weight(.medium))

            Text("Search for users or use filters to find people with similar fitness interests")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    DiscoverUsersView(
        viewModel: DiscoverViewModel(
            socialRepository: SocialRepository()
        )
    )
}
