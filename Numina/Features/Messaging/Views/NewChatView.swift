//
//  NewChatView.swift
//  Numina
//
//  View for starting a new conversation
//

import SwiftUI

struct NewChatView: View {
    @ObservedObject var viewModel: MessagesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchQuery = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var selectedUsers: Set<String> = []
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBarView

                // Search results
                if isSearching {
                    LoadingView()
                } else if let error = searchError {
                    ErrorView(message: error) {
                        Task {
                            await performSearch()
                        }
                    }
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    emptyResultsView
                } else {
                    userListView
                }
            }
            .navigationTitle("New Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await createConversation()
                        }
                    }
                    .foregroundColor(.orange)
                    .disabled(selectedUsers.isEmpty || isCreating)
                }
            }
        }
    }

    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search by name or interests", text: $searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: searchQuery) { _, newValue in
                    Task {
                        if newValue.count >= 2 {
                            try? await Task.sleep(nanoseconds: 500_000_000) // Debounce
                            if searchQuery == newValue {
                                await performSearch()
                            }
                        } else {
                            searchResults = []
                        }
                    }
                }

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                    searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private var userListView: some View {
        List {
            if searchResults.isEmpty && searchQuery.isEmpty {
                // Recently matched users section (placeholder)
                Section {
                    Text("Search for users to start a conversation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } header: {
                    Text("Get Started")
                }
            } else {
                Section {
                    ForEach(searchResults, id: \.id) { user in
                        UserRow(
                            user: user,
                            isSelected: selectedUsers.contains(user.id)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleUserSelection(user.id)
                        }
                    }
                } header: {
                    Text("Search Results")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Users Found")
                .font(.title3.weight(.medium))

            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    // MARK: - Actions

    private func performSearch() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        searchError = nil

        do {
            searchResults = try await viewModel.messageRepository.searchUsers(query: searchQuery)
        } catch {
            searchError = error.localizedDescription
        }

        isSearching = false
    }

    private func toggleUserSelection(_ userId: String) {
        if selectedUsers.contains(userId) {
            selectedUsers.remove(userId)
        } else {
            selectedUsers.insert(userId)
        }
    }

    private func createConversation() async {
        guard !selectedUsers.isEmpty else { return }

        isCreating = true

        do {
            // Get current user ID and add to participants
            let participantIds = Array(selectedUsers)

            let conversation = try await viewModel.createConversation(with: participantIds)

            // Refresh conversations list
            await viewModel.loadConversations()

            dismiss()
        } catch {
            searchError = error.localizedDescription
        }

        isCreating = false
    }
}

// MARK: - User Row

struct UserRow: View {
    let user: User
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            avatarView
                .frame(width: 50, height: 50)

            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)

                if !user.fitnessInterests.isEmpty {
                    Text(user.fitnessInterests.prefix(3).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let locationName = user.locationName {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(locationName)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var avatarView: some View {
        Group {
            if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    defaultAvatar
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                defaultAvatar
            }
        }
    }

    private var defaultAvatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.orange.opacity(0.7), .red.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 50, height: 50)
            .overlay(
                Text(user.name.prefix(1).uppercased())
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Preview

#Preview {
    NewChatView(
        viewModel: MessagesViewModel(
            messageRepository: MessageRepository()
        )
    )
}
